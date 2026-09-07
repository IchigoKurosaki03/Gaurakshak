"""GauSaathi assistant endpoint.

DESIGN RULE (see PRD + SECURITY.md):
- The LLM API key lives ONLY here on the backend, from settings. Never in the app.
- The model receives ONLY authorized, scoped context for the current user's
  farm — never the whole database.
- GauSaathi must NOT claim to be a vet, diagnose, or prescribe medication.

For the demo this returns a grounded, rule-based reply built from real cow data,
so it works with no LLM key. To go live, send `context` + `req.message` to the
LLM using settings.gausaathi_llm_api_key and keep the same response shape.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Cow, Prediction, User
from ..schemas import ChatRequest, ChatResponse
from ..security import get_current_user

router = APIRouter(prefix="/assistant", tags=["assistant"])

_DISCLAIMER = ("I'm GauSaathi, a helper — not a veterinarian. "
               "For anything serious, please contact a vet.")


def _authorized_context(req: ChatRequest, user: User, db: Session) -> list[str]:
    """Only this farm's data. Never expose other farms or raw tables."""
    context: list[str] = []
    if req.cow_id is not None:
        cow = db.get(Cow, req.cow_id)
        if cow and cow.farm_id == user.farm_id:
            context.append(f"Cow {cow.name} (tag {cow.tag_id}), health {cow.basic_health_status}.")
            latest = (
                db.query(Prediction)
                .filter(Prediction.cow_id == cow.id)
                .order_by(Prediction.timestamp.desc())
                .first()
            )
            if latest:
                factors = ", ".join(f.feature for f in latest.factors) or "no notable factors"
                context.append(
                    f"Latest risk: {latest.risk_level} ({latest.risk_score}), "
                    f"trend {latest.trend}. Factors: {factors}."
                )
    return context


@router.post("/chat", response_model=ChatResponse)
def chat(
    req: ChatRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    context = _authorized_context(req, user, db)

    # --- Demo reply (no LLM key needed). Replace with an LLM call for production. ---
    if context:
        reply = (
            "Here's what I can see. " + " ".join(context) +
            " If the risk is medium or high, check the udder and watch milk quality. "
            + _DISCLAIMER
        )
    else:
        reply = (
            "I can explain your cows' health, milk and risk once you pick a cow. "
            + _DISCLAIMER
        )

    return ChatResponse(reply=reply, used_context=context)
