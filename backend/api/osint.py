from typing import Literal
from urllib.parse import urlparse

from fastapi import APIRouter
from pydantic import BaseModel, Field


router = APIRouter(prefix="/osint", tags=["OSINT"])


class OsintRequest(BaseModel):
    target: str = Field(min_length=1, max_length=500)
    target_type: Literal["auto", "username", "email", "phone", "url"] = "auto"


class OsintItem(BaseModel):
    category: str
    label: str
    value: str
    confidence: str


class OsintResponse(BaseModel):
    status: str
    target: str
    target_type: str
    summary: str
    results: list[OsintItem]
    sources: list[str]


def detect_target_type(target: str) -> str:
    value = target.strip()

    if "@" in value and " " not in value:
        return "email"

    if value.startswith(("http://", "https://")):
        return "url"

    digits = "".join(ch for ch in value if ch.isdigit())
    if len(digits) >= 7 and len(digits) >= len(value.replace(" ", "").replace("-", "")) * 0.7:
        return "phone"

    return "username"


def analyze_target(target: str, target_type: str) -> OsintResponse:
    value = target.strip()

    if target_type == "auto":
        target_type = detect_target_type(value)

    results: list[OsintItem] = []
    sources: list[str] = []

    if target_type == "username":
        results.extend(
            [
                OsintItem(
                    category="IDENTITY",
                    label="Username",
                    value=value,
                    confidence="HIGH",
                ),
                OsintItem(
                    category="DISCOVERY",
                    label="Public profile search",
                    value=f"Search public web sources for: {value}",
                    confidence="PENDING",
                ),
            ]
        )
        sources.append("Public web search")

    elif target_type == "email":
        domain = value.split("@", 1)[1] if "@" in value else ""

        results.extend(
            [
                OsintItem(
                    category="IDENTITY",
                    label="Email",
                    value=value,
                    confidence="HIGH",
                ),
                OsintItem(
                    category="DOMAIN",
                    label="Email domain",
                    value=domain,
                    confidence="HIGH",
                ),
            ]
        )
        sources.append("Public domain information")

    elif target_type == "phone":
        results.extend(
            [
                OsintItem(
                    category="IDENTITY",
                    label="Phone target",
                    value=value,
                    confidence="HIGH",
                ),
                OsintItem(
                    category="LOOKUP",
                    label="Public-source lookup",
                    value="Only publicly available information can be analyzed.",
                    confidence="PENDING",
                ),
            ]
        )
        sources.append("Publicly available sources")

    elif target_type == "url":
        parsed = urlparse(value)

        results.extend(
            [
                OsintItem(
                    category="DOMAIN",
                    label="Hostname",
                    value=parsed.hostname or value,
                    confidence="HIGH",
                ),
                OsintItem(
                    category="PROTOCOL",
                    label="Scheme",
                    value=parsed.scheme or "unknown",
                    confidence="HIGH",
                ),
            ]
        )
        sources.append("Public URL metadata")

    return OsintResponse(
        status="complete",
        target=value,
        target_type=target_type,
        summary=(
            f"KALEN classified the target as {target_type}. "
            "Results are limited to lawful/public intelligence."
        ),
        results=results,
        sources=sources,
    )


@router.get("/")
async def osint_status():
    return {
        "status": "online",
        "module": "OSINT",
    }


@router.post("/analyze", response_model=OsintResponse)
async def analyze_osint(request: OsintRequest):
    return analyze_target(
        request.target,
        request.target_type,
    )
