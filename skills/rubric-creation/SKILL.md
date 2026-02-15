---
name: phase-2-rubric-creation
description: Phase 2 of the MKT2700 AI-Augmented Product Development Pipeline. Creates a weighted evaluation rubric organizing criteria into market-facing and capability-facing groups informed by Phase 1 Strategic Brief, using flat weighted scoring. Uses 0-4 scoring scale with defined levels. Enforces weighting BEFORE scoring. Triggers on "begin phase 2," "rubric creation," "evaluation criteria," or "create rubric." Requires Phase 1 Strategic Brief as input.
---
# ©2026 Brad Scheller

# Phase 2: Rubric Creation

## Purpose

Build a comprehensive, weighted evaluation rubric tailored to the team's specific strategic situation. This rubric will be used in Phase 5 to evaluate all discovered concepts. Criteria are organized into market-facing and capability-facing groups for clarity, with flat weighted scoring across all criteria.

## Prerequisites

Requires the `strategic-brief.md` artifact from Phase 1. If not available, ask the student to provide it.

## Process

### Behavioral Directive: Propose-and-Refine

**Do NOT re-ask questions that Phase 1 already answered.** The Strategic Brief contains the team's industry, capabilities, constraints, competitive analysis, and strategic direction. Use it.

For every step in this phase:
1. Read the relevant prior artifact(s)
2. Propose outputs based on what you already know
3. Present proposals with your reasoning
4. Ask the team to validate, adjust, or fill gaps — not to start from scratch

### Step 1: External Criteria Discovery (AI Deep Research)

Using web search and the Strategic Brief, research what makes products successful in this specific market. Generate and investigate these questions:

1. "What are the critical success factors for new [industry] products?"
2. "What caused recent product failures in [industry]?"
3. "What do customers in [market segment] value most when choosing products?"
4. "What regulatory or compliance requirements exist for [industry] products?"
5. "What are the emerging trends that successful [industry] products must address?"

**Cross-reference your external findings with the PESTEL, Porter's Five Forces, and competitive analysis from the Strategic Brief. Propose criteria that align with the macro forces already identified.**

Synthesize findings into ~15-20 external criteria. Common categories include:
- Market fit & demand validation
- Competitive differentiation
- Revenue potential / market size
- Customer acquisition feasibility
- Regulatory/compliance alignment
- Technology readiness
- Scalability potential
- Trend alignment

### Step 2: Internal Criteria Interview/Derivation

**First, read the Strategic Brief.** Extract:
- VRIO analysis (valuable/rare/inimitable/organized resources)
- SWOT findings (strengths, weaknesses, opportunities, threats)
- Self-assessment responses (team capabilities, constraints, timeline)
- Organizational constraints (budget, resources, timeline)

**Propose 5-10 capability-facing criteria derived from these findings.** Present them to the team with rationale:

"Based on your Strategic Brief, here are the capability-facing criteria I've derived. For each one, tell me if it's right, needs adjustment, or is missing something:

1. [Criterion name] — **Rationale:** Your VRIO analysis identified [specific capability]. This criterion ensures concepts leverage that strength.
2. [Criterion name] — **Rationale:** Your constraints section noted [budget/timeline/resource limit]. This criterion filters for feasibility within those bounds.
3. [Continue for all 5-10 proposed criteria]"

**Only ask NEW questions about gaps the Strategic Brief didn't cover.** If the Brief is silent on technical capabilities, partnership channels, or specific decision-killing constraints, ask targeted questions to fill those gaps.

Synthesize into ~5-10 internal criteria covering:
- Technical feasibility given team skills
- Budget alignment
- Timeline feasibility
- Resource availability
- Strategic fit with company capabilities (from VRIO)

### Step 3: Compile & Define Criteria

For EACH criterion, create a scoring definition:

```markdown
### [Criterion Name]
**Category:** External / Internal
**Weight:** [to be set in Step 4]

| Score | Level | Definition |
|-------|-------|------------|
| 0 | Non-existent | [specific definition for this criterion] |
| 1 | Weak | [specific definition] |
| 2 | Moderate | [specific definition] |
| 3 | Strong | [specific definition] |
| 4 | Exceptional | [specific definition] |
```

Each level definition must be specific and observable — not vague. Bad: "Somewhat good market fit." Good: "Target market segment identified with evidence of demand from 2+ independent sources, but no direct customer validation yet."

### Step 3.5: Organize Criteria into Groups

Organize all criteria into two groups for readability and logical flow. This grouping is for organization only — all criteria will be scored with individual weights in a single flat formula.

**Two-group framework:**

1. **Market-Facing Criteria**
   - Derived from external research (Step 1)
   - Examples: market fit, competitive differentiation, customer demand, market size, regulatory alignment, trend alignment, revenue potential

2. **Capability-Facing Criteria**
   - Derived from internal assessment (Step 2)
   - Examples: technical feasibility, budget alignment, timeline feasibility, strategic fit with VRIO capabilities, resource availability, team expertise

**Process:**

1. Review your Phase 1 Strategic Brief findings
2. Sort each criterion from Steps 1-2 into one of these two groups based on whether it addresses external market factors or internal capabilities
3. The grouping does NOT affect scoring — it's purely for organization
4. All criteria will receive individual weights (1-5) and contribute equally to the flat scoring formula

### Step 4: Weight Assignment

**CRITICAL: Weights must be assigned BEFORE any concepts are scored. This prevents gaming the system to favor a preferred concept.**

Present all criteria to the team and ask them to assign individual criterion weights (1-5). Guide with:

1. "Which criteria are absolutely essential — a score of 0 on these should eliminate a concept regardless of other scores?"
2. "Rank these criteria from most to least important for your company's specific situation."
3. "Assign a weight from 1-5 to each criterion, where 5 = critical and 1 = nice-to-have."

The system suggests initial weights based on the Strategic Brief analysis, then lets the team adjust. These are individual criterion weights, not category weights — all criteria contribute directly to the final score using a flat formula.

### Step 5: Add Must-Have Constraints

Identify binary pass/fail criteria that act as pre-filters:
- These are not scored on the 0-4 scale
- They are YES/NO gates: if NO, the concept is killed before rubric scoring
- Examples: "Must be legal in target market," "Must be buildable within 12 months," "Must not require >$500K initial investment"

### Step 6: Validate & Lock

Present the complete rubric to the team for review:
- Total criteria count
- Weight distribution (show as % of total weight)
- Must-have constraints list
- Sample scoring walkthrough with a hypothetical concept

Once approved, lock the rubric. No changes after scoring begins.

## Scoring Formula

**Flat Weighted Scoring:**

```
Concept Score = Σ(score_i × weight_i) ÷ Σ(4 × weight_i) × 100%
```

Where:
- Each criterion is scored 0-4 and assigned an individual weight (1-5)
- All criteria contribute directly to the final score regardless of group
- The denominator normalizes to the theoretical maximum (all criteria scored 4)
- Final Score is a percentage where 100% = perfect score on every criterion

## Decision Thresholds

| Score Range | Decision | Action |
|-------------|----------|--------|
| < 90% | **KILL** | Eliminate from consideration |
| 90% – 95% | **REVISE** | Identify improvement opportunities; re-evaluate after changes |
| > 95% | **CONTINUE** | Advance to deep research and refinement |

For concepts in the REVISE band, the system generates improvement suggestions ranked by projected impact on the final score.

## Output: Evaluation Rubric Artifact

Save as `evaluation-rubric.md`:

```markdown
# Evaluation Rubric: [Company Name]

## Must-Have Constraints (Pass/Fail)
1. [Constraint]: YES/NO
2. [Constraint]: YES/NO
...

## Scoring Criteria

### Market-Facing Criteria
| # | Criterion | Weight | 0 (Non-existent) | 1 (Weak) | 2 (Moderate) | 3 (Strong) | 4 (Exceptional) |
|---|-----------|--------|-------------------|----------|--------------|------------|------------------|
| 1 | [name] | [1-5] | [definition] | [def] | [def] | [def] | [def] |
| 2 | [name] | [1-5] | [definition] | [def] | [def] | [def] | [def] |
...

### Capability-Facing Criteria
| # | Criterion | Weight | 0 (Non-existent) | 1 (Weak) | 2 (Moderate) | 3 (Strong) | 4 (Exceptional) |
|---|-----------|--------|-------------------|----------|--------------|------------|------------------|
| 1 | [name] | [1-5] | [definition] | [def] | [def] | [def] | [def] |
| 2 | [name] | [1-5] | [definition] | [def] | [def] | [def] | [def] |
...

## Scoring Formula
Concept Score = Σ(score_i × weight_i) ÷ Σ(4 × weight_i) × 100%

## Decision Thresholds
- < 90%: KILL
- 90-95%: REVISE (with improvement roadmap)
- > 95%: CONTINUE

## Total Criteria: [N]
## Rubric Locked: [date]
```

## LLM Council Checkpoint: Rubric Vetting

This phase includes an LLM Council checkpoint. See `llm-council-protocol.md` for the full protocol.

**Checkpoint:** Rubric Vetting
**When to run:** After the team has drafted the complete rubric (Step 6) but BEFORE locking it.
**Command:**
```bash
python scripts/llm_council.py --checkpoint rubric \
  --input evaluation-rubric.md \
  --context strategic-brief.md
```
**What happens next:** Paste `council-rubric.md` into Claude and say: "Here is Gemini's independent rubric review. Run the LLM Council reconciliation protocol." Review all divergences and gaps with the team. Adopt recommended changes, THEN lock the rubric.

## Handoff

After generating the rubric:
1. Save the artifact.
2. Remind: "Your rubric is now LOCKED. Do not change weights or criteria after this point."
3. Instruct: "Open a new chat and say 'Begin Phase 3.' Bring your progress tracker and Strategic Brief."
