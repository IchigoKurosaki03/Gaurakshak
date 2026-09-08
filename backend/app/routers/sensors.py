"""Sensor-reading ingestion. Same endpoint the real ESP32 will POST to later;
for now the simulator script feeds it. Accepts cow_id OR tag_id.
"""
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Cow, MilkingSession, SensorReading, User
from ..schemas import SensorNodeStatusOut, SensorReadingCreate, SensorReadingOut
from ..security import get_current_user

router = APIRouter(tags=["sensors"])


@router.post("/sensor-readings", response_model=SensorReadingOut)
def ingest_reading(
    req: SensorReadingCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    cow: Cow | None = None
    if req.cow_id is not None:
        cow = db.get(Cow, req.cow_id)
    elif req.tag_id is not None:
        cow = db.query(Cow).filter(
            Cow.farm_id == user.farm_id, Cow.tag_id == req.tag_id
        ).first()

    if cow is None or cow.farm_id != user.farm_id:
        raise HTTPException(status_code=404, detail="Cow not found for this reading")

    if req.session_id is not None:
        session = db.get(MilkingSession, req.session_id)
        if session is None or session.cow_id != cow.id:
            raise HTTPException(
                status_code=400,
                detail="Sensor session does not belong to this cow",
            )
        if session.ended_at is not None:
            raise HTTPException(status_code=400, detail="Milking session is already closed")

    reading = SensorReading(
        cow_id=cow.id,
        session_id=req.session_id,
        timestamp=req.timestamp or datetime.now(UTC),
        milk_yield=req.milk_yield,
        milk_conductivity=req.milk_conductivity,
        milk_temperature=req.milk_temperature,
        body_surface_temperature=req.body_surface_temperature,
        activity=req.activity,
    )
    db.add(reading)
    db.commit()
    db.refresh(reading)
    return reading


@router.get("/cows/{cow_id}/sensor-readings", response_model=list[SensorReadingOut])
def cow_readings(
    cow_id: int,
    limit: int = 50,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    cow = db.get(Cow, cow_id)
    if cow is None or cow.farm_id != user.farm_id:
        raise HTTPException(status_code=404, detail="Cow not found")
    return (
        db.query(SensorReading)
        .filter(SensorReading.cow_id == cow_id)
        .order_by(SensorReading.timestamp.desc())
        .limit(min(limit, 500))
        .all()
    )


@router.get("/sensors/status", response_model=list[SensorNodeStatusOut])
def sensor_status(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Return the latest persisted state for each sensor node in this farm."""
    sessions = (
        db.query(MilkingSession, Cow)
        .join(Cow, Cow.id == MilkingSession.cow_id)
        .filter(Cow.farm_id == user.farm_id, MilkingSession.sensor_id.isnot(None))
        .order_by(MilkingSession.started_at.desc())
        .all()
    )
    now = datetime.now(UTC)
    seen_nodes: set[str] = set()
    nodes: list[SensorNodeStatusOut] = []
    for session, cow in sessions:
        sensor_id = session.sensor_id
        if not sensor_id or sensor_id in seen_nodes:
            continue
        seen_nodes.add(sensor_id)
        latest = (
            db.query(SensorReading)
            .filter(SensorReading.session_id == session.id)
            .order_by(SensorReading.timestamp.desc())
            .first()
        )
        last_seen = latest.timestamp if latest is not None else session.started_at
        if last_seen.tzinfo is None:
            last_seen = last_seen.replace(tzinfo=UTC)
        reading_count = (
            db.query(SensorReading)
            .filter(SensorReading.session_id == session.id)
            .count()
        )
        nodes.append(
            SensorNodeStatusOut(
                sensor_id=sensor_id,
                cow_id=cow.id,
                cow_tag=cow.tag_id,
                last_seen_at=last_seen,
                reading_count=reading_count,
                status="online"
                if session.ended_at is None and now - last_seen <= timedelta(minutes=30)
                else "idle",
            )
        )
    return nodes
