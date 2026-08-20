from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
import secrets

router = APIRouter(prefix="/auth", tags=["Authentication"])

PASSKEY = "KALEN"

class LoginRequest(BaseModel):
    passkey: str

active_sessions = {}

@router.post("/login")
def login(data: LoginRequest):

    if data.passkey != PASSKEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid Passkey"
        )

    token = secrets.token_hex(32)

    active_sessions[token] = {
        "login_time": datetime.now().isoformat()
    }

    return {
        "status": "SUCCESS",
        "token": token
    }