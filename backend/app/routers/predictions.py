"""Prediction endpoint. Pulls the cow's recent readings, builds features,
calls the (currently mock) predictor, stores the result + factors, and
raises an alert on Medium/High risk.

Swapping mock -> XGBoost happens inside predictor.py only; this file and the
response shape (PredictionOut) stay unchanged.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Cow, MilkingSession, SensorReading, Prediction, PredictionFactor, Alert, User
from ..schemas import PredictionRequest, PredictionOut
from ..security import get_current_user
from ..ml.predictor import predict_risk, RiskFeatures

router = APIRouter(tags=["predictions"])


def _build_features(cow_id: int, db: Session) -> RiskFeatures:
    """Latest reading + change vs the mean of the prior readings."""
    readings = (
        db.query(SensorReading)
        .filter(SensorReading.cow_id == cow_id)
        .order_by(SensorReading.timestamp.desc())
        .limit(10)
        .all()
    )
    if not readings:
        return RiskFeatures()

    latest = readings[0]
    prior = readings[1:]

    def _mean(attr: str):
        vals = [getattr(r, attr) for r in prior if getattr(r, attr) is not None]
        return sum(vals) / len(vals) if vals else None

    def _change(cur, base):
        return (cur - base) if (cur is not None and base is not None) else None

    return RiskFeatures(
        history_count=len(readings),
        milk_yield=latest.milk_yield,
        milk_conductivity=latest.milk_conductivity,
        milk_temperature=latest.milk_temperature,
        body_surface_temperature=latest.body_surface_temperature,
        activity=latest.activity,
        yield_change=_change(latest.milk_yield, _mean("milk_yield")),
        conductivity_change=_change(latest.milk_conductivity, _mean("milk_conductivity")),
        activity_change=_change(latest.activity, _mean("activity")),
    )


@router.post("/predictions", response_model=PredictionOut)
def create_prediction(
    req: PredictionRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    cow = db.get(Cow, req.cow_id)
    if cow is None or cow.farm_id != user.farm_id:
        raise HTTPException(status_code=404, detail="Cow not found")

    if req.session_id is not None:
        session = db.get(MilkingSession, req.session_id)
        if session is None or session.cow_id != cow.id:
            raise HTTPException(status_code=400, detail="Milking session does not belong to this cow")
        if session.ended_at is None:
            raise HTTPException(status_code=400, detail="Complete the milking session before prediction")

    features = _build_features(cow.id, db)
    result = predict_risk(features)

    prediction = Prediction(
        cow_id=cow.id,
        risk_score=result.risk_score,
        risk_level=result.risk_level,
        trend=result.trend,
        model_version=result.model_version,
    )
    db.add(prediction)
    db.commit()
    db.refresh(prediction)

    for factor in result.contributing_factors:
        db.add(PredictionFactor(prediction_id=prediction.id, feature=factor, contribution=0.0))

    # Farmer-friendly alert on elevated risk
    if result.risk_level in ("Medium", "High"):
        msg = (
            f"{cow.name} needs attention. Mastitis risk is {result.risk_level.lower()} "
            f"and {result.trend.lower()}. Check the cow for signs of udder inflammation "
            f"and contact a veterinarian if needed."
        )
        db.add(Alert(
            cow_id=cow.id,
            prediction_id=prediction.id,
            severity=result.risk_level,
            message=msg,
        ))

    db.commit()

    return PredictionOut(
        cow_id=cow.tag_id,
        risk_score=result.risk_score,
        risk_level=result.risk_level,
        trend=result.trend,
        contributing_factors=result.contributing_factors,
        model_version=result.model_version,
    )


@router.get("/cows/{cow_id}/risk", response_model=PredictionOut)
def latest_risk(
    cow_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    cow = db.get(Cow, cow_id)
    if cow is None or cow.farm_id != user.farm_id:
        raise HTTPException(status_code=404, detail="Cow not found")

    prediction = (
        db.query(Prediction)
        .filter(Prediction.cow_id == cow_id)
        .order_by(Prediction.timestamp.desc())
        .first()
    )
    if prediction is None:
        raise HTTPException(status_code=404, detail="No prediction yet for this cow")

    factors = [f.feature for f in prediction.factors]
    return PredictionOut(
        cow_id=cow.tag_id,
        risk_score=prediction.risk_score,
        risk_level=prediction.risk_level,
        trend=prediction.trend,
        contributing_factors=factors,
        model_version=prediction.model_version,
    )
