from fastapi import FastAPI

app = FastAPI(title="KALEN AI")

@app.get("/")
def home():
    return {
        "name": "KALEN AI",
        "status": "ONLINE"
    }