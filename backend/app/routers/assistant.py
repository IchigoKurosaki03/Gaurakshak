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
import httpx
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Cow, Prediction, User
from ..schemas import ChatRequest, ChatResponse
from ..security import get_current_user
from ..config import settings

router = APIRouter(prefix="/assistant", tags=["assistant"])


def _provider_reply(message: str, context: list[str]) -> str | None:
    """Use an optional OpenAI-compatible provider without logging its key."""
    if not (settings.gausaathi_llm_api_key and settings.gausaathi_llm_base_url
            and settings.gausaathi_llm_model):
        return None
    system = (
        "You are GauSaathi, a concise dairy-farm early-warning helper. "
        "Use only supplied farm context. Do not diagnose or prescribe. "
        "Recommend a veterinarian for urgent concerns. Reply in the farmer's "
        "language and keep the answer under 110 words."
    )
    try:
        response = httpx.post(
            f"{settings.gausaathi_llm_base_url.rstrip('/')}/chat/completions",
            headers={"Authorization": f"Bearer {settings.gausaathi_llm_api_key}"},
            json={
                "model": settings.gausaathi_llm_model,
                "messages": [
                    {"role": "system", "content": system},
                    {"role": "user", "content": f"Farm context: {context or ['No selected cow.']}\n\nQuestion: {message}"},
                ],
                "temperature": 0.2,
                "max_tokens": 220,
            },
            timeout=12,
        )
        response.raise_for_status()
        content = response.json().get("choices", [{}])[0].get("message", {}).get("content", "")
        return content.strip() or None
    except (httpx.HTTPError, KeyError, TypeError, ValueError):
        return None

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

    generated = _provider_reply(req.message, context)
    if generated:
        return ChatResponse(
            reply=f"{generated}\n\n{_DISCLAIMER}",
            used_context=context,
        )

    # Grounded fallback: it works offline or when a provider fails, without
    # inventing clinical facts or making a diagnosis.
    if context:
        question = req.message.casefold()
        details = " ".join(context)
        if any(word in question for word in ("milk", "yield", "production", "conductivity")):
            guidance = "Review the latest yield and conductivity readings in Milk; compare them with this cow's usual pattern."
        elif any(word in question for word in ("risk", "attention", "healthy", "mastitis", "symptom")):
            guidance = "Review the listed risk factors, check the udder and appetite, and contact a veterinarian for persistent or urgent symptoms."
        elif any(word in question for word in ("sensor", "node", "wearable", "temperature", "activity")):
            guidance = "Open Devices or Cow health to review the latest wearable reading and confirm that the node is reporting."
        elif any(word in question for word in ("who", "which", "cow", "herd")):
            guidance = "Use Cows to compare the herd, then open the cow profile for its timeline and latest records."
        else:
            guidance = "Open the relevant Health or Milk screen for the latest chart and record details."
        reply = f"{details} {guidance} {_DISCLAIMER}"
    else:
        reply = (
            "I can explain your cows' health, milk and risk once you pick a cow. "
            + _DISCLAIMER
        )

    return ChatResponse(reply=reply, used_context=context)
