"""Mastitis risk predictor.

PHASE 1 (now): rule-based mock. Deterministic-ish, believable for a demo.
PHASE 2 (later): load a trained XGBoost model and call model.predict_proba(...).
PHASE 3 (future): same, but trained/calibrated on Indian farm data.

The rest of the app ONLY calls `predict_risk(features)` and reads the returned
dataclass. Swapping the body of this function must not change that contract.

IMPORTANT: output is an early-warning RISK ESTIMATE, never a medical diagnosis.
"""
from dataclasses import dataclass, field

MODEL_VERSION = "mock-rule-v1"


@dataclass
class RiskFeatures:
    """What the predictor needs. Values may be None when a sensor is absent."""
    history_count: int = 0
    milk_yield: float | None = None
    milk_conductivity: float | None = None
    milk_temperature: float | None = None
    body_surface_temperature: float | None = None
    activity: float | None = None
    # trend context (change vs the cow's own recent baseline)
    yield_change: float | None = None          # negative = dropping
    conductivity_change: float | None = None    # positive = rising
    activity_change: float | None = None         # negative = dropping


@dataclass
class RiskResult:
    risk_score: float
    risk_level: str
    trend: str
    contributing_factors: list[str] = field(default_factory=list)
    model_version: str = MODEL_VERSION


# Rough reference bands for healthy Indian dairy cattle (demo heuristics only,
# NOT clinically validated). Replaced entirely once the real model exists.
_CONDUCTIVITY_HIGH = 5.5   # mS/cm — elevated conductivity is a classic mastitis signal
_MILK_TEMP_HIGH = 39.0     # deg C
_BODY_TEMP_HIGH = 39.5     # deg C
_ACTIVITY_LOW = 40.0       # index — lethargy


def predict_risk(f: RiskFeatures) -> RiskResult:
    """Return a mastitis risk estimate from current + trend features."""
    # Honesty guard: with no current sensor signal at all there is nothing to
    # assess. We must NOT fall through to a 0.0 score / "Low" — that would tell
    # the farmer a cow is healthy when we simply have no readings for her yet.
    if f.history_count < 2 or all(
        v is None
        for v in (
            f.milk_yield,
            f.milk_conductivity,
            f.milk_temperature,
            f.body_surface_temperature,
            f.activity,
        )
    ):
        return RiskResult(
            risk_score=0.0,
            risk_level="Insufficient",
            trend="Unknown",
            contributing_factors=["Not enough sensor readings yet to estimate risk"],
            model_version=MODEL_VERSION,
        )

    score = 0.0
    factors: list[str] = []

    # --- Conductivity: strongest single mock signal ---
    if f.milk_conductivity is not None and f.milk_conductivity >= _CONDUCTIVITY_HIGH:
        score += 0.30
        factors.append("Milk conductivity increasing")
    if f.conductivity_change is not None and f.conductivity_change > 0.3:
        score += 0.15
        if "Milk conductivity increasing" not in factors:
            factors.append("Milk conductivity increasing")

    # --- Milk yield dropping ---
    if f.yield_change is not None and f.yield_change < -0.5:
        score += 0.20
        factors.append("Milk yield decreasing")

    # --- Temperatures elevated ---
    if f.milk_temperature is not None and f.milk_temperature >= _MILK_TEMP_HIGH:
        score += 0.12
        factors.append("Milk temperature elevated")
    if f.body_surface_temperature is not None and f.body_surface_temperature >= _BODY_TEMP_HIGH:
        score += 0.10
        factors.append("Body temperature elevated")

    # --- Activity / behaviour ---
    if f.activity is not None and f.activity <= _ACTIVITY_LOW:
        score += 0.10
        factors.append("Activity decreasing")
    if f.activity_change is not None and f.activity_change < -10:
        score += 0.08
        if "Activity decreasing" not in factors:
            factors.append("Activity decreasing")

    score = round(min(score, 0.99), 2)

    if score >= 0.66:
        level = "High"
    elif score >= 0.33:
        level = "Medium"
    else:
        level = "Low"

    # Trend from the change signals (falls back to Normal)
    rising = (f.conductivity_change or 0) > 0.2 or (f.yield_change or 0) < -0.5
    falling = (f.conductivity_change or 0) < -0.2 and (f.yield_change or 0) > 0
    trend = "Increasing" if rising else ("Decreasing" if falling else "Normal")

    if not factors:
        factors.append("No significant changes detected")

    return RiskResult(
        risk_score=score,
        risk_level=level,
        trend=trend,
        contributing_factors=factors,
        model_version=MODEL_VERSION,
    )
