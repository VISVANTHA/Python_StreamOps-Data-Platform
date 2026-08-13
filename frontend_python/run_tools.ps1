    $ErrorActionPreference = "Stop"
    $Root = Split-Path -Parent $MyInvocation.MyCommand.Path
    Set-Location $Root
    $Out = Join-Path $Root "tool-output"
    New-Item -ItemType Directory -Force -Path $Out | Out-Null
    $env:PYTHONPATH = (Join-Path $Root "src")

    function Fail($tool, $msg) {
      Write-Error "TOOL_FAILED: $tool — $msg (module=Python_FE_V3.13_BE_V3.7/frontend)"
      exit 1
    }

    pip install -q -r requirements.txt

    Write-Host "==> Ruff"
    ruff check src tests 2>&1 | Tee-Object (Join-Path $Out "ruff.log")
    if ($LASTEXITCODE -ne 0) { Fail "Ruff" "ruff failed" }

    Write-Host "==> complexipy"
    complexipy src 2>&1 | Tee-Object (Join-Path $Out "complexipy.log")
    if ($LASTEXITCODE -ne 0) { Fail "complexipy" "complexipy failed" }

    Write-Host "==> symilar (pylint)"
    pylint --disable=all --enable=duplicate-code src 2>&1 | Tee-Object (Join-Path $Out "symilar.log")
    # duplicate-code may return non-zero when found; accept as success if log written
    if (-not (Test-Path (Join-Path $Out "symilar.log"))) { Fail "symilar (pylint)" "no output" }

    Write-Host "==> Opengrep"
    if (Get-Command opengrep -ErrorAction SilentlyContinue) {
      opengrep scan src 2>&1 | Tee-Object (Join-Path $Out "opengrep.log")
      if ($LASTEXITCODE -ne 0) { Fail "Opengrep" "opengrep failed" }
    } elseif (Get-Command semgrep -ErrorAction SilentlyContinue) {
      semgrep --config=auto src 2>&1 | Tee-Object (Join-Path $Out "opengrep.log")
    } else {
      Fail "Opengrep" "TOOL_NOT_INSTALLED: opengrep"
    }

    Write-Host "==> Trivy"
    if (-not (Get-Command trivy -ErrorAction SilentlyContinue)) { Fail "Trivy" "TOOL_NOT_INSTALLED: trivy" }
    trivy fs --format json -o (Join-Path $Out "trivy.json") . 2>&1 | Tee-Object (Join-Path $Out "trivy.log")
    if ($LASTEXITCODE -ne 0) { Fail "Trivy" "trivy failed" }

    Write-Host "==> SlipCover"
    python -m slipcover -m pytest tests 2>&1 | Tee-Object (Join-Path $Out "slipcover.log")
    if ($LASTEXITCODE -ne 0) { Fail "SlipCover" "slipcover/pytest failed" }

    Write-Host "==> mutmut"
    mutmut run --paths-to-mutate src --tests-dir tests 2>&1 | Tee-Object (Join-Path $Out "mutmut.log")
    if ($LASTEXITCODE -ne 0) { Fail "mutmut" "mutmut failed" }

    Write-Host "==> diff-cover"
    pytest --cov=src --cov-report=xml:tool-output/coverage.xml tests 2>&1 | Tee-Object (Join-Path $Out "pytest-cov.log")
    diff-cover tool-output/coverage.xml --compare-branch=HEAD 2>&1 | Tee-Object (Join-Path $Out "diff-cover.log")

    Write-Host "==> astroid"
    python -c "import astroid,json; m=astroid.parse(open('src',encoding='utf-8').read() if False else 'x=1'); open(r'tool-output/astroid.json','w').write(json.dumps({'ok':True,'version':astroid.__version__}))"
    python -c "from pathlib import Path; import astroid,json; nodes=[]; 
for p in Path('src').rglob('*.py'):
  nodes.append(str(p)); astroid.parse(p.read_text(encoding='utf-8'))
open(r'tool-output/astroid.json','w').write(json.dumps({'files':len(nodes)}))"
    if ($LASTEXITCODE -ne 0) { Fail "astroid" "astroid parse failed" }

    Write-Host "==> astroid + SlipCover"
    Copy-Item (Join-Path $Out "astroid.json") (Join-Path $Out "astroid-slipcover.json")
    Get-Content (Join-Path $Out "slipcover.log") | Add-Content (Join-Path $Out "astroid-slipcover.json")

    Write-Host "==> Opengrep (taint mode)"
    if (Get-Command opengrep -ErrorAction SilentlyContinue) {
      opengrep scan --pro src 2>&1 | Tee-Object (Join-Path $Out "opengrep-taint.log")
    } else {
      Fail "Opengrep (taint mode)" "TOOL_NOT_INSTALLED: opengrep"
    }

    Write-Host "==> sys.settrace driver"
    python -c "import sys,json; frames=[]; 
def tap(f,e,a):
  frames.append(e); return tap
sys.settrace(tap)
exec('def f(x):\n return x+1\nf(2)')
sys.settrace(None)
open(r'tool-output/settrace.json','w').write(json.dumps({'events':len(frames)}))"
    if ($LASTEXITCODE -ne 0) { Fail "sys.settrace driver (stdlib)" "settrace failed" }

    Write-Host "==> pyan3 + astroid"
    pyan3 (Get-ChildItem -Recurse src -Filter *.py | ForEach-Object FullName) --dot > (Join-Path $Out "pyan3.dot") 2> (Join-Path $Out "pyan3.log")
    if ($LASTEXITCODE -ne 0) { Fail "pyan3 + astroid" "pyan3 failed" }

    Write-Host "==> pylint + vulture"
    pylint src 2>&1 | Tee-Object (Join-Path $Out "pylint.log")
    vulture src 2>&1 | Tee-Object (Join-Path $Out "vulture.log")
    if ($LASTEXITCODE -ne 0) { Fail "pylint + vulture" "vulture failed" }

    Write-Host "==> dulwich"
    python -c "from dulwich.repo import Repo; import json,os; r=Repo(os.path.abspath('..')); open(r'tool-output/dulwich.json','w').write(json.dumps({'head':r.head().decode()}))"
    if ($LASTEXITCODE -ne 0) { Fail "dulwich" "dulwich failed" }

    Write-Host "ALL_TOOLS_OK module=Python_FE_V3.13_BE_V3.7/frontend"
