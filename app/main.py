from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.model import summarize_text

app = FastAPI()


class TextRequest(BaseModel):
    text: str


@app.post("/summarize")
def summarize(request: TextRequest):
    if len(request.text) < 50:
        raise HTTPException(status_code=400, detail="Text too short to summarize")
    summary = summarize_text(request.text)
    return {"summary": summary}
