# Python_StreamOps-Data-Platform

**Project:** StreamOps Data Platform  
**Language:** Python  
**Branch:** `Python_FE_V3.14_BE_V2.7`  
**Frontend version:** 3.14  
**Backend version:** 2.7

## Reference URLs

- `frontend_url`: https://github.com/mijanr/FastAPI-Streamlit
- `backend_url`: https://github.com/mijanr/FastAPI-Streamlit
- Frontend component: StreamOps Ops Dashboard (Streamlit)
- Backend component: StreamOps Ingestion API (FastAPI)

## Layout

- `frontend_python/` — frontend service
- `backend_python/` — backend API

## How to run (backend → frontend pipeline)

1. Start the backend in `backend_python/` (see that module's README / start script).
2. Start the frontend in `frontend_python/`.
3. Confirm the frontend successfully receives data from the backend endpoint.

## Tools

Each module has `run_tools.ps1` / `run_tools.sh` that invokes the Scenario 2 tool set and writes artifacts under `tool-output/`. Failures abort with the tool name — they do not silently skip.

Tools for this language (15):
- Ruff (verified: 3.7)
- complexipy (verified: 3.8)
- symilar (pylint) (verified: 3.10)
- Opengrep (verified: UNRESOLVED)
- Trivy (verified: N/A (language/runtime-version agnostic))
- SlipCover (verified: 3.8)
- mutmut (verified: 3.10)
- diff-cover (verified: N/A (language/runtime-version agnostic))
- astroid (verified: 3.10)
- astroid + SlipCover (verified: 3.10)
- Opengrep (taint mode) (verified: 10.0.26200)
- sys.settrace driver (stdlib) (verified: 3.14.7)
- pyan3 + astroid (verified: 3.10)
- pylint + vulture (verified: 3.10)
- dulwich (verified: N/A (language/runtime-version agnostic))
