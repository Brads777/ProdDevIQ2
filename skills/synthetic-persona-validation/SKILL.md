---
name: synthetic-persona-validation
description: >
  Generates a panel of 100-200 synthetic personas representing the target market from your PRD.
  Personas are organized into demographic segments with detailed representatives and aggregate statistics.
  Each persona responds to your concept pitch in character, followed by simulated user interviews
  and usability testing. The system scores responses against your evaluation rubric with
  kill/refine/proceed thresholds.
  Trigger: "validate my concept", "test with personas", "synthetic market feedback",
  or /validate-concept.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
context: fork
---
# ©2026 Brad Scheller

# Synthetic Persona Validation

## Purpose

Generate a large-scale panel of realistic synthetic personas (100-200) from your target market and test your product concept against them. The panel provides structured market screening feedback, simulated user interviews, and usability testing — all scored against your team's evaluation rubric.

## Prerequisites

This skill builds on artifacts your team created during Phase 1 (MKT2700-ProdDevIQ). Two files are **required**, and others are **optional but enriching**.

### Required
| File | Created In | What It Contains |
|------|-----------|-----------------|
| `product-requirements.md` | Phase 1, Step 7 (PRD Generation) | Your product spec — target market, features, business model |
| `evaluation-rubric.md` | Phase 1, Step 2 (Rubric Creation) | Your scoring criteria and weights |

### Optional (enriches persona quality)
| File | Created In | What It Contains |
|------|-----------|-----------------|
| `strategic-brief.md` | Phase 1, Step 1 (Strategic Foundation) | Market landscape, competitive analysis |
| `evaluation-results.md` | Phase 1, Step 5 (Concept Evaluation) | LLM Council debate scores and optimization shifts |
| `refined-concept.md` | Phase 1, Step 6 (Refinement) | Final concept spec after council feedback |

## Process

### Step 0: Artifact Discovery

Before anything else, search for the required files. Check these locations in order:

1. **Current project root** (`./*.md`)
2. **Parent directory** (`../*.md`) — in case the student is in a subfolder
3. **Common Phase 1 project names** — look for sibling directories matching `*MKT2700*`, `*ProdDev*`, `*Phase1*`, `*phase-1*`

For each required file:
- If found → read it and confirm with the student: "I found your [file] at [path]. Is this the right one?"
- If NOT found → show the student what they're looking for:
  > "I need your **product-requirements.md** — this is the PRD your team created in Phase 1 (Step 7). It contains your target market, pain points, core features, and business model. Can you tell me which folder your Phase 1 project is in, or paste the key sections?"

Also search for any optional files. If found, note them: "I also found your strategic-brief.md — I'll use this to create more realistic personas."

**Do NOT proceed until both required files are located or the student has provided equivalent content.**

### Step 1: Extract Target Market Profile

Read the PRD and identify:
1. Primary target user segment (demographics, psychographics)
2. Key pain points the product addresses
3. Current alternatives they use
4. Decision-making criteria

Present this back to the student for validation before generating personas.

#### Step 1b: Assess Market Breadth & Determine Panel Size

After extracting the target market profile, assess how broad or narrow the target market is and determine the appropriate persona panel size:

| Market Type | Criteria | Panel Size |
|-------------|----------|------------|
| **Narrow/specific** | Single demographic, tight age range, specific industry or role (e.g., "college students ages 18-22 in CS programs", "pediatric dentists in suburban practices") | **100 personas** |
| **Broad/diverse** | Multiple segments, wide age range, cross-industry, or general population (e.g., "all small business owners", "anyone who manages personal finances") | **200 personas** |

Present the assessment to the student:

> "Based on your PRD, your target market is [narrow/broad] because [reasoning]. I recommend a panel of **[100/200] personas**. Would you like to adjust this number?"

Allow the student to override the panel size if they have a reason (e.g., they want more granularity or are short on time).

### Step 2: Generate Persona Panel

Create the full persona panel organized into **demographic segments**. Do NOT list all 100-200 personas individually. Instead, use a layered approach:

#### 2a: Define Demographic Segments

Based on the target market profile, define **5-10 demographic segments** that cover the full range of the target market. Each segment should represent a meaningfully different sub-group.

For each segment, specify:
- **Segment name** (e.g., "Budget-Conscious College Students", "Tech-Forward Small Business Owners")
- **Description** (2-3 sentences defining this sub-group)
- **Percentage of panel** (e.g., 30% of 100 = 30 personas)
- **Key characteristics** that distinguish this segment

Example distribution for a 100-persona panel:
| Segment | % | Count | Description |
|---------|---|-------|-------------|
| Segment A | 30% | 30 | Primary target, highest pain |
| Segment B | 25% | 25 | Secondary target, moderate pain |
| Segment C | 20% | 20 | Adjacent market, curious adopters |
| Segment D | 15% | 15 | Skeptical segment, hard to convert |
| Segment E | 10% | 10 | Edge cases, unusual use patterns |

The distribution should reflect realistic market composition — the primary target segment gets the largest share.

#### 2b: Create Representative Personas

For each segment, generate **3-5 fully detailed representative personas**. These are the named, fleshed-out individuals who speak for their segment.

Each representative persona must include:
- **Name & background** (realistic, diverse)
- **Role/occupation** relevant to the target segment
- **Tech savviness** (1-5 scale)
- **Key pain point** they experience
- **Current solution** they use today
- **Budget sensitivity** (low/medium/high)
- **Decision style** (impulsive, analytical, consensus-seeker, skeptic)
- **Segment membership** (which segment they belong to)

This yields approximately **25-50 fully detailed personas** across all segments.

#### 2c: Generate Aggregate Segment Statistics

For the remaining personas in each segment (those without individual profiles), generate aggregate statistics:
- **Interest level distribution** (e.g., "60% high interest, 25% moderate, 15% low")
- **Purchase intent %** (e.g., "45% would buy, 30% maybe, 25% no")
- **Top 3 common objections** for the segment
- **Price sensitivity range** for the segment
- **Most-valued features** (ranked)
- **Likely churn risks**

Present the full panel to the student: "Here's your test panel of [100/200] personas across [N] segments. I've created [X] detailed representative personas and aggregate statistics for the rest. Want to adjust any segments or personas before we begin?"

### Step 3: Concept Pitch

Ask the student to pitch their concept in 2-3 paragraphs. If they struggle, help them structure it:
- What is it?
- Who is it for?
- What problem does it solve?
- How is it different from what exists?

### Step 4: Market Screening Responses

Each **representative persona** (the 25-50 detailed ones) responds **in character** to the pitch. Responses must include:
- **Initial reaction** (1-2 sentences, gut feeling)
- **Interest level** (1-10)
- **Top concern or objection**
- **What would make them say yes**
- **What would make them walk away**
- **Would they pay for this?** (yes/no/maybe + reasoning)

Personas should NOT all agree. Include a range of reactions reflecting each segment's characteristics.

For the remaining personas (those represented by aggregate statistics), generate **segment-level response summaries**:
- **Segment-wide interest level distribution** (e.g., mean 6.8, std dev 1.4)
- **Top 3 objections** from this segment
- **Purchase intent breakdown** (yes/maybe/no percentages)
- **Key quotes** (3-5 representative reactions that capture the segment's range)

### Step 4b: Simulated User Interviews

Select **5 representative personas** from across the panel for in-depth simulated interviews. Choose one of each type:

| Interview Slot | Persona Type | Selection Criteria |
|---------------|-------------|-------------------|
| 1 | **Enthusiast** | Highest interest level, most positive initial reaction |
| 2 | **Skeptic** | Lowest interest level, strongest objections |
| 3 | **Fence-sitter** | Moderate interest (5-6 range), genuinely undecided |
| 4 | **Edge-case** | From the smallest or most unusual segment |
| 5 | **Primary target** | From the largest segment, represents the core user |

Conduct a simulated **10-question interview** with each persona, staying in character throughout. The questions:

1. **Current workflow** — "Walk me through how you handle [problem domain] today."
2. **Biggest frustration** — "What's the most annoying part of your current solution?"
3. **First impression** — "I just described [product]. What's your honest gut reaction?"
4. **Must-have features** — "Which features matter most to you? Why?"
5. **Never-use features** — "Anything in here you'd never touch? Why not?"
6. **Price sensitivity** — "What would you expect to pay for this? What's too much?"
7. **Switching trigger** — "What would make you actually switch from what you use now?"
8. **Dealbreaker** — "What's the one thing that would make you say 'absolutely not'?"
9. **Virality indicator** — "Who else do you know who needs something like this?"
10. **NPS-style recommendation** — "On a scale of 0-10, how likely are you to recommend this to a friend? Why?"

For each interview, provide the full transcript in a conversational Q&A format with the persona answering in character, reflecting their background, personality, and segment.

After all 5 interviews, provide a **Theme Summary**:
- Common threads across all interviews
- Surprising insights or contradictions
- Features that consistently excited or concerned personas
- Price sensitivity patterns
- Virality potential assessment

Save all interview transcripts and the theme summary to `interview-transcripts.md`.

### Step 4c: Usability Testing Simulation

Select **5 personas** that span the full range of tech savviness (one each at levels 1 through 5). These may overlap with interview personas or be different — choose whichever combination best covers the tech-savviness spectrum.

Each persona evaluates the product concept (or prototype, if available) against **6 usability heuristics**, scoring each 1-5 and providing an in-character comment:

| Heuristic | What It Measures |
|-----------|-----------------|
| **Learnability** | How easy is it for a first-time user to accomplish basic tasks? |
| **Efficiency** | Once learned, how quickly can users complete tasks? |
| **Error tolerance** | How well does the design help users recover from mistakes? |
| **Consistency** | Are patterns predictable across the interface? |
| **Accessibility** | Is the design inclusive for users with varying abilities and contexts? |
| **Value clarity** | Is the benefit of the product immediately obvious? |

Output a **Usability Scorecard** as a table:

| Persona | Tech Level | Learnability | Efficiency | Error Tolerance | Consistency | Accessibility | Value Clarity | Average |
|---------|-----------|-------------|-----------|----------------|-------------|--------------|--------------|---------|
| [Name] | 1 | X/5 | X/5 | X/5 | X/5 | X/5 | X/5 | X.X |
| [Name] | 2 | X/5 | X/5 | X/5 | X/5 | X/5 | X/5 | X.X |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |
| **Average** | — | X.X | X.X | X.X | X.X | X.X | X.X | **X.X** |

Below the scorecard, include each persona's verbatim comments on each heuristic.

Flag any heuristic that averages below 3.0 as a **critical usability issue**.

Save the usability scorecard and comments to `usability-scorecard.md`.

### Step 5: Rubric Scoring

Read the student's `evaluation-rubric.md` and score the concept by aggregating evidence from **all three test types**:

#### Primary weight: Market Screening Data (100-200 personas)
For each rubric criterion:
1. Map persona responses and segment-level statistics to the relevant criterion
2. Score on the rubric's scale (0-4)
3. Provide specific evidence from representative persona responses and segment aggregates

#### Supporting evidence: Interview Insights (5 deep interviews)
For each rubric criterion:
1. Pull relevant quotes and observations from the interview transcripts
2. Note where interviews confirmed or contradicted the market screening data
3. Adjust confidence in the score based on interview depth

#### UX criteria: Usability Scores (5 heuristic evaluations)
For UX-related rubric criteria:
1. Map usability heuristic scores to the relevant rubric criterion
2. Note critical usability issues (any heuristic averaging below 3.0)
3. Factor usability findings into the overall score

Calculate the weighted total as a percentage. For each criterion, show how all three data sources contributed to the final score.

### Step 6: Verdict & Recommendations

Apply thresholds:

| Score | Verdict | Action |
|-------|---------|--------|
| **Below 60%** | **Kill** | The concept doesn't resonate with the target market. Identify the 2-3 fatal weaknesses. Suggest whether to pivot or abandon. |
| **60-80%** | **Refine** | The concept has potential but needs work. Provide 3-5 specific suggestions that would improve the score, mapped to rubric criteria. |
| **Above 80%** | **Proceed** | Strong concept. Provide enhancement suggestions but don't block progress. |

Regardless of verdict, ALWAYS provide an **Improvement Roadmap** at the end of the verdict:

1. **Weakest criteria first** — List every rubric criterion that scored below 3, ordered from lowest to highest.
2. **Specific, actionable suggestions** — For each weak criterion, provide 2-3 concrete changes the team can make to their PRD, prototype, or pitch. Reference the specific persona objections that drove the score down.
3. **Which personas to win over** — Name the skeptical personas and explain exactly what would flip their response from negative to positive.
4. **Retest instructions** — Tell the student: "After making these changes, update your `product-requirements.md` and run `/validate-concept` again to see if your score improves."

The goal is that a student reading the verdict knows *exactly* what to change and can immediately iterate.

### Step 7: Output

Save results across multiple files:

| File | Contents |
|------|----------|
| `persona-validation-results.md` | Full market screening results with segment analysis: persona panel profiles, segment distributions, individual representative responses, segment-level response summaries, rubric scoring breakdown, overall score and verdict, and specific recommendations |
| `interview-transcripts.md` | All 5 interview transcripts (full Q&A), plus a theme summary covering common threads, surprising insights, feature sentiment, price patterns, and virality potential |
| `usability-scorecard.md` | Heuristic evaluation results: the scorecard table, per-persona comments on each heuristic, critical usability issues flagged, and UX improvement priorities |
| `market-heat-map.md` | Segment-by-segment breakdown showing hot/cold zones: each segment's interest level, purchase intent, top objections, feature preferences, and an overall heat rating (Hot / Warm / Cold) to help the team see where their concept resonates strongest and where it falls flat |

## Key Principles

1. **Personas must feel real** — no generic "User A" labels. Give them names, jobs, personalities.
2. **Diversity matters** — vary ages, tech comfort, decision styles, and budget sensitivity.
3. **Honest feedback** — at least one persona should be hard to convince. Not everyone loves every idea.
4. **Rubric-anchored** — every score must reference specific rubric criteria with evidence.
5. **Actionable output** — recommendations should be specific enough to act on immediately.
6. **Statistical significance through scale** — with 100-200 personas, segment-level patterns carry real weight. Avoid drawing conclusions from individual outliers; focus on trends that hold across a segment.
