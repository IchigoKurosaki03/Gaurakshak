"""SQLAlchemy models — mirrors DATABASE.md.

Every sensor reading carries a timestamp and cow/session association.
"""
from datetime import UTC, datetime, date

from sqlalchemy import String, Integer, Float, ForeignKey, DateTime, Date, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def _now() -> datetime:
    return datetime.now(UTC)


class Farm(Base):
    __tablename__ = "farms"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120))
    location: Mapped[str | None] = mapped_column(String(200), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=_now)

    cows: Mapped[list["Cow"]] = relationship(back_populates="farm")
    users: Mapped[list["User"]] = relationship(back_populates="farm")


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120))
    phone: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    role: Mapped[str] = mapped_column(String(20), default="farmer")  # farmer | vet | manager
    farm_id: Mapped[int | None] = mapped_column(ForeignKey("farms.id"), nullable=True)

    farm: Mapped["Farm | None"] = relationship(back_populates="users")


class Cow(Base):
    __tablename__ = "cows"
    __table_args__ = (UniqueConstraint("farm_id", "tag_id", name="uq_cows_farm_tag"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    farm_id: Mapped[int] = mapped_column(ForeignKey("farms.id"), index=True)
    tag_id: Mapped[str] = mapped_column(String(50), index=True)  # QR/RFID/ear-tag
    name: Mapped[str] = mapped_column(String(80))
    breed: Mapped[str | None] = mapped_column(String(80), nullable=True)
    date_of_birth: Mapped[date | None] = mapped_column(Date, nullable=True)
    lactation_number: Mapped[int | None] = mapped_column(Integer, nullable=True)
    basic_health_status: Mapped[str] = mapped_column(String(20), default="Healthy")
    photo_url: Mapped[str | None] = mapped_column(String(300), nullable=True)

    farm: Mapped["Farm"] = relationship(back_populates="cows")
    health_records: Mapped[list["HealthRecord"]] = relationship(back_populates="cow")
    readings: Mapped[list["SensorReading"]] = relationship(back_populates="cow")
    predictions: Mapped[list["Prediction"]] = relationship(back_populates="cow")


class HealthRecord(Base):
    __tablename__ = "health_records"
    id: Mapped[int] = mapped_column(primary_key=True)
    cow_id: Mapped[int] = mapped_column(ForeignKey("cows.id"), index=True)
    record_type: Mapped[str] = mapped_column(String(40))  # mastitis | vaccination | calving | note
    date: Mapped[date] = mapped_column(Date, default=lambda: _now().date())
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    diagnosis: Mapped[str | None] = mapped_column(String(200), nullable=True)
    treatment: Mapped[str | None] = mapped_column(String(200), nullable=True)
    vaccination: Mapped[str | None] = mapped_column(String(200), nullable=True)

    cow: Mapped["Cow"] = relationship(back_populates="health_records")


class MilkingSession(Base):
    __tablename__ = "milking_sessions"
    id: Mapped[int] = mapped_column(primary_key=True)
    cow_id: Mapped[int] = mapped_column(ForeignKey("cows.id"), index=True)
    sensor_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime, default=_now)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    readings: Mapped[list["SensorReading"]] = relationship(back_populates="session")


class SensorReading(Base):
    __tablename__ = "sensor_readings"
    id: Mapped[int] = mapped_column(primary_key=True)
    cow_id: Mapped[int] = mapped_column(ForeignKey("cows.id"), index=True)
    session_id: Mapped[int | None] = mapped_column(ForeignKey("milking_sessions.id"), nullable=True)
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=_now, index=True)
    milk_yield: Mapped[float | None] = mapped_column(Float, nullable=True)          # litres
    milk_conductivity: Mapped[float | None] = mapped_column(Float, nullable=True)   # mS/cm
    milk_temperature: Mapped[float | None] = mapped_column(Float, nullable=True)    # deg C
    body_surface_temperature: Mapped[float | None] = mapped_column(Float, nullable=True)  # deg C
    activity: Mapped[float | None] = mapped_column(Float, nullable=True)            # index

    cow: Mapped["Cow"] = relationship(back_populates="readings")
    session: Mapped["MilkingSession | None"] = relationship(back_populates="readings")


class Prediction(Base):
    __tablename__ = "predictions"
    id: Mapped[int] = mapped_column(primary_key=True)
    cow_id: Mapped[int] = mapped_column(ForeignKey("cows.id"), index=True)
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=_now, index=True)
    risk_score: Mapped[float] = mapped_column(Float)
    risk_level: Mapped[str] = mapped_column(String(10))  # Low | Medium | High
    trend: Mapped[str] = mapped_column(String(12))       # Normal | Increasing | Decreasing
    model_version: Mapped[str] = mapped_column(String(30), default="mock-rule-v1")

    cow: Mapped["Cow"] = relationship(back_populates="predictions")
    factors: Mapped[list["PredictionFactor"]] = relationship(back_populates="prediction")


class PredictionFactor(Base):
    __tablename__ = "prediction_factors"
    id: Mapped[int] = mapped_column(primary_key=True)
    prediction_id: Mapped[int] = mapped_column(ForeignKey("predictions.id"), index=True)
    feature: Mapped[str] = mapped_column(String(80))
    contribution: Mapped[float] = mapped_column(Float)

    prediction: Mapped["Prediction"] = relationship(back_populates="factors")


class Alert(Base):
    __tablename__ = "alerts"
    id: Mapped[int] = mapped_column(primary_key=True)
    cow_id: Mapped[int] = mapped_column(ForeignKey("cows.id"), index=True)
    prediction_id: Mapped[int | None] = mapped_column(ForeignKey("predictions.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=_now, index=True)
    severity: Mapped[str] = mapped_column(String(10))  # Low | Medium | High
    message: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(12), default="open")  # open | acknowledged | resolved
