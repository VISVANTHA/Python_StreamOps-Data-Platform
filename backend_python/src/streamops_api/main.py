from fastapi import FastAPI
from .pipeline import IngestionPipeline

app = FastAPI(title="StreamOps Ingestion API")
pipeline = IngestionPipeline()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/api/ingest/stats")
def stats():
    return pipeline.stats()

@app.post("/api/ingest/event")
def ingest(event: dict):
    return pipeline.accept(event)
