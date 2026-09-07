"""GauRakshak FastAPI application entry point.

Run (from the backend/ folder):
    uvicorn app.main:app --reload
Then open http://localhost:8000/docs
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from .config import settings
from .database import Base, engine
from . import models  # noqa: F401  (ensures models are registered before create_all)
from .routers import auth, farms, cows, sensors, predictions, alerts, assistant

if settings.app_env.lower() in {"production", "prod"}:
    if settings.jwt_secret_key == "dev-only-insecure-secret-change-me":
        raise RuntimeError("JWT_SECRET_KEY must be set in production")
    if settings.demo_auth_enabled:
        raise RuntimeError("DEMO_AUTH_ENABLED must be false in production")

# For the hackathon we auto-create tables. In production use Alembic migrations.
Base.metadata.create_all(bind=engine)
# ``create_all`` does not retrofit constraints into a pre-existing SQLite
# database. Keep the local demo database aligned with the model constraint.
if settings.database_url.startswith("sqlite"):
    with engine.begin() as connection:
        connection.execute(text(
            "CREATE UNIQUE INDEX IF NOT EXISTS ix_cows_farm_tag_unique "
            "ON cows (farm_id, tag_id)"
        ))

app = FastAPI(
    title="GauRakshak API",
    version="0.1.0",
    description="Early mastitis risk prediction & cattle health monitoring.",
)

# CORS — restricted to configured origins (never use ['*'] with credentials).
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_origin_regex=settings.cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(farms.router)
app.include_router(cows.router)
app.include_router(sensors.router)
app.include_router(predictions.router)
app.include_router(alerts.router)
app.include_router(assistant.router)


@app.get("/", tags=["health"])
def root():
    return {"app": "GauRakshak", "status": "ok", "env": settings.app_env}


@app.get("/health", tags=["health"])
def health():
    return {"status": "healthy"}
