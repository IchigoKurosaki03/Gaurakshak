"""Alerts list + acknowledge/resolve, scoped to the user's farm."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Alert, Cow, User
from ..schemas import AlertOut, AlertUpdate
from ..security import get_current_user

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.get("", response_model=list[AlertOut])
def list_alerts(
    status: str | None = None,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    q = (
        db.query(Alert)
        .join(Cow, Alert.cow_id == Cow.id)
        .filter(Cow.farm_id == user.farm_id)
    )
    if status:
        q = q.filter(Alert.status == status)
    return q.order_by(Alert.created_at.desc()).all()


@router.patch("/{alert_id}", response_model=AlertOut)
def update_alert(
    alert_id: int,
    req: AlertUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    alert = (
        db.query(Alert)
        .join(Cow, Alert.cow_id == Cow.id)
        .filter(Alert.id == alert_id, Cow.farm_id == user.farm_id)
        .first()
    )
    if alert is None:
        raise HTTPException(status_code=404, detail="Alert not found")
    alert.status = req.status
    db.commit()
    db.refresh(alert)
    return alert
