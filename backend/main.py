from fastapi import FastAPI

from backend.api.chat import router as chat_router
from backend.api.voice import router as voice_router
from backend.api.vision import router as vision_router
from backend.api.creator import router as creator_router
from backend.api.osint import router as osint_router
from backend.api.smart_call import router as smart_call_router
from backend.api.system import router as system_router

app = FastAPI(
    title="KALEN AI",
    version="2.0"
)

app.include_router(chat_router)
app.include_router(voice_router)
app.include_router(vision_router)
app.include_router(creator_router)
app.include_router(osint_router)
app.include_router(smart_call_router)
app.include_router(system_router)

@app.get("/")
def root():
    return {
        "AI": "KALEN",
        "Status": "ONLINE",
        "Version": "2.0"
    }