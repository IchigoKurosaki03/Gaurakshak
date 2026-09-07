"""Pydantic schemas — the FROZEN API contract.

The Flutter app depends on these shapes, not on any model internals.
Swapping the mock predictor for real XGBoost must NOT change these.
"""
from datetime import datetime, date as dt_date
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


# ---------- Auth ----------
class LoginRequest(BaseModel):
    phone: str = Field(..., min_length=8, max_length=20)


class VerifyOtpRequest(BaseModel):
    phone: str
    otp: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    farm_id: int | None = None


# ---------- Farm ----------
class FarmCreate(BaseModel):
    name: str
    location: str | None = None


class FarmOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    location: str | None
    created_at: datetime


# ---------- Cow ----------
class CowCreate(BaseModel):
    tag_id: str
    name: str
    breed: str | None = None
    date_of_birth: dt_date | None = None
    lactation_number: int | None = None
    basic_health_status: str = "Healthy"
    photo_url: str | None = None


class CowUpdate(BaseModel):
    name: str | None = None
    breed: str | None = None
    date_of_birth: dt_date | None = None
    lactation_number: int | None = None
    basic_health_status: str | None = None
    photo_url: str | None = None


class CowOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    farm_id: int
    tag_id: str
    name: str
    breed: str | None
    date_of_birth: dt_date | None
    lactation_number: int | None
    basic_health_status: str
    photo_url: str | None


class CowImportOut(BaseModel):
    imported: int
    replaced_existing: bool
    cows: list[CowOut]


# ---------- Health records ----------
class HealthRecordCreate(BaseModel):
    record_type: str
    date: dt_date | None = None
    notes: str | None = None
    diagnosis: str | None = None
    treatment: str | None = None
    vaccination: str | None = None


class HealthRecordOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    cow_id: int
    record_type: str
    date: dt_date
    notes: str | None
    diagnosis: str | None
    treatment: str | None
    vaccination: str | None


# ---------- Milking / sessions ----------
class ScanCowRequest(BaseModel):
    tag_id: str
    sensor_id: str | None = None


class SessionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    cow_id: int
    sensor_id: str | None
    started_at: datetime
    ended_at: datetime | None


# ---------- Sensor readings (same shape the ESP32 will POST) ----------
class SensorReadingCreate(BaseModel):
    cow_id: int | None = None
    tag_id: str | None = None          # ESP32 may send tag instead of internal id
    session_id: int | None = None
    timestamp: datetime | None = None
    milk_yield: float | None = None
    milk_conductivity: float | None = None
    milk_temperature: float | None = None
    body_surface_temperature: float | None = None
    activity: float | None = None

    @model_validator(mode="after")
    def require_cow_reference(self):
        if self.cow_id is None and not self.tag_id:
            raise ValueError("Provide cow_id or tag_id")
        return self


class SensorReadingOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    cow_id: int
    session_id: int | None
    timestamp: datetime
    milk_yield: float | None
    milk_conductivity: float | None
    milk_temperature: float | None
    body_surface_temperature: float | None
    activity: float | None


# ---------- Predictions (matches API.md example exactly) ----------
class PredictionRequest(BaseModel):
    cow_id: int
    session_id: int | None = None


class PredictionOut(BaseModel):
    cow_id: str
    risk_score: float
    risk_level: str
    trend: str
    contributing_factors: list[str]
    model_version: str = "mock-rule-v1"


# ---------- Alerts ----------
class AlertOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    cow_id: int
    prediction_id: int | None
    created_at: datetime
    severity: str
    message: str
    status: str


class AlertUpdate(BaseModel):
    status: str  # acknowledged | resolved

    @field_validator("status")
    @classmethod
    def validate_status(cls, value: str) -> str:
        normalized = value.lower().strip()
        if normalized not in {"acknowledged", "resolved"}:
            raise ValueError("status must be acknowledged or resolved")
        return normalized


# ---------- GauSaathi ----------
class ChatRequest(BaseModel):
    message: str
    cow_id: int | None = None


class ChatResponse(BaseModel):
    reply: str
    used_context: list[str] = []
