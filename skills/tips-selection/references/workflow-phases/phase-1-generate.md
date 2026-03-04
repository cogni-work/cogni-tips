# Phase 1: Generate Candidate Pool

**Reference Checksum:** `sha256:tips-sel-p1-gen-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-1-generate.md | Checksum: tips-sel-p1-gen-v1
```

---

## Objective

Generate 60 trend candidates (5 per cell across 4 dimensions × 3 horizons) contextualized to the project's industry sector.

**Expected Duration:** 60-90 seconds (includes extended thinking)

---

## Entry Gate

Before proceeding, verify Phase 0 (and optionally Phase 0.5) outputs:

- [ ] PROJECT_PATH set and validated
- [ ] INDUSTRY_SECTOR extracted
- [ ] RESEARCH_TYPE = `smarter-service`
- [ ] Logging initialized
- [ ] WEB_RESEARCH_AVAILABLE flag set (true/false)
- [ ] If WEB_RESEARCH_AVAILABLE=true: WEB_RESEARCH_CONTEXT loaded

**If any missing:** STOP. Return to Phase 0.

---

## Dimension Framework (Embedded)

### Four Fixed Dimensions

| Dimension Slug | German Name | Primary TIPS | Focus |
|----------------|-------------|--------------|-------|
| `externe-effekte` | Externe Effekte | Trend (T) | External forces, regulations, market shifts |
| `neue-horizonte` | Neue Horizonte | Possibilities (P) | Strategic options, business model evolution |
| `digitale-wertetreiber` | Digitale Wertetreiber | Implications (I) | Value creation, digital impact |
| `digitales-fundament` | Digitales Fundament | Solutions (S) | Capabilities, infrastructure, enablers |

### Three Horizons

| Horizon | Timeframe | Characteristics |
|---------|-----------|-----------------|
| `act` | 0-2 years | Immediate, validated, ready for implementation |
| `plan` | 2-5 years | Emerging, requires preparation, building capabilities |
| `observe` | 5+ years | Future, speculative, monitoring stage |

---

## Step 1.1: Initialize Generation

```bash
log_phase "Phase 1: Generate Candidate Pool" "start"
log_conditional INFO "Industry sector: ${INDUSTRY_SECTOR}"
log_conditional INFO "Target: 60 candidates (5 per cell × 12 cells)"
log_conditional INFO "Web research available: ${WEB_RESEARCH_AVAILABLE}"
```

---

## Step 1.1.5: Load Web Research Context (If Available)

If web research was executed in Phase 0.5, load the signals:

```bash
if [ "$WEB_RESEARCH_AVAILABLE" = "true" ]; then
  log_conditional INFO "Loading web research context..."
  log_conditional INFO "Total signals available: ${WEB_RESEARCH_CONTEXT.total_signals}"

  # Log signal counts per dimension
  for dim in externe-effekte neue-horizonte digitale-wertetreiber digitales-fundament; do
    signal_count=${WEB_RESEARCH_CONTEXT.signals_by_dimension.$dim.signal_count}
    log_conditional INFO "  $dim: $signal_count signals"
  done
else
  log_conditional WARN "Web research not available - using training knowledge only"
  log_conditional WARN "Candidates will be marked as source=training"
fi
```

### Target Mix When Web Research Available

When `WEB_RESEARCH_AVAILABLE=true`, aim for:

| Source Type | Target Count | Percentage |
|-------------|--------------|------------|
| web-signal | 24-36 | 40-60% |
| training | 24-36 | 40-60% |
| hybrid | 0-12 | 0-20% |

**Minimum:** At least 2 web-signal candidates per dimension (8 total).

---

## Step 1.2: Generate Candidates (Extended Thinking)

### MANDATORY: Thinking Block Template

Generate 60 candidates using a single extended thinking block.

**When WEB_RESEARCH_AVAILABLE=true**, incorporate web signals into generation:

<thinking>
**TIPS Candidate Generation for ${INDUSTRY_SECTOR}**

**Web Research Status:** ${WEB_RESEARCH_AVAILABLE}
**Total Web Signals:** ${WEB_RESEARCH_CONTEXT.total_signals} (if available)

**Industry Context:**
- Sector: ${INDUSTRY_SECTOR}
- Key characteristics: [DESCRIBE industry-specific characteristics]
- Current challenges: [LIST major challenges]
- Transformation drivers: [LIST key drivers]

---

**DIMENSION 1: Externe Effekte (External Effects) - TREND Focus**

**Web Signals for this dimension (if available):**
${If WEB_RESEARCH_AVAILABLE:}
1. Signal: ${signal_name} | Keywords: ${keywords} | Source: ${url} | Fresh: ${date}
2. Signal: ${signal_name} | Keywords: ${keywords} | Source: ${url} | Fresh: ${date}
[List all signals for externe-effekte]
${Else:}
No web signals - using training knowledge only
${EndIf}

**Generation Strategy:**
- 2-3 candidates: Derived from web signals (mark source=web-signal)
- 2-3 candidates: From training knowledge (mark source=training)
- Ensure diversity across horizons

Act Horizon (0-2y) - 5 candidates:

| # | Trend Name | Keywords | Rationale | Source | Freshness |
|---|------------|----------|-----------|--------|-----------|
| 1 | [NAME from web signal] | [kw1], [kw2], [kw3] | [Why relevant + web evidence] | web-signal | [date] |
| 2 | [NAME from training] | [kw1], [kw2], [kw3] | [Why relevant] | training | - |
| 3 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | web-signal | [date] |
| 4 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | training | - |
| 5 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | training | - |

Plan Horizon (2-5y) - 5 candidates:

| # | Trend Name | Keywords | Rationale | Source | Freshness |
|---|------------|----------|-----------|--------|-----------|
| 1 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 2 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 3 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 4 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 5 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |

Observe Horizon (5+y) - 5 candidates:

| # | Trend Name | Keywords | Rationale | Source | Freshness |
|---|------------|----------|-----------|--------|-----------|
| 1 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 2 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 3 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 4 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |
| 5 | [NAME] | [kw1], [kw2], [kw3] | [Why relevant] | [source] | [date/-] |

---

**DIMENSION 2: Neue Horizonte (New Horizons) - POSSIBILITIES Focus**

**Web Signals for this dimension (if available):**
[List signals from WEB_RESEARCH_CONTEXT.signals_by_dimension.neue-horizonte]

Act Horizon (0-2y) - 5 candidates:
[SAME TABLE FORMAT WITH Source AND Freshness COLUMNS]

Plan Horizon (2-5y) - 5 candidates:
[SAME TABLE FORMAT]

Observe Horizon (5+y) - 5 candidates:
[SAME TABLE FORMAT]

---

**DIMENSION 3: Digitale Wertetreiber (Digital Value Drivers) - IMPLICATIONS Focus**

**Web Signals for this dimension (if available):**
[List signals from WEB_RESEARCH_CONTEXT.signals_by_dimension.digitale-wertetreiber]

Act Horizon (0-2y) - 5 candidates:
[SAME TABLE FORMAT WITH Source AND Freshness COLUMNS]

Plan Horizon (2-5y) - 5 candidates:
[SAME TABLE FORMAT]

Observe Horizon (5+y) - 5 candidates:
[SAME TABLE FORMAT]

---

**DIMENSION 4: Digitales Fundament (Digital Foundation) - SOLUTIONS Focus**

**Web Signals for this dimension (if available):**
[List signals from WEB_RESEARCH_CONTEXT.signals_by_dimension.digitales-fundament]

Act Horizon (0-2y) - 5 candidates:
[SAME TABLE FORMAT WITH Source AND Freshness COLUMNS]

Plan Horizon (2-5y) - 5 candidates:
[SAME TABLE FORMAT]

Observe Horizon (5+y) - 5 candidates:
[SAME TABLE FORMAT]

---

**Generation Summary:**
- Total candidates: 60
- Distribution: 15 per dimension, 5 per cell
- Web-signal sourced: [COUNT] candidates
- Training sourced: [COUNT] candidates
- Industry alignment: All candidates contextualized to ${INDUSTRY_SECTOR}
- TIPS coverage: Each dimension emphasizes its primary TIPS component
</thinking>

### Source Type Definitions

| Source Type | Definition | Freshness |
|-------------|------------|-----------|
| `web-signal` | Candidate derived from Phase 0.5 web search results | Date from source |
| `training` | Candidate from LLM training knowledge | `-` (no date) |
| `hybrid` | Web signal enriched with training context | Date from source |

---

## Step 1.3: Store Candidates in Memory

Store the generated candidates in a structured format for Phase 2:

```bash
# Candidates stored in memory (LLM internal state)
# Structure: Array of objects with dimension, horizon, sequence, trend_name, keywords, rationale, source, freshness

CANDIDATES_GENERATED=60
CANDIDATES_PER_CELL=5

# Track source distribution
WEB_SIGNAL_COUNT=0
TRAINING_COUNT=0
HYBRID_COUNT=0

for candidate in CANDIDATES; do
  case $candidate.source in
    "web-signal") WEB_SIGNAL_COUNT=$((WEB_SIGNAL_COUNT + 1)) ;;
    "training") TRAINING_COUNT=$((TRAINING_COUNT + 1)) ;;
    "hybrid") HYBRID_COUNT=$((HYBRID_COUNT + 1)) ;;
  esac
done

log_conditional INFO "Generated ${CANDIDATES_GENERATED} candidates"
log_conditional INFO "Distribution: ${CANDIDATES_PER_CELL} per cell × 12 cells"
log_conditional INFO "Source breakdown: web-signal=${WEB_SIGNAL_COUNT}, training=${TRAINING_COUNT}, hybrid=${HYBRID_COUNT}"
```

---

## Step 1.4: Validate Generation

Verify candidate count and distribution:

```bash
# Validate counts
for dim in externe-effekte neue-horizonte digitale-wertetreiber digitales-fundament; do
  for horizon in act plan observe; do
    count=$(count_candidates "$dim" "$horizon")
    if [ "$count" -ne 5 ]; then
      log_conditional ERROR "Cell ${dim}:${horizon} has ${count} candidates (expected 5)"
      exit 1
    fi
  done
done

log_conditional INFO "Validation passed: 60 candidates across 12 cells"
```

---

## Step 1.5: Mark Phase 1 Complete

```bash
log_phase "Phase 1: Generate Candidate Pool" "complete"
log_metric "candidates_generated" "60" "count"
```

---

## Success Criteria

- [ ] 60 candidates generated
- [ ] 5 candidates per cell (12 cells)
- [ ] All candidates include: trend_name, keywords (3), rationale, source, freshness
- [ ] All candidates contextualized to INDUSTRY_SECTOR
- [ ] Each dimension emphasizes its primary TIPS component
- [ ] If WEB_RESEARCH_AVAILABLE: 40-60% web-signal sourced candidates
- [ ] Source distribution logged

---

## Candidate Quality Guidelines

### Good Candidates

- **Specific:** Clear trend name (2-5 words)
- **Relevant:** Directly applicable to the industry sector
- **Actionable:** Can be researched and validated
- **Distinct:** Minimally overlapping with other candidates in same cell

### Avoid

- Generic trends not specific to the industry
- Duplicate trends across cells
- Overly broad or vague trend names
- Trends that don't fit the horizon timeframe

---

## Next Phase

Proceed to [phase-2-present.md](phase-2-present.md)

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Extended thinking fails | Retry generation |
| Candidate count != 60 | Log error, regenerate missing cells |
| Industry context unclear | Use general digital transformation trends |
