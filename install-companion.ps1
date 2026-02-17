# ProdDevIQ2 — Companion Installer (Windows PowerShell)

$ErrorActionPreference = "Stop"

function Write-Header {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     The Companion — Browser GUI Setup        ║" -ForegroundColor Cyan
    Write-Host "║        MKT2700 Phase 2 · ProdDevIQ2          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info($msg) { Write-Host "[Companion] $msg" -ForegroundColor Cyan }
function Write-Ok($msg) { Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "[✗] $msg" -ForegroundColor Red; exit 1 }

Write-Header

# ── Step 1: Check for Claude Code ──────────────────────────────────
Write-Info "Checking prerequisites..."
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    Write-Ok "Claude Code CLI found"
} else {
    Write-Fail "Claude Code not found. Install it first: npm install -g @anthropic-ai/claude-code"
}

# ── Step 2: Install Bun ────────────────────────────────────────────
Write-Info "Checking for Bun..."
$bun = Get-Command bun -ErrorAction SilentlyContinue
if ($bun) {
    $bunVer = & bun --version
    Write-Ok "Bun already installed ($bunVer)"
} else {
    Write-Info "Installing Bun..."
    irm bun.sh/install.ps1 | iex

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    $bun = Get-Command bun -ErrorAction SilentlyContinue
    if ($bun) {
        $bunVer = & bun --version
        Write-Ok "Bun installed ($bunVer)"
    } else {
        Write-Warn "Bun installed but not in PATH yet."
        Write-Warn "Close this PowerShell window, open a new one, and run this script again."
        exit 1
    }
}

# ── Step 3: Launch The Companion ───────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         Companion ready to launch!           ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "To start The Companion, run:" -ForegroundColor White
Write-Host "  bunx the-companion" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then open http://localhost:3456 in your browser." -ForegroundColor White
Write-Host ""
Write-Host "Tip: You can also just use 'claude' in the terminal if you prefer." -ForegroundColor Gray
Write-Host ""

$launch = Read-Host "Launch The Companion now? (Y/n)"
if ($launch -ne "n" -and $launch -ne "N") {
    Write-Info "Starting The Companion..."
    & bunx the-companion
}
