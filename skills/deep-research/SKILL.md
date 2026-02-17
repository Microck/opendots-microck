---
name: deep-research
user-invocable: true
allowed-tools: Read, Write, Glob, Task, perplexity-webui_pplx_ask, perplexity-webui_pplx_deep_research, kagi-search_kagi-search, AskUserQuestion
description: Deep research with multi-stage verification pipeline inspired by Lutum Veritas. Use for comprehensive, verified research with claim audits and cross-referencing. Triggered by "deep research", "thorough research", or "/deep-research".
---

# Deep Research Skill - Lutum Veritas Inspired

## Trigger
- "deep research on [topic]"
- "thorough research on [topic]"
- "/deep-research [topic]"
- Any request requiring comprehensive, verified answers with sources

## Core Philosophy

**Key innovations from Lutum Veritas:**
1. **Recursive context passing** - Each research point knows what previous ones discovered
2. **Claim Audits** - Self-verification instead of blind assertions
3. **Dual-scraping phases** - First for answer, second for verification
4. **Source transparency** - Every claim traced to its source

---

## Mode Selection

### Mode A: Quick Verify (Ask Mode)
**When:** User needs a verified answer, not a full research report
**Time:** ~60-90 seconds
**Use for:** Factual questions, single-topic verification

### Mode B: Deep Research
**When:** User needs comprehensive analysis
**Time:** ~5-15 minutes
**Use for:** Complex topics, multiple angles, full reports

**Ask user which mode** if unclear:
- "Do you want a quick verified answer (~2 min) or comprehensive deep research (~10 min)?"

---

## Mode A: Quick Verify Pipeline (6 Stages)

```
C1: Intent Analysis → C2: Knowledge Gap → C3: Search Strategy → C4: Synthesis → C5: Claim Audit → C6: Verification
```

### Stage C1: Intent Analysis
**Goal:** Understand what the user really needs

Use Perplexity Ask to analyze the question:
```
Analyze this research question and identify:
1. Core intent - what is the user actually trying to understand?
2. Implicit requirements - what does "good answer" look like for this query?
3. Success criteria - how will we know the answer is complete?

Question: {user_question}
```

### Stage C2: Knowledge Gap Analysis  
**Goal:** Determine what must be searched vs. what model knows

```
For this question: {user_question}

What does the model's training data likely cover well?
What aspects definitely need fresh web search?
Be specific about knowledge gaps.
```

### Stage C3: Search Strategy
**Goal:** Create targeted search plan

Execute parallel searches using Perplexity Search:
- Primary angle: {main_topic}
- Counter角度: {opposing_view}
- Latest updates: {topic} 2024 2025

Use Kagi as secondary source for:
- Technical docs, GitHub, forums
- Alternative viewpoints not in Perplexity

### Stage C4: Answer Synthesis
**Goal:** Generate initial answer with inline citations

Format:
- Start with direct answer
- Use [1], [2], [3] for sources
- Distinguish established facts from interpretations
- Flag areas of uncertainty

### Stage C5: Claim Audit (KEY INNOVATION)
**Goal:** Self-verify every claim

For each major claim in C4 output, run verification:
```
Claim: {specific_claim_from_answer}

Verify this claim. Search for contradictory evidence.
Return:
- VERIFIED: Source confirms claim
- CONTRADICTED: Sources disagree  
- UNCERTAIN: Insufficient evidence
- NUANCED: Claim is partially true but needs qualification
```

**This is the Lutum Veritas magic** - forces self-reflection instead of blind assertions.

### Stage C6: Final Verification
**Goal:** Cross-check against second set of sources

Search for:
- "debunks [claim]"
- "myth about [topic]"
- "[topic] false"

Final output format:
```
## Answer

[Synthesized answer with verified claims]

## Sources
[1] Source title - URL
[2] Source title - URL

## Verification Notes
- Claim X: VERIFIED [source]
- Claim Y: NUANCED - [qualification]
- Claim Z: UNCERTAIN - [explanation]
```

---

## Mode B: Deep Research Pipeline

```
Clarification → Research Plan → Deep Research (per point) → Final Synthesis
```

### Step 1: Clarification
Ask smart follow-up questions to understand scope:

```
To research this topic effectively, I need to clarify:

1. Scope: Are we covering history, current state, future, or all?
2. Depth: Surface overview or detailed analysis?
3. Angle: Any specific perspective (pro/con, technical, business)?
4. Audience: Expert or general?
5. Time sensitivity: Need latest 2024/2025 info?

Topic: {topic}
```

Use AskUserQuestion tool.

### Step 2: Research Plan
Generate structured investigation points:

```
Create a research plan for: {topic}

Break this into 4-8 independent research points that:
- Can be researched in parallel
- Together cover the topic comprehensively
- Have clear, distinct angles
- Build on each other (later points can reference earlier)

Format:
## Research Points

### Point 1: [Title]
- Focus: [what to investigate]
- Key questions: [2-3 questions]
- Expected sources: [type of sources]

...etc
```

### Step 3: Deep Research (Per Point)
For EACH research point, execute:

**3a. Think:** Generate search queries for this point
**3b. Search:** Run Perplexity + Kagi searches  
**3c. Select:** Pick best 3-5 URLs
**3d. Synthesize:** Create "dossier" for this point

**CRITICAL:** Pass context forward:
```
Context from previous research points:
{summary_of_points_1_to_n-1}

Now researching point {n}: {title}

How does this connect to previous findings?
What new angles does this point add?
```

### Step 4: Final Synthesis
Cross-reference all dossiers:

```
Synthesize all research points into a comprehensive report:

## Previous Findings (Context)
{all_point_summaries}

## New Research: Point {n}
{current_dossier}

## Cross-Reference Task
- What connects this to previous findings?
- Any contradictions?
- What's the unified picture?
```

Final output structure:
```
# Deep Research: {Topic}

## Executive Summary
{2-3 paragraph overview}

## Key Findings
### Finding 1
- Evidence: [source]
- Confidence: HIGH/MEDIUM/LOW

### Finding 2
...

## Source Registry
| # | Source | Type | Relevance |
|---|--------|------|-----------|
| 1 | Title | article | 9/10 |
...

## Areas of Uncertainty
- [List claims with lower confidence]

## Conclusion
{ synthesised answer }
```

---

## Source Quality Grading

Apply Lutum Veritas quality levels:

| Level | Source Type | Reliability |
|-------|-------------|-------------|
| I | Peer-reviewed academic | Highest |
| II | Official docs/ government | High |
| III | Major news / established media | High |
| IV | Industry publications | Medium |
| V | Blog posts / personal sites | Lower |
| VI | Social media / forums | Lowest |
| VII | Unknown / unverified | Avoid |

---

## Cost Optimization (from Lutum Veritas philosophy)

- Use Perplexity Search for initial discovery (cheap)
- Use Perplexity Ask for synthesis (moderate)
- Use Kagi for technical/deep sources (secondary verification)
- Reserve Deep Research for complex topics only

**Target costs:**
- Quick Verify: ~5k tokens
- Deep Research: ~30-50k tokens

---

## Verification Checklist

Before presenting any research, confirm:

- [ ] Each factual claim has inline citation
- [ ] Contradicting evidence sought and noted
- [ ] Confidence levels assigned to claims
- [ ] Sources are recent (unless historical topic)
- [ ] Alternative viewpoints represented
- [ ] Uncertainty explicitly acknowledged

---

## Examples

**Quick Verify:**
- "Deep research: Is AI coding actually faster?"
- "Verify: What's the current state of Rust in web dev?"

**Deep Research:**
- "Do a deep research on: The true cost of AI coding assistants in enterprise"
- "Thorough research: Compare React vs Vue vs Svelte in 2025"

---

## Fallback

If research is inconclusive:
```
## Limitations

- [Aspect that couldn't be verified]
- [Reason for uncertainty]
- [Recommendations for further research]
```

Always be honest about what couldn't be determined. This is the Lutum Veritas way - truth over confidence.
