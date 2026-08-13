import httpx

def fetch_stats(base_url: str) -> dict:
    r = httpx.get(f"{base_url.rstrip('/')}/api/ingest/stats", timeout=5.0)
    r.raise_for_status()
    return r.json()
