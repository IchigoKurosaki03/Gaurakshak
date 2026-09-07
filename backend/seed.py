"""Seed demo data: one farm, a farmer, and a few cows with readings.

Run from the backend/ folder:  python seed.py
Safe to re-run — it clears and rebuilds the demo rows.
"""
from datetime import UTC, datetime, timedelta

from app.database import Base, engine, SessionLocal
from app.models import Alert, Cow, Farm, HealthRecord, MilkingSession, Prediction, PredictionFactor, SensorReading, User

Base.metadata.create_all(bind=engine)


def run():
    db = SessionLocal()
    try:
        # wipe (demo only)
        # Delete children before parents so this works with SQLite foreign keys
        # enabled and with PostgreSQL/Supabase.
        for model in (PredictionFactor, Alert, Prediction, SensorReading, MilkingSession, HealthRecord, Cow, User, Farm):
            db.query(model).delete()
        db.commit()

        farm = Farm(name="Green Valley Dairy", location="Pune, Maharashtra")
        db.add(farm)
        db.commit()
        db.refresh(farm)

        db.add(User(name="Ramesh", phone="9999999999", role="farmer", farm_id=farm.id))
        db.commit()

        cows = [
            Cow(farm_id=farm.id, tag_id="COW-024", name="Gauri", breed="Gir",
                lactation_number=3, basic_health_status="Monitor"),
            Cow(farm_id=farm.id, tag_id="COW-011", name="Lakshmi", breed="Sahiwal",
                lactation_number=2, basic_health_status="Healthy"),
            Cow(farm_id=farm.id, tag_id="COW-007", name="Nandini", breed="Gir",
                lactation_number=4, basic_health_status="Healthy"),
        ]
        db.add_all(cows)
        db.commit()
        for c in cows:
            db.refresh(c)

        gauri = cows[0]
        now = datetime.now(UTC)
        # Gauri: rising conductivity + dropping yield over 5 sessions (looks risky)
        series = [
            (12.0, 4.8, 38.2, 39.0, 62),
            (11.6, 5.0, 38.4, 39.1, 58),
            (11.0, 5.3, 38.6, 39.2, 52),
            (10.2, 5.6, 38.9, 39.4, 45),
            (9.3, 5.9, 39.1, 39.6, 38),
        ]
        for i, (y, c, mt, bt, act) in enumerate(series):
            db.add(SensorReading(
                cow_id=gauri.id,
                timestamp=now - timedelta(days=len(series) - i),
                milk_yield=y, milk_conductivity=c, milk_temperature=mt,
                body_surface_temperature=bt, activity=act,
            ))

        # Healthy cow readings for Lakshmi
        for i in range(5):
            db.add(SensorReading(
                cow_id=cows[1].id,
                timestamp=now - timedelta(days=5 - i),
                milk_yield=10.0, milk_conductivity=4.5, milk_temperature=38.1,
                body_surface_temperature=38.8, activity=70,
            ))

        db.commit()
        print("Seeded: farm", farm.id, "| cows:", [c.tag_id for c in cows])
        print("Login demo -> phone 9999999999, OTP 123456")
    finally:
        db.close()


if __name__ == "__main__":
    run()
