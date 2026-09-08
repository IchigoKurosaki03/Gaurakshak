"""Cow registration, CSV import, profile, health records, and scan-to-session.

Every cow query is scoped to the current user's farm — a farmer can never
read or touch another farm's cows. See SECURITY.md (broken object-level auth).
"""
import csv
import io
import re
from datetime import UTC, date, datetime
from functools import lru_cache
from pathlib import Path
from typing import Any

from fastapi import APIRouter, Depends, File, HTTPException, Path as ApiPath, Query, UploadFile
from sqlalchemy.orm import Session

from ..database import get_db
from ..config import settings
from ..models import Alert, Cow, HealthRecord, MilkingSession, Prediction, PredictionFactor, SensorReading, User
from ..schemas import (
    CowCreate, CowUpdate, CowOut,
    HealthRecordCreate, HealthRecordOut,
    ScanCowRequest, SessionOut, CowImportOut,
)
from ..security import get_current_user

router = APIRouter(tags=["cows"])


def _require_farm(user: User) -> int:
    if user.farm_id is None:
        raise HTTPException(status_code=400, detail="Set up a farm first")
    return user.farm_id


def _get_owned_cow(cow_id: int, user: User, db: Session) -> Cow:
    cow = db.get(Cow, cow_id)
    if cow is None or cow.farm_id != user.farm_id:
        # 404 (not 403) so we don't leak that the cow exists on another farm
        raise HTTPException(status_code=404, detail="Cow not found")
    return cow


def _normalize_cow_id(value: str) -> str:
    cleaned = value.strip().casefold()
    match = re.fullmatch(r"([a-z]+)[-_ ]*0*(\d+)", cleaned)
    if match:
        return f"{match.group(1)}{int(match.group(2))}"
    return re.sub(r"[-_ ]+", "", cleaned)


def _validate_sample_id(cow_id: str) -> None:
    match = re.fullmatch(r"[a-zA-Z]+[-_ ]*0*(\d+)", cow_id.strip())
    # This pattern has one capture group: the numeric suffix.
    if match and int(match.group(1)) > 50:
        raise HTTPException(status_code=400, detail="Only cow IDs 1 through 50 are enabled for this dataset preview")


def _get_csv_samples(cow_id: str, limit: int) -> list[dict[str, Any]]:
    _validate_sample_id(cow_id)
    csv_name = "mastitis_3000_female_cows_180_days_2_readings.csv"
    csv_candidates = [
        Path(__file__).resolve().parents[3] / csv_name,
        Path(__file__).resolve().parents[2] / csv_name,
    ]
    csv_path = next((path for path in csv_candidates if path.exists()), csv_candidates[0])
    if not csv_path.exists():
        raise HTTPException(status_code=404, detail="CSV dataset not found on the server")

    rows: list[dict[str, Any]] = []
    target_id = _normalize_cow_id(cow_id)
    found_target = False
    with csv_path.open("r", newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            if row.get("cow_id") is None:
                continue
            row_id = _normalize_cow_id(str(row["cow_id"]))
            if row_id == target_id:
                found_target = True
                rows.append({
                    "cow_id": row.get("cow_id"),
                    "farm_id": row.get("farm_id"),
                    "recorded_date": row.get("recorded_date"),
                    "recorded_time": row.get("recorded_time"),
                    "reading_session": row.get("reading_session"),
                    "sex": row.get("sex"),
                    "breed": row.get("breed"),
                    "age_years": float(row.get("age_years") or 0),
                    "lactation_number": int(float(row.get("lactation_number") or 0)),
                    "previous_mastitis_history": int(float(row.get("previous_mastitis_history") or 0)),
                    "vaccination_status": row.get("vaccination_status"),
                    "milk_yield_liters": float(row.get("milk_yield_liters") or 0),
                    "milk_temperature_c": float(row.get("milk_temperature_c") or 0),
                    "milk_ph": float(row.get("milk_ph") or 0),
                    "milk_conductivity_ms_cm": float(row.get("milk_conductivity_ms_cm") or 0),
                    "somatic_cell_count": int(float(row.get("somatic_cell_count") or 0)),
                    "body_temperature_c": float(row.get("body_temperature_c") or 0),
                    "udder_temperature_c": float(row.get("udder_temperature_c") or 0),
                    "rumination_minutes": float(row.get("rumination_minutes") or 0),
                    "milking_duration_minutes": float(row.get("milking_duration_minutes") or 0),
                    "milking_hygiene_score": float(row.get("milking_hygiene_score") or 0),
                    "milking_interval_hours": float(row.get("milking_interval_hours") or 0),
                    "udder_swelling_score": float(row.get("udder_swelling_score") or 0),
                    "udder_redness_score": float(row.get("udder_redness_score") or 0),
                    "milk_abnormality_score": float(row.get("milk_abnormality_score") or 0),
                    "previous_disease_count": int(float(row.get("previous_disease_count") or 0)),
                    "antibiotic_treatment_last_30_days": int(float(row.get("antibiotic_treatment_last_30_days") or 0)),
                    "mastitis_current": int(float(row.get("mastitis_current") or 0)),
                    "risk_probability": float(row.get("risk_probability") or 0),
                    "risk_category": row.get("risk_category"),
                    "mastitis_next_7_days": int(float(row.get("mastitis_next_7_days") or 0)),
                    "mastitis_next_14_days": int(float(row.get("mastitis_next_14_days") or 0)),
                })
            elif found_target:
                # The source is ordered by cow_id, so once the next cow starts
                # we already have every reading for the requested cow. This
                # avoids rescanning 189 MB for each health or milk lookup.
                break

    if not rows:
        raise HTTPException(status_code=404, detail=f"No CSV samples found for cow ID {cow_id}")

    def timestamp(item: dict[str, Any]) -> datetime:
        raw_date = str(item.get("recorded_date") or "")
        raw_time = str(item.get("recorded_time") or "")
        try:
            return datetime.strptime(f"{raw_date} {raw_time}", "%d-%m-%Y %H:%M")
        except ValueError:
            return datetime.min

    # Keep only the newest requested samples, but return them in chronological
    # order so charts read naturally from left (older) to right (newer).
    rows.sort(key=timestamp)
    return rows[-limit:]


@router.get("/cows/sample-data")
def get_cow_samples(
    cow_id: str = Query(..., min_length=2, max_length=40, pattern=r"^[A-Za-z]+[-_ ]*\d+$"),
    limit: int = Query(50, ge=1, le=50),
):
    """Return public local-preview CSV samples, ordered oldest to newest."""
    return _get_csv_samples(cow_id, limit)


@lru_cache(maxsize=1)
def _csv_catalog() -> tuple[dict[str, Any], ...]:
    """Read the dataset once to form the preview catalog, then reuse it."""
    csv_name = "mastitis_3000_female_cows_180_days_2_readings.csv"
    csv_candidates = [
        Path(__file__).resolve().parents[3] / csv_name,
        Path(__file__).resolve().parents[2] / csv_name,
    ]
    csv_path = next((path for path in csv_candidates if path.exists()), csv_candidates[0])
    if not csv_path.exists():
        raise HTTPException(status_code=404, detail="CSV dataset not found on the server")

    catalog: list[dict[str, Any]] = []
    seen: set[str] = set()
    with csv_path.open("r", newline="", encoding="utf-8-sig") as handle:
        for row in csv.DictReader(handle):
            raw_id = row.get("cow_id")
            if not raw_id:
                continue
            normalized = _normalize_cow_id(raw_id)
            if normalized in seen:
                continue
            seen.add(normalized)
            catalog.append({
                "id": len(catalog) + 1,
                "tag_id": raw_id,
                "name": raw_id,
                "breed": row.get("breed"),
                "age_years": float(row.get("age_years") or 0),
                "today_milk_litres": float(row.get("milk_yield_liters") or 0),
                "basic_health_status": row.get("risk_category"),
            })
            if len(catalog) == 50:
                break
    return tuple(catalog)


@router.get("/cows/catalog")
def get_csv_catalog(
    limit: int = Query(50, ge=1, le=50),
):
    """Return the local-preview catalog; farm records remain authenticated."""
    return list(_csv_catalog()[:limit])


@router.get("/cows/{cow_id}/samples")
def get_cow_samples_by_path(
    cow_id: str = ApiPath(..., min_length=2, max_length=40, pattern=r"^[A-Za-z]+[-_ ]*\d+$"),
    limit: int = Query(50, ge=1, le=50),
):
    return _get_csv_samples(cow_id, limit)


@router.post("/cows", response_model=CowOut)
def create_cow(
    req: CowCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    farm_id = _require_farm(user)
    cow = Cow(farm_id=farm_id, **req.model_dump())
    db.add(cow)
    db.commit()
    db.refresh(cow)
    return cow


@router.get("/cows", response_model=list[CowOut])
def list_cows(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    farm_id = _require_farm(user)
    return db.query(Cow).filter(Cow.farm_id == farm_id).all()


@router.post("/cows/import-csv", response_model=CowImportOut)
def import_cows_csv(
    file: UploadFile = File(...),
    replace_existing: bool = True,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Import the farm's cow catalog from CSV.

    Required columns are ``cow_id`` (or ``tag_id``/``animal_id``) and
    ``name``. When ``replace_existing`` is true, the CSV becomes the source of
    truth and the current farm catalog is replaced.
    """
    farm_id = _require_farm(user)
    if not file.filename or not file.filename.lower().endswith(".csv"):
        raise HTTPException(status_code=400, detail="Upload a .csv file")
    declared_size = file.size
    if declared_size is not None and declared_size > settings.max_upload_bytes:
        raise HTTPException(status_code=413, detail="CSV is too large")

    try:
        payload = file.file.read(settings.max_upload_bytes + 1)
        if len(payload) > settings.max_upload_bytes:
            raise HTTPException(status_code=413, detail="CSV is too large")
        text = payload.decode("utf-8-sig")
    except UnicodeDecodeError as error:
        raise HTTPException(status_code=400, detail="CSV must be UTF-8 encoded") from error

    rows = csv.DictReader(io.StringIO(text))
    if not rows.fieldnames:
        raise HTTPException(status_code=400, detail="CSV must contain a header row")

    headers = {header.strip().lower() for header in rows.fieldnames if header}
    id_column = next((column for column in ("cow_id", "tag_id", "animal_id", "id") if column in headers), None)
    if id_column is None or "name" not in headers:
        raise HTTPException(
            status_code=400,
            detail="CSV must contain name and cow_id (or tag_id/animal_id) columns",
        )

    def value(row: dict[str, str | None], *names: str) -> str | None:
        normalized = {key.strip().lower(): (item or "").strip() for key, item in row.items() if key}
        for name in names:
            if normalized.get(name):
                return normalized[name]
        return None

    imported: list[Cow] = []
    seen_ids: set[str] = set()
    for row_number, row in enumerate(rows, start=2):
        if row_number > 1002:
            raise HTTPException(status_code=400, detail="CSV is limited to 1,000 cows per import")
        tag_id = value(row, id_column)
        name = value(row, "name")
        if not tag_id or not name:
            raise HTTPException(status_code=400, detail=f"Row {row_number} needs cow_id and name")
        normalized_id = tag_id.casefold()
        if normalized_id in seen_ids:
            raise HTTPException(status_code=400, detail=f"Duplicate cow ID on row {row_number}: {tag_id}")
        seen_ids.add(normalized_id)

        dob = value(row, "date_of_birth", "dob")
        parsed_dob = None
        if dob:
            try:
                parsed_dob = date.fromisoformat(dob)
            except ValueError as error:
                raise HTTPException(status_code=400, detail=f"Invalid date on row {row_number}: {dob}") from error

        lactation = value(row, "lactation_number", "lactation")
        try:
            parsed_lactation = int(lactation) if lactation else None
        except ValueError as error:
            raise HTTPException(status_code=400, detail=f"Invalid lactation number on row {row_number}") from error

        imported.append(Cow(
            farm_id=farm_id,
            tag_id=tag_id,
            name=name,
            breed=value(row, "breed"),
            date_of_birth=parsed_dob,
            lactation_number=parsed_lactation,
            basic_health_status=value(row, "basic_health_status", "health_status", "health") or "Healthy",
            photo_url=value(row, "photo_url", "photo"),
        ))

    if not imported:
        raise HTTPException(status_code=400, detail="CSV contains no cow rows")

    if replace_existing:
        existing_ids = [cow.id for cow in db.query(Cow).filter(Cow.farm_id == farm_id).all()]
        if existing_ids:
            prediction_ids = [row[0] for row in db.query(Prediction.id).filter(Prediction.cow_id.in_(existing_ids)).all()]
            if prediction_ids:
                db.query(PredictionFactor).filter(PredictionFactor.prediction_id.in_(prediction_ids)).delete(synchronize_session=False)
            db.query(Alert).filter(Alert.cow_id.in_(existing_ids)).delete(synchronize_session=False)
            db.query(Prediction).filter(Prediction.cow_id.in_(existing_ids)).delete(synchronize_session=False)
            db.query(SensorReading).filter(SensorReading.cow_id.in_(existing_ids)).delete(synchronize_session=False)
            db.query(MilkingSession).filter(MilkingSession.cow_id.in_(existing_ids)).delete(synchronize_session=False)
            db.query(HealthRecord).filter(HealthRecord.cow_id.in_(existing_ids)).delete(synchronize_session=False)
            db.query(Cow).filter(Cow.id.in_(existing_ids)).delete(synchronize_session=False)

    db.add_all(imported)
    db.commit()
    for cow in imported:
        db.refresh(cow)
    return CowImportOut(imported=len(imported), replaced_existing=replace_existing, cows=imported)


@router.get("/cows/{cow_id}", response_model=CowOut)
def get_cow(
    cow_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return _get_owned_cow(cow_id, user, db)


@router.get("/cows/by-tag/{tag_id}", response_model=CowOut)
def get_cow_by_external_id(
    tag_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Look up a cow using the unique ID supplied by the CSV or ear-tag."""
    farm_id = _require_farm(user)
    cow = (
        db.query(Cow)
        .filter(Cow.farm_id == farm_id, Cow.tag_id.ilike(tag_id.strip()))
        .first()
    )
    if cow is None:
        raise HTTPException(status_code=404, detail="No cow found for this ID")
    return cow


@router.patch("/cows/{cow_id}", response_model=CowOut)
def update_cow(
    cow_id: int,
    req: CowUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    cow = _get_owned_cow(cow_id, user, db)
    for k, v in req.model_dump(exclude_unset=True).items():
        setattr(cow, k, v)
    db.commit()
    db.refresh(cow)
    return cow


# ----- Health records -----
@router.post("/cows/{cow_id}/health-records", response_model=HealthRecordOut)
def add_health_record(
    cow_id: int,
    req: HealthRecordCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _get_owned_cow(cow_id, user, db)
    data = req.model_dump(exclude_unset=True)
    record = HealthRecord(cow_id=cow_id, **data)
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get("/cows/{cow_id}/health-records", response_model=list[HealthRecordOut])
def list_health_records(
    cow_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _get_owned_cow(cow_id, user, db)
    return (
        db.query(HealthRecord)
        .filter(HealthRecord.cow_id == cow_id)
        .order_by(HealthRecord.date.desc())
        .all()
    )


# ----- Scan cow -> start a milking session -----
@router.post("/cows/scan", response_model=SessionOut)
@router.post("/milking-sessions", response_model=SessionOut)
def scan_cow(
    req: ScanCowRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    farm_id = _require_farm(user)
    cow = (
        db.query(Cow)
        .filter(Cow.farm_id == farm_id, Cow.tag_id.ilike(req.tag_id.strip()))
        .first()
    )
    if cow is None:
        raise HTTPException(status_code=404, detail="No cow with that tag on your farm")

    session = MilkingSession(cow_id=cow.id, sensor_id=req.sensor_id)
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


@router.get("/milking-sessions/{session_id}", response_model=SessionOut)
def get_milking_session(
    session_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    session = db.get(MilkingSession, session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Milking session not found")
    cow = _get_owned_cow(session.cow_id, user, db)
    if cow.farm_id != user.farm_id:
        raise HTTPException(status_code=404, detail="Milking session not found")
    return session


@router.post("/milking-sessions/{session_id}/complete", response_model=SessionOut)
def complete_milking_session(
    session_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Close a session once its readings have been uploaded."""
    session = db.get(MilkingSession, session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Milking session not found")
    _get_owned_cow(session.cow_id, user, db)
    if session.ended_at is None:
        session.ended_at = datetime.now(UTC)
        db.commit()
        db.refresh(session)
    return session
