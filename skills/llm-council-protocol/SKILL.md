---
name: llm-council-protocol
description: Reusable multi-model evaluation protocol for the MKT2700 pipeline. Runs independent evaluations via Claude and Gemini API, compares structured outputs, identifies divergences, and reconciles through cross-examination or tiebreak. Used in Phase 2 (rubric vetting), Phase 5 (concept scoring), Phase 6 (KANO validation), and Phase 7 (PRD review). Triggers on "run council," "LLM council," "multi-model check," or "cross-evaluate."
---

# ©2026 Brad Scheller

# LLM Council Protocol

## Purpose

The LLM Council is a structured multi-model evaluation process that reduces single-model bias by running independent assessments through Claude and Gemini, then systematically reconciling disagreements. It is used at four critical decision points in the MKT2700 pipeline.

## Prerequisites

- Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)
- Environment variable set: `export GEMINI_API_KEY="your-key-here"`
- Python package installed: `pip install google-genai`

## Council Roles

| Role | Model | Responsibility |
|------|-------|---------------|
| **Evaluator A** | Claude (current session) | Produces structured output for the task |
| **Evaluator B** | Gemini (via API) | Independently produces the same structured output from identical context |
| **Reconciler** | Claude (current session) | Compares both outputs, identifies divergences, resolves them |

**Key principle:** Evaluators NEVER see each other's output before completing their own assessment. Independence is critical.

## Council Checkpoints in the Pipeline

| Phase | Checkpoint | What the Council Evaluates | Agreement Threshold |
|-------|-----------|---------------------------|-------------------|
| **Phase 2** | Rubric Vetting | Criteria completeness, weight balance, level definition clarity, bias | Structural agreement on criteria set |
| **Phase 5** | Concept Scoring | Per-criterion rubric scores for each concept | Within 1 point per criterion |
| **Phase 6** | KANO Validation | Feature classification across 5 KANO categories | Same category assignment |
| **Phase 7** | PRD Review | Internal consistency, evidence sufficiency, logical gaps | Pass/fail per section |

---

## Protocol Steps (Generic — Applies to All Checkpoints)

### Step 1: Prepare Council Input

Create an **identical context package** for both evaluators. This package must include:
- The task-specific prompt (defined per checkpoint below)
- All relevant artifacts
- The exact output format both models must follow

**Rule:** Both evaluators receive byte-for-byte identical input. No additional context, hints, or framing for either model.

### Step 2: Run Evaluator A (Claude)

Claude evaluates the task and produces structured output in the required format. Save this output before proceeding.

### Step 3: Run Evaluator B (Gemini)

Send the identical context package to Gemini via the API. Use the `llm_council.py` helper script (below) or call the API directly.

### Step 4: Compare Outputs

Generate a comparison matrix using the checkpoint-specific comparison rules. Classify each item as:
- **Agree** — within the agreement threshold
- **Diverge** — outside the agreement threshold
- **Gap** — one model identified something the other missed entirely

### Step 5: Resolve Divergences

For each divergence, apply resolution methods in order:

**Method 1 — Cross-Examination:**
Present Evaluator A with Evaluator B's reasoning (and vice versa). Ask each to:
1. Acknowledge the other's points
2. Identify which specific evidence supports each position
3. Provide a revised assessment if warranted

If models converge within the agreement threshold → resolved.

**Method 2 — Third-Model Tiebreak:**
If cross-examination fails, use a blind evaluator (fresh Gemini session or Perplexity) with:
- ONLY the raw evidence and task definition
- NO knowledge of either model's prior assessment
- The same output format

Use the tiebreak score as final.

### Step 6: Produce Reconciled Output

Generate the final reconciled assessment with:
- Agreed items (unchanged)
- Resolved divergences (with reconciliation notes)
- Tiebreak results (flagged as uncertainty areas)
- Confidence rating per item (High / Medium / Low)

---

## Checkpoint-Specific Prompts and Rules

### Checkpoint: Phase 2 — Rubric Vetting

**When:** After the team has drafted their rubric but BEFORE locking it.

**Council Input Package:**
```
TASK: Review this evaluation rubric for a product development project. Assess independently.

COMPANY CONTEXT:
[paste strategic-brief.md]

DRAFT RUBRIC:
[paste draft evaluation-rubric.md]

Evaluate the rubric on these dimensions:
1. COMPLETENESS: Are any critical criteria missing for this industry/market? List any gaps.
2. REDUNDANCY: Do any criteria overlap or measure the same thing? Identify pairs.
3. WEIGHT BALANCE: Are the category weights and individual weights reasonable for this company's situation? Flag any that seem over/under-weighted.
4. LEVEL DEFINITIONS: Are the 0-4 level definitions specific, observable, and unambiguous? Flag any that are vague.
5. BIAS CHECK: Do the criteria or weights unfairly favor a particular type of solution (e.g., digital over physical, B2C over B2B)? Identify any bias.
6. MUST-HAVE CONSTRAINTS: Are the pass/fail gates reasonable and sufficient?

For each dimension, provide:
- Rating: Strong / Adequate / Needs Improvement
- Specific findings with explanations
- Recommended changes (if any)
```

**Comparison Rules:**
- **Agree:** Both models rate a dimension the same (Strong/Adequate/Needs Improvement)
- **Diverge:** Models disagree on a dimension rating
- **Gap:** One model identifies a missing criterion or bias the other missed

**Resolution:** Present all identified gaps and divergences to the team. The team decides which recommendations to adopt before locking the rubric.

**Output:** `council-rubric.md` — appended to the rubric artifact.

---

### Checkpoint: Phase 5 — Concept Scoring

**When:** After Claude scores all concepts, before producing final rankings.

**Council Input Package:**
```
TASK: Score the following product concept against every criterion in this rubric.

RUBRIC:
[paste evaluation-rubric.md]

CONCEPT: [name]
RESEARCH EVIDENCE:
[paste concept's research dossier from research-repository.md]

For EACH criterion:
1. Score (0-4) based on the level definitions
2. One-sentence justification citing specific evidence
3. Confidence (High/Medium/Low)

Calculate final weighted score: Σ(score × weight) ÷ Σ(4 × weight) × 100%

Format as a markdown scorecard table.
```

**Comparison Rules:**
- **Agree:** Scores within 1 point on a criterion
- **Diverge:** Scores differ by 2+ points on a criterion

**Resolution:** Cross-examination for each divergent criterion. Tiebreak if unresolved. Unresolved items become risk flags in PRD Section 8.

**Output:** Reconciled scorecard per concept with confidence ratings.

---

### Checkpoint: Phase 6 — KANO Validation

**When:** After Claude classifies features into KANO categories, before finalizing.

**Council Input Package:**
```
TASK: Independently classify the following product features using the KANO model.

PRODUCT CONCEPT:
[paste refined concept summary]

TARGET USER:
[paste target user persona from research]

FEATURES TO CLASSIFY:
[list all features identified in Phase 6]

For EACH feature, classify into exactly one KANO category:
- Must-Be: Absence causes dissatisfaction, presence doesn't increase satisfaction
- Performance: More is better, linearly proportional to satisfaction
- Excitement: Unexpected, creates disproportionate delight
- Indifferent: Users don't care either way
- Reverse: Would hurt satisfaction if included

For each classification, provide:
1. Category assignment
2. One-sentence justification based on user needs
3. Confidence (High/Medium/Low)
```

**Comparison Rules:**
- **Agree:** Same KANO category
- **Diverge:** Different KANO category (especially Must-Be vs. Performance — this changes MVP scope)

**Critical divergences:** Must-Be ↔ Performance disagreements are high-stakes because they determine what goes in the MVP. These MUST be resolved, not left as "Low confidence."

**Resolution:** Cross-examination with specific focus on: "Would the target user be actively dissatisfied if this feature were missing, or would they simply prefer more of it?" This question distinguishes Must-Be from Performance.

**Output:** Reconciled KANO classification table with confidence ratings.

---

### Checkpoint: Phase 7 — PRD Review

**When:** After the full PRD draft is generated, before final submission.

**Council Input Package:**
```
TASK: Review this Product Requirements Document for quality, consistency, and completeness.

PRD:
[paste complete product-requirements-document.md]

SUPPORTING ARTIFACTS:
- Strategic Brief summary: [key points]
- Rubric score: [final reconciled score]
- KANO classification summary: [Must-Be count, Performance count, Excitement count]

Review each section and assess:
1. EVIDENCE SUFFICIENCY: Are claims supported by cited sources? Flag any unsupported assertions.
2. INTERNAL CONSISTENCY: Do sections contradict each other? (e.g., feature listed as in-scope in Section 5 but missing from Section 6)
3. LOGICAL FLOW: Does the narrative make sense from problem → solution → implementation?
4. COMPLETENESS: Are any required subsections missing or thin?
5. ACTIONABILITY: Could a development team actually build from this PRD? Are specs specific enough?

For each section (1-10), provide:
- Pass / Needs Revision
- Specific issues found (if any)
- Severity: Critical (blocks submission) / Minor (improve if time allows)
```

**Comparison Rules:**
- **Agree:** Both models give same Pass/Needs Revision for a section
- **Diverge:** One passes a section the other flags

**Resolution:** Any section flagged by EITHER model gets reviewed. Better to over-flag than miss an issue in the final deliverable.

**Output:** `council-prd-review.md` — checklist of issues to address before submission.

---

## Python Helper Script: `llm_council.py`

```python
"""
LLM Council Helper — MKT2700 Pipeline
Automates Gemini evaluation and comparison matrix generation.

Usage:
    python scripts/llm_council.py --checkpoint rubric --input evaluation-rubric.md --context strategic-brief.md
    python scripts/llm_council.py --checkpoint scoring --input research-repository.md --rubric evaluation-rubric.md --concept "Concept Name"
    python scripts/llm_council.py --checkpoint kano --input refined-concept.md --persona target-user-persona.md
    python scripts/llm_council.py --checkpoint prd-review --input product-requirements-document.md

Optional:
    --model MODEL    Override the default Gemini model (default: gemini-2.0-flash)
"""

import argparse
import os
import sys
from pathlib import Path

# --- Configuration ---
DEFAULT_GEMINI_MODEL = "gemini-2.0-flash"


def configure_api(model_name=None):
    """Configure Gemini API from environment variable. Returns (client, model_name)."""
    try:
        from google import genai
    except ImportError:
        print("ERROR: google-genai package not installed.")
        print("Install it with: pip install google-genai")
        sys.exit(1)
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("ERROR: GEMINI_API_KEY environment variable not set.")
        print("Get a free key at: https://aistudio.google.com/apikey")
        print("Then run: export GEMINI_API_KEY='your-key-here'")
        sys.exit(1)
    client = genai.Client(api_key=api_key)
    model = model_name or DEFAULT_GEMINI_MODEL
    print(f"Using model: {model}")
    return client, model


def read_file(path):
    """Read a file and return its contents."""
    try:
        return Path(path).read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"\nERROR: File not found: {path}")
        sys.exit(1)


def run_gemini_evaluation(client, model_name, prompt):
    """Send prompt to Gemini and return response text."""
    print(f"  Sending to {model_name}...")
    try:
        response = client.models.generate_content(
            model=model_name,
            contents=prompt,
        )
        if not response.text:
            print("\nERROR: Gemini returned an empty response.")
            sys.exit(1)
        print(f"  Response received ({len(response.text)} chars)")
        return response.text
    except Exception as e:
        error_msg = str(e)
        print(f"\nERROR: Gemini API request failed: {error_msg}")
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
            print("\nRate limit error. Wait a minute and try again.")
            print("Or try: --model gemini-2.0-flash-lite")
        elif "404" in error_msg or "NOT_FOUND" in error_msg:
            print(f"\nModel '{model_name}' not found. Try:")
            print("  --model gemini-2.0-flash")
            print("  --model gemini-2.0-flash-lite")
        sys.exit(1)


# (Checkpoint functions: rubric_vetting, concept_scoring, kano_validation, prd_review)
# Each accepts (client, model_name, ...) and calls run_gemini_evaluation.
# See scripts/llm_council.py for the full implementation.


def main():
    parser = argparse.ArgumentParser(description="LLM Council Helper — MKT2700 Pipeline")
    parser.add_argument("--checkpoint", required=True,
                        choices=["rubric", "scoring", "kano", "prd-review"])
    parser.add_argument("--input", required=True, help="Primary input file path")
    parser.add_argument("--context", help="Context file (for rubric checkpoint)")
    parser.add_argument("--rubric", help="Rubric file (for scoring checkpoint)")
    parser.add_argument("--concept", help="Concept name (for scoring checkpoint)")
    parser.add_argument("--persona", help="Persona file (for KANO checkpoint)")
    parser.add_argument("--output", help="Output file path (default: council-{checkpoint}.md)")
    parser.add_argument("--model", default=DEFAULT_GEMINI_MODEL,
                        help=f"Gemini model to use (default: {DEFAULT_GEMINI_MODEL})")

    args = parser.parse_args()
    client, model_name = configure_api(args.model)
    # ... checkpoint dispatch and output writing ...


if __name__ == "__main__":
    main()
```

> **Note:** The embedded script above is abbreviated. The full script with all checkpoint functions is at `scripts/llm_council.py`.

## Quick Reference: Running the Council

### Phase 2 — Rubric Vetting
```bash
# After Claude drafts the rubric:
python scripts/llm_council.py --checkpoint rubric \
  --input evaluation-rubric.md \
  --context strategic-brief.md

# Then paste council-rubric.md into Claude:
# "Here is Gemini's rubric review. Run the LLM Council reconciliation."
```

### Phase 5 — Concept Scoring
```bash
# After Claude scores a concept:
python scripts/llm_council.py --checkpoint scoring \
  --input research-repository.md \
  --rubric evaluation-rubric.md \
  --concept "Smart Kitchen Assistant"

# Repeat for each concept, then paste results into Claude for reconciliation.
```

### Phase 6 — KANO Validation
```bash
# After Claude classifies features:
python scripts/llm_council.py --checkpoint kano \
  --input refined-concept.md \
  --persona target-user-persona.md

# Paste council-kano.md into Claude for reconciliation.
```

### Phase 7 — PRD Review
```bash
# After the full PRD is drafted:
python scripts/llm_council.py --checkpoint prd-review \
  --input product-requirements-document.md

# Paste council-prd-review.md into Claude for reconciliation.
```

## Integration with Phase Skills

Each phase skill that uses the Council should include:

```markdown
## LLM Council Checkpoint

This phase includes an LLM Council checkpoint. See `llm-council-protocol.md` for the full protocol.

**Checkpoint:** [rubric / scoring / kano / prd-review]
**When to run:** [specific trigger point in the phase]
**Command:** [specific scripts/llm_council.py command]
**What happens next:** [what to do with the council output]
```

The Council output feeds back into the phase workflow — it does NOT create a separate deliverable (except for Phase 7 where `prd-council-review.md` is an optional submission artifact).
