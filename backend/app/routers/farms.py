"""Farm setup. A user creating a farm is linked to it."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Farm, User
from ..schemas import FarmCreate, FarmOut
from ..security import get_current_user

router = APIRouter(prefix="/farms", tags=["farms"])


@router.post("", response_model=FarmOut)
def create_farm(
    req: FarmCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    farm = Farm(name=req.name, location=req.location)
    db.add(farm)
    db.commit()
    db.refresh(farm)

    # link the creating user to this farm
    user.farm_id = farm.id
    db.commit()
    return farm


@router.get("/{farm_id}", response_model=FarmOut)
def get_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    farm = db.get(Farm, farm_id)
    if farm is None:
        raise HTTPException(status_code=404, detail="Farm not found")
    if user.farm_id != farm.id:
        raise HTTPException(status_code=403, detail="Not your farm")
    return farm
