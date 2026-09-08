"""Pydantic schemas — the FROZEN API contract.

The Flutter app depends on these shapes, not on any model internals.
Swapping the mock predictor for real XGBoost must NOT change these.
"""
from datetime import datetime, date as dt_date
import re
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


def _safe_text(value: str, field_name: str, maximum: int = 160) -> str:
    cleaned = value.strip()
    if not cleaned or len(cleaned) > maximum or any(ord(char) < 32 for char in cleaned):
        raise ValueError(f"{field_name} is invalid")
    return cleaned


# ---------- Auth ----------
class LoginRequest(BaseModel):
    phone: str = Field(..., min_length=8, max_length=20, pattern=r"^\+?[0-9]{8,15}$")


class VerifyOtpRequest(BaseModel):
    phone: str = Field(..., min_length=8, max_length=20, pattern=r"^\+?[0-9]{8,15}$")
    otp: str = Field(..., min_length=6, max_length=8, pattern=r"^[0-9]+$")


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    farm_id: int | None = None


# ---------- Farm ----------
class FarmCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=120)
    location: str | None = Field(default=None, max_length=160)

    @field_validator("name", "location")
    @classmethod
    def clean_farm_text(cls, value: str | None, info) -> str | None:
        return _safe_text(value, info.field_name) if value is not None else None


class FarmOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    location: str | None
    created_at: datetime


# ---------- Cow ----------
class CowCreate(BaseModel):
    tag_id: str = Field(..., min_length=2, max_length=40, pattern=r"^[A-Za-z0-9][A-Za-z0-9 _-]*$")
    name: str = Field(..., min_length=1, max_length=100)
    breed: str | None = Field(default=None, max_length=80)
    date_of_birth: dt_date | None = None
    lactation_number: int | None = Field(default=None, ge=0, le=30)
    basic_health_status: str = "Healthy"
    photo_url: str | None = Field(default=None, max_length=500)

    @field_validator("tag_id", "name", "breed", "basic_health_status")
    @classmethod
    def clean_cow_text(cls, value: str | None, info) -> str | None:
        return _safe_text(value, info.field_name) if value is not None else None


class CowUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    breed: str | None = Field(default=None, max_length=80)
    date_of_birth: dt_date | None = None
    lactation_number: int | None = Field(default=None, ge=0, le=30)
    basic_health_status: str | None = None
    photo_url: str | None = Field(default=None, max_length=500)

    @field_validator("name", "breed", "basic_health_status")
    @classmethod
    def clean_update_text(cls, value: str | None, info) -> str | None:
        return _safe_text(value, info.field_name) if value is not None else None


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
    record_type: str = Field(..., min_length=2, max_length=80)
    date: dt_date | None = None
    notes: str | None = Field(default=None, max_length=1000)
    diagnosis: str | None = Field(default=None, max_length=300)
    treatment: str | None = Field(default=None, max_length=300)
    vaccination: str | None = Field(default=None, max_length=300)

    @field_validator("record_type", "notes", "diagnosis", "treatment", "vaccination")
    @classmethod
    def clean_record_text(cls, value: str | None, info) -> str | None:
        return _safe_text(value, info.field_name, 1000) if value is not None else None


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
    tag_id: str = Field(..., min_length=2, max_length=40, pattern=r"^[A-Za-z0-9][A-Za-z0-9 _-]*$")
    sensor_id: str | None = Field(default=None, max_length=80, pattern=r"^[A-Za-z0-9][A-Za-z0-9 _-]*$")


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
        if all(getattr(self, name) is None for name in (
            "milk_yield", "milk_conductivity", "milk_temperature",
            "body_surface_temperature", "activity",
        )):
            raise ValueError("Provide at least one sensor measurement")
        limits = {
            "milk_yield": (0, 100),
            "milk_conductivity": (0, 20),
            "milk_temperature": (25, 50),
            "body_surface_temperature": (20, 50),
            "activity": (0, 100),
        }
        for field_name, (minimum, maximum) in limits.items():
            value = getattr(self, field_name)
            if value is not None and not minimum <= value <= maximum:
                raise ValueError(
                    f"{field_name} must be between {minimum} and {maximum}"
                )
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


class SensorNodeStatusOut(BaseModel):
    sensor_id: str
    cow_id: int
    cow_tag: str
    last_seen_at: datetime
    reading_count: int
    status: str  # online | idle


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
    message: str = Field(..., min_length=1, max_length=800)
    cow_id: int | None = None

    @field_validator("message")
    @classmethod
    def clean_message(cls, value: str) -> str:
        return _safe_text(value, "message", 800)


class ChatResponse(BaseModel):
    reply: str
    used_context: list[str] = []
