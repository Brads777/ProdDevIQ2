# MKT2700 Phase 2 — PRD to Prototype

**Course:** Product Design & Development (Spring 2026)
**University:** Northeastern University
**Instructor:** Brad Scheller

## What This Is

This repository provides AI-powered skills to help your team build a working prototype from the PRD you created in Phase 1. Each skill is a guided workflow that walks you through a specific step.

## Available Skills

| Skill | Trigger | What It Does |
|-------|---------|-------------|
| `student-app-starter` | "build my app", `/student-app-starter` | Walks you through picking a stack and scaffolding your project |
| `start-new-project` | "start new project", `/start-new-project` | Project setup wizard with repo configuration |
| `frontend-master` | When building UI components | Frontend architecture, state management, CSS patterns |
| `backend-master` | When building API/server | Backend patterns, API design, database setup |
| `shadcn-ui` | `/shadcn` | Pre-built UI components that look professional fast |
| `github-master` | When managing code | Git workflow, commits, branches, collaboration |
| `when-stuck` | "I'm stuck", "help" | Problem-solving dispatch — picks the right technique |
| `pptx` | "create presentation" | Generate PowerPoint slides |
| `rubric-creation` | "evaluate with rubric" | Reuse your Phase 1 rubric to score prototype quality |
| `llm-council-protocol` | "run council", `/council` | Multi-model debate (Claude + Gemini) on your outputs |
| `synthetic-persona-validation` | "validate my concept", `/validate-concept` | Test your prototype with AI-generated user personas |

## Available Agents

| Agent | What It Does |
|-------|-------------|
| `architect-reviewer` | Reviews your system design and architecture decisions |
| `frontend-developer` | Specialist for frontend implementation tasks |
| `backend-developer` | Specialist for backend implementation tasks |

## Phase 2 Workflow

```
1. START HERE ──────── /student-app-starter
   Pick your tech stack and scaffold the project

2. ARCHITECTURE ────── Ask architect-reviewer to review your plan
   Get feedback before you build

3. BUILD ───────────── Use frontend-master + backend-master
   Implement your PRD's core features

4. STYLE ───────────── /shadcn for UI components
   Make it look professional

5. VALIDATE ────────── /validate-concept
   Test with synthetic personas against your rubric

6. REFINE ──────────── Use council + rubric to evaluate
   Score your prototype, iterate on weak areas

7. PRESENT ─────────── Create your demo video + slides
   Record a walkthrough of your working prototype
```

## Bringing Phase 1 Artifacts Forward

Copy these files from your Phase 1 project into this project's root:
- `product-requirements.md` (your PRD)
- `evaluation-rubric.md` (your rubric)
- `strategic-brief.md` (your market research)

The Phase 2 skills will read these automatically.

## Tips

- **Start with `/student-app-starter`** — it asks the right questions and sets everything up
- **Use `when-stuck` liberally** — it's faster than Googling
- **Commit early and often** — use `github-master` to keep your code safe
- **Don't skip the persona validation** — it catches problems before your presentation
- **Every team member should run Claude Code** — split the work, merge via GitHub
