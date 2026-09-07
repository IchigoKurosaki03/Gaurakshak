"""Phone + OTP login. Demo OTP is fixed; swap for a real SMS provider later."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db
from ..models import User
from ..schemas import LoginRequest, VerifyOtpRequest, TokenResponse
from ..security import create_access_token, DEMO_OTP

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
def login(req: LoginRequest):
    # In production: generate and deliver an OTP through an SMS provider.
    if not settings.demo_auth_enabled:
        raise HTTPException(status_code=503, detail="SMS OTP provider is not configured")
    return {"message": "Demo OTP generated", "demo_otp": DEMO_OTP}


@router.post("/verify-otp", response_model=TokenResponse)
def verify_otp(req: VerifyOtpRequest, db: Session = Depends(get_db)):
    if not settings.demo_auth_enabled:
        raise HTTPException(status_code=503, detail="SMS OTP provider is not configured")
    if req.otp != DEMO_OTP:
        raise HTTPException(status_code=401, detail="Invalid OTP")

    user = db.query(User).filter(User.phone == req.phone).first()
    if user is None:
        # first login creates the farmer account
        user = User(name="Farmer", phone=req.phone, role="farmer")
        db.add(user)
        db.commit()
        db.refresh(user)

    token = create_access_token(user.id)
    return TokenResponse(access_token=token, user_id=user.id, farm_id=user.farm_id)
