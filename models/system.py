from pydantic import BaseModel

class SystemStatus(BaseModel):
    ai: str
    version: str
    status: str