# MKT2700 — ProdDevIQ Phase 2

**PRD to Working Prototype** | Spring 2026 | Northeastern University

## Overview

Phase 2 takes your Product Requirements Document from Phase 1 and turns it into a working prototype. This repository includes AI-powered skills and agents that guide you through every step — from choosing a tech stack to deploying a live demo.

## Quick Start

1. **Download this repo** — Click **Code** → **Download ZIP**
2. **Extract to your G: Drive** — Right-click → Extract Here
3. **Open terminal** — `cd` into the extracted folder
4. **Copy Phase 1 files** — Move your `product-requirements.md`, `evaluation-rubric.md`, and `strategic-brief.md` into the project root
5. **Start Claude Code** — Type `claude` and begin with `/student-app-starter`

## What's Included

### Skills (11)
Guided workflows for each step of the prototype process:

| Category | Skills |
|----------|--------|
| **Scaffolding** | `student-app-starter`, `start-new-project` |
| **Development** | `frontend-master`, `backend-master`, `shadcn-ui` |
| **Version Control** | `github-master` |
| **Problem Solving** | `when-stuck` |
| **Evaluation** | `rubric-creation`, `llm-council-protocol`, `synthetic-persona-validation` |
| **Presentation** | `pptx` |

### Agents (3)
Specialist AI agents you can delegate tasks to:
- `architect-reviewer` — System design validation
- `frontend-developer` — Frontend implementation
- `backend-developer` — Backend implementation

## Prerequisites

- **Claude Code** installed (`npm install -g @anthropic-ai/claude-code`)
- **Northeastern account** logged into Claude Code (free Opus 4.6 access)
- **Phase 1 deliverables** (PRD, rubric, strategic brief)
- **Gemini API key** (for LLM Council — free from [Google AI Studio](https://aistudio.google.com/apikey))

## The Companion (Browser GUI)

The Companion gives you a browser-based interface for Claude Code — multiple sessions side by side, visual tool call feedback, and streaming responses. Much easier than a plain terminal.

### Quick Install

**Mac / Linux:**
```bash
bash install-companion.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File install-companion.ps1
```

### Manual Install

1. Install Bun (one-time):
   - **Mac/Linux:** `curl -fsSL https://bun.sh/install | bash`
   - **Windows PowerShell:** `irm bun.sh/install.ps1 | iex`
2. Launch: `bunx the-companion`
3. Open **localhost:3456** in your browser

### What You Get

- **Multiple sessions** — Run several Claude Code instances side by side
- **Streaming** — See responses token by token as they're written
- **Tool visibility** — Every file edit, bash command, and search shown in collapsible blocks
- **Subagent nesting** — Watch agent teams work hierarchically
- **Permission control** — Approve or deny tool calls from the browser

## Phase 2 Deliverables

| Item | File |
|------|------|
| Working prototype | Deployed URL (Vercel/similar) |
| Persona validation results | `persona-validation-results.md` |
| Architecture documentation | `architecture.md` |
| Demo video | `TeamXX_Prototype_Demo.mp4` |
| Presentation slides | `TeamXX_Phase2_Presentation.pptx` |

---

*© 2026 Brad Scheller · Northeastern University*
