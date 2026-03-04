---
name: tips-selection
description: |
  Interactive TIPS (Trend-Implications-Possibilities-Solutions) candidate selection workflow for smarter-service research projects. Generates trend candidates across 4 dimensions and 3 horizons, presents them for user review and down-selection, supports user-proposed candidates and regeneration requests, and iterates until agreed candidates are finalized. Mandatory prerequisite for dimension-planner when research_type is smarter-service. Use when: (1) Starting smarter-service research that requires TIPS candidate selection, (2) User wants to review and select trend candidates before generating refined questions, (3) User mentions "TIPS selection", "trend candidates", or wants to customize research candidates, (4) dimension-planner halts due to missing agreed-trend-candidates.json.
---

# TIPS Selection

Interactive workflow for selecting TIPS (Trend-Implications-Possibilities-Solutions) candidates for smarter-service research projects.

## Purpose

This skill is a **mandatory prerequisite** for `dimension-planner` when `research_type: smarter-service`. It enables users to:

1. Generate 60 trend candidates (5 per cell)
2. Auto-select all 60 candidates for smarter-service (5 per cell)
3. Produce agreed candidates for dimension-planner

## Prerequisites

- Research project initialized with `research_type: smarter-service` in question frontmatter
- `industry_sector` field in question frontmatter OR extractable from `research_context`

## References Index

Read references **only when needed** for the specific task:

| Reference | Read when... |
|-----------|--------------|
| [references/workflow-phases/phase-0-initialize.md](references/workflow-phases/phase-0-initialize.md) | Starting skill - load context |
| [references/workflow-phases/phase-0.5-web-research.md](references/workflow-phases/phase-0.5-web-research.md) | Executing live web search for trend signals |
| [references/workflow-phases/phase-1-generate.md](references/workflow-phases/phase-1-generate.md) | Generating 60 candidates |
| [references/workflow-phases/phase-2-present.md](references/workflow-phases/phase-2-present.md) | Writing trend-candidates.md |
| [references/workflow-phases/phase-3-process.md](references/workflow-phases/phase-3-process.md) | Processing user selections |
| [references/workflow-phases/phase-4-finalize.md](references/workflow-phases/phase-4-finalize.md) | Finalizing agreed candidates |
| [../../references/research-types/smarter-service.md](../../references/research-types/smarter-service.md) | Understanding TIPS framework |

## Immediate Action: Initialize TodoWrite

**MANDATORY:** Initialize TodoWrite immediately with workflow phases:

1. Phase 0: Initialize & Load Context [in_progress]
2. Phase 0.5: Web Research (if enabled) [pending]
3. Phase 1: Generate Candidate Pool [pending]
4. Phase 2: Present Candidates [pending]
5. Phase 3: Process User Selection [pending]
6. Phase 4: Finalize Agreed Candidates [pending]

Update todo status as you progress through each phase.

---

## Core Workflow

```text
Phase 0 → Phase 0.5 → Phase 1 → Phase 2 → [USER EDITS] → Phase 3 → Phase 4
   │          │          │         │            │            │         │
   │          │          │         │            │            │         └─ Write JSON
   │          │          │         │            │            └─ Validate selections
   │          │          │         │            └─ User marks [x], adds proposals
   │          │          │         └─ Write trend-candidates.md, PAUSE
   │          │          └─ Generate 60 candidates (mix web + training)
   │          └─ Web search for trend signals (8 searches: 4 dims × 2 regions)
   └─ Load question, extract industry_sector, set WEB_RESEARCH_ENABLED
```

**Web Research:** Enabled by default. Disable with `web_research: false` in question frontmatter.

### Phase 0: Initialize & Load Context

Read [references/workflow-phases/phase-0-initialize.md](references/workflow-phases/phase-0-initialize.md), then execute:

1. Extract PROJECT_PATH from question file path
2. Read question frontmatter for `industry_sector` or extract from `research_context`
3. Validate project has `research_type: smarter-service`
4. Create `02-refined-questions/data/` directory if needed
5. Configure WEB_RESEARCH_ENABLED (default: true)
6. Initialize logging

**Required outputs:**

- PROJECT_PATH, INDUSTRY_SECTOR variables set
- WEB_RESEARCH_ENABLED configured
- Project validated as smarter-service type

### Phase 0.5: Web Research (If Enabled)

Read [references/workflow-phases/phase-0.5-web-research.md](references/workflow-phases/phase-0.5-web-research.md), then execute:

1. Build 8 search configurations (4 dimensions × 2 regions: global + DACH)
2. Execute WebSearch for each config
3. Extract trend signals from results
4. Aggregate and deduplicate signals by dimension
5. Build WEB_RESEARCH_CONTEXT for Phase 1

**Required outputs:**

- WEB_RESEARCH_AVAILABLE flag set
- WEB_RESEARCH_CONTEXT with signals by dimension

**Fallback:** If all searches fail, proceed with training-only generation (warning logged).

### Phase 1: Generate Candidate Pool

Read [references/workflow-phases/phase-1-generate.md](references/workflow-phases/phase-1-generate.md), then execute:

1. Load WEB_RESEARCH_CONTEXT if available
2. Generate 60 trend candidates using extended thinking
3. Mix web-signal sourced (40-60%) and training sourced (40-60%) candidates
4. 5 candidates per cell (4 dimensions × 3 horizons × 5 = 60)
5. Each candidate includes: trend name, keywords (3), rationale, source, freshness
6. All candidates contextualized to INDUSTRY_SECTOR

**Required outputs:**

- 60 candidates stored in memory with source tracking
- Distribution: 5 per cell (12 cells total)
- Source breakdown: web-signal count, training count

### Phase 2: Present Candidates

Read [references/workflow-phases/phase-2-present.md](references/workflow-phases/phase-2-present.md), then execute:

1. Write `trend-candidates.md` to `{PROJECT_PATH}/02-refined-questions/data/`
2. Include selection tables with checkboxes
3. Include "User Proposed" section
4. Include "More?" column for regeneration requests
5. Include selection summary table

**PAUSE:** After writing the file, instruct user to:

**smarter-service auto-selection:** All 60 candidates are automatically selected (5 per cell). No user down-selection required.

### Phase 4: Finalize Agreed Candidates

Read [references/workflow-phases/phase-4-finalize.md](references/workflow-phases/phase-4-finalize.md), then execute:

1. Build JSON structure with 60 agreed candidates (auto-selected)
2. Write `agreed-trend-candidates.json` to `.metadata/`
3. Update `trend-candidates.md` frontmatter status to `agreed`
4. Log completion

**Required outputs:**

- `.metadata/agreed-trend-candidates.json` with 60 candidates
- `trend-candidates.md` status updated to `agreed`

---

## Output Schema

### trend-candidates.md

Location: `{PROJECT_PATH}/02-refined-questions/data/trend-candidates.md`

```yaml
---
status: draft | pending_review | agreed
industry_sector: "manufacturing"
generated_at: 2025-12-16T10:30:00Z
total_candidates: 60
selected_count: 0
web_research_status: "success"
web_sourced_candidates: 28
training_sourced_candidates: 32
search_timestamp: 2025-12-16T10:25:00Z
---
```

### agreed-trend-candidates.json

Location: `{PROJECT_PATH}/.metadata/agreed-trend-candidates.json`

```json
{
  "metadata": {
    "industry_sector": "manufacturing",
    "agreed_at": "2025-12-16T11:45:00Z",
    "total_candidates": 60,
    "source_skill": "tips-selection",
    "web_research_status": "success",
    "web_sourced_count": 18,
    "training_sourced_count": 18,
    "search_timestamp": "2025-12-16T10:25:00Z"
  },
  "candidates": [
    {
      "dimension": "externe-effekte",
      "horizon": "act",
      "sequence": 1,
      "trend_name": "EU AI Act Compliance",
      "keywords": ["ai-act", "regulation", "2024"],
      "rationale": "Immediate deadline pressure",
      "source": "web-signal",
      "source_url": "https://ec.europa.eu/...",
      "freshness_date": "2024-12"
    }
  ]
}
```

---

## Selection Constraints

| Constraint | Value |
|------------|-------|
| Total candidates generated | 60 (5 per cell) |
| Candidates per cell | 5 |
| Selection mode | Auto-select all 60 (smarter-service) |
| Total agreed candidates | 60 (4 dims × 3 horizons × 5) |

---

## Dimension Matrix

| Dimension | German | Primary TIPS | Horizon Distribution |
|-----------|--------|--------------|---------------------|
| externe-effekte | Externe Effekte | Trend (T) | 5 Act, 5 Plan, 5 Observe |
| neue-horizonte | Neue Horizonte | Possibilities (P) | 5 Act, 5 Plan, 5 Observe |
| digitale-wertetreiber | Digitale Wertetreiber | Implications (I) | 5 Act, 5 Plan, 5 Observe |
| digitales-fundament | Digitales Fundament | Solutions (S) | 5 Act, 5 Plan, 5 Observe |

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Missing question file | Exit 1, cannot proceed |
| research_type not smarter-service | Exit 1, skill only for smarter-service |
| industry_sector not found | Prompt user to provide |
| trend-candidates.md not found (Phase 3) | Run Phase 1-2 first |
| Selection count invalid | Report errors, PAUSE for user correction |
| User proposal off-sector | Warn but allow override |

---

## Integration with dimension-planner

After `tips-selection` completes:

1. User invokes `dimension-planner` skill
2. dimension-planner Phase 2 checks for `.metadata/agreed-trend-candidates.json`
3. If present and valid (60 candidates): Use agreed candidates
4. If missing: HALT with instruction to run `tips-selection` first

---

## Debugging

### Logging

```bash
# Log file location
${PROJECT_PATH}/.logs/tips-selection-execution-log.txt

# View phase transitions
grep "\[PHASE\]" "${PROJECT_PATH}/.logs/tips-selection-execution-log.txt"

# View validation results
grep "\[VALIDATION\]" "${PROJECT_PATH}/.logs/tips-selection-execution-log.txt"
```

### Common Issues

1. **"Selection count invalid"** - User marked wrong number of candidates per cell
2. **"Industry sector not found"** - Add `industry_sector:` to question frontmatter
3. **"File not found"** - Ensure trend-candidates.md exists before Phase 3
