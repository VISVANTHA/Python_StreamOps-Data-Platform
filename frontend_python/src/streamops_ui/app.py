import os
import streamlit as st
import httpx
from .dashboard import render_stats

API = os.environ.get("STREAMOPS_API", "http://127.0.0.1:8000")

st.title("StreamOps Ops Dashboard")
if st.button("Refresh ingestion stats"):
    r = httpx.get(f"{API}/api/ingest/stats", timeout=5.0)
    r.raise_for_status()
    render_stats(r.json())
