#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
pwsh -File "$ROOT/run_tools.ps1"
