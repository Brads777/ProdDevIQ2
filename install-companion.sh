#!/usr/bin/env bash
set -euo pipefail

# ProdDevIQ2 — Companion Installer (Mac/Linux)

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[Companion]${NC} $1"; }
ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
fail()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║     The Companion — Browser GUI Setup        ║"
echo "║        MKT2700 Phase 2 · ProdDevIQ2          ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Check for Claude Code ──────────────────────────────────
info "Checking prerequisites..."
if command -v claude &>/dev/null; then
    ok "Claude Code CLI found"
else
    fail "Claude Code not found. Install it first: npm install -g @anthropic-ai/claude-code"
fi

# ── Step 2: Install Bun ────────────────────────────────────────────
info "Checking for Bun..."
if command -v bun &>/dev/null; then
    ok "Bun already installed ($(bun --version))"
else
    info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    if command -v bun &>/dev/null; then
        ok "Bun installed ($(bun --version))"
    else
        warn "Bun installed but not in PATH yet."
        warn "Close this terminal, open a new one, and run this script again."
        exit 1
    fi
fi

# ── Step 3: Launch The Companion ───────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         Companion ready to launch!           ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "To start The Companion, run:"
echo -e "  ${CYAN}bunx the-companion${NC}"
echo ""
echo -e "Then open ${CYAN}http://localhost:3456${NC} in your browser."
echo ""
echo -e "Tip: You can also just use ${CYAN}claude${NC} in the terminal if you prefer."
echo ""

read -p "Launch The Companion now? (Y/n): " LAUNCH
if [[ ! "$LAUNCH" =~ ^[Nn]$ ]]; then
    info "Starting The Companion..."
    bunx the-companion
fi
