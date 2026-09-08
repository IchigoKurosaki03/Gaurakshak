"""Auth helpers: JWT creation/verification + the current-user dependency.

Demo-grade OTP: for the hackathon the OTP is fixed ("123456") so you can log in
without an SMS gateway. In production, integrate a real SMS OTP provider and
NEVER ship a hardcoded OTP. See SECURITY.md.
"""
from datetime import UTC, datetime, timedelta

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from .config import settings
from .database import get_db
from .models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/verify-otp", auto_error=True)

# DEMO ONLY — replace with a real SMS OTP flow in production.
DEMO_OTP = "123456"


def create_access_token(user_id: int) -> str:
    issued_at = datetime.now(UTC)
    expire = issued_at + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {"sub": str(user_id), "iat": issued_at, "exp": expire, "type": "access"}
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    cred_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
        user_id = payload.get("sub")
        if user_id is None or payload.get("type") != "access":
            raise cred_error
    except JWTError:
        raise cred_error

    try:
        user = db.get(User, int(user_id))
    except (TypeError, ValueError):
        raise cred_error
    if user is None:
        raise cred_error
    return user
