---
name: synthetic-persona-validation
description: >
  Generates a panel of synthetic personas representing the target market from your PRD.
  Each persona responds to your concept pitch in character, providing realistic feedback.
  The system scores responses against your evaluation rubric with kill/refine/proceed thresholds.
  Trigger: "validate my concept", "test with personas", "synthetic market feedback",
  or /validate-concept.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
context: fork
---
# ©2026 Brad Scheller

# Synthetic Persona Validation

## Purpose

Generate a panel of realistic synthetic personas from your target market and test your product concept against them. The panel provides structured feedback scored against your team's evaluation rubric.

## Prerequisites

- `product-requirements.md` (your PRD from Phase 1)
- `evaluation-rubric.md` (your rubric from Phase 1, Phase 2)

If either file is missing, ask the student to provide it or paste the key sections.

## Process

### Step 1: Extract Target Market Profile

Read the PRD and identify:
1. Primary target user segment (demographics, psychographics)
2. Key pain points the product addresses
3. Current alternatives they use
4. Decision-making criteria

Present this back to the student for validation before generating personas.

### Step 2: Generate Persona Panel

Create **5 synthetic personas** that represent a realistic cross-section of the target market:

Each persona must include:
- **Name & background** (realistic, diverse)
- **Role/occupation** relevant to the target segment
- **Tech savviness** (1-5 scale)
- **Key pain point** they experience
- **Current solution** they use today
- **Budget sensitivity** (low/medium/high)
- **Decision style** (impulsive, analytical, consensus-seeker, skeptic)

Present the panel to the student: "Here's your test panel. Want to adjust any personas before we begin?"

### Step 3: Concept Pitch

Ask the student to pitch their concept in 2-3 paragraphs. If they struggle, help them structure it:
- What is it?
- Who is it for?
- What problem does it solve?
- How is it different from what exists?

### Step 4: Persona Responses

Each persona responds **in character** to the pitch. Responses must include:
- **Initial reaction** (1-2 sentences, gut feeling)
- **Interest level** (1-10)
- **Top concern or objection**
- **What would make them say yes**
- **What would make them walk away**
- **Would they pay for this?** (yes/no/maybe + reasoning)

Personas should NOT all agree. Include at least one skeptic and one enthusiast.

### Step 5: Rubric Scoring

Read the student's `evaluation-rubric.md` and score the concept based on the persona panel's aggregated feedback:

For each rubric criterion:
1. Map persona responses to the relevant criterion
2. Score on the rubric's scale (0-4)
3. Provide specific evidence from persona responses

Calculate the weighted total as a percentage.

### Step 6: Verdict & Recommendations

Apply thresholds:

| Score | Verdict | Action |
|-------|---------|--------|
| **Below 90%** | **Kill** | The concept doesn't resonate with the target market. Identify the 2-3 fatal weaknesses. Suggest whether to pivot or abandon. |
| **90-95%** | **Refine** | The concept has potential but needs work. Provide 3-5 specific suggestions that would improve the score, mapped to rubric criteria. |
| **Above 95%** | **Proceed** | Strong concept. Provide enhancement suggestions but don't block progress. |

### Step 7: Output

Save results to `persona-validation-results.md` containing:
- Persona panel profiles
- Individual persona responses
- Rubric scoring breakdown
- Overall score and verdict
- Specific recommendations

## Key Principles

1. **Personas must feel real** — no generic "User A" labels. Give them names, jobs, personalities.
2. **Diversity matters** — vary ages, tech comfort, decision styles, and budget sensitivity.
3. **Honest feedback** — at least one persona should be hard to convince. Not everyone loves every idea.
4. **Rubric-anchored** — every score must reference specific rubric criteria with evidence.
5. **Actionable output** — recommendations should be specific enough to act on immediately.
