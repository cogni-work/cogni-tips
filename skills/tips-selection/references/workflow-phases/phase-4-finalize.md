# Phase 4: Finalize Agreed Candidates

**Reference Checksum:** `sha256:tips-sel-p4-final-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-4-finalize.md | Checksum: tips-sel-p4-final-v1
```

---

## Objective

Write the 52 agreed candidates to `.metadata/agreed-trend-candidates.json` and update `trend-candidates.md` status to `agreed`.

**Expected Duration:** 10-15 seconds

---

## Entry Gate

Before proceeding, verify Phase 3 outputs:

- [ ] 52 candidates selected
- [ ] Horizon-specific counts: 5 ACT, 5 PLAN, 3 OBSERVE per dimension
- [ ] All validation checks passed

**If validation incomplete:** Return to Phase 3.

---

## Step 4.1: Initialize Phase

```bash
log_phase "Phase 4: Finalize Agreed Candidates" "start"
log_conditional INFO "Building JSON output for 52 agreed candidates"
```

---

## Step 4.2: Build JSON Structure

### JSON Schema

```json
{
  "metadata": {
    "industry_sector": "${INDUSTRY_SECTOR}",
    "agreed_at": "${ISO_TIMESTAMP}",
    "total_candidates": 52,
    "source_skill": "tips-selection",
    "project_path": "${PROJECT_PATH}",
    "web_research_status": "success|partial|failed|disabled",
    "web_sourced_count": 18,
    "training_sourced_count": 18,
    "search_timestamp": "${SEARCH_TIMESTAMP}"
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
    },
    {
      "dimension": "externe-effekte",
      "horizon": "act",
      "sequence": 2,
      "trend_name": "Supply Chain Resilience",
      "keywords": ["supply-chain", "resilience", "risk"],
      "rationale": "Post-pandemic strategic priority",
      "source": "training",
      "freshness_date": null
    },
    // ... 50 more candidates
  ]
}
```

### Source Field Values

| Source Value | Description |
|--------------|-------------|
| `web-signal` | Derived from Phase 0.5 web search |
| `training` | Generated from LLM training knowledge |
| `hybrid` | Web signal enriched with training context |
| `user_proposed` | Proposed by user in selection phase |

### MANDATORY: Thinking Block for JSON Building

<thinking>
**Building Agreed Candidates JSON**

Collecting 52 selected candidates:

**externe-effekte:**
- act: [CANDIDATE 1-5] (5 candidates)
- plan: [CANDIDATE 1-5] (5 candidates)
- observe: [CANDIDATE 1-3] (3 candidates)

**neue-horizonte:**
- act: [CANDIDATE 1-5] (5 candidates)
- plan: [CANDIDATE 1-5] (5 candidates)
- observe: [CANDIDATE 1-3] (3 candidates)

**digitale-wertetreiber:**
- act: [CANDIDATE 1-5] (5 candidates)
- plan: [CANDIDATE 1-5] (5 candidates)
- observe: [CANDIDATE 1-3] (3 candidates)

**digitales-fundament:**
- act: [CANDIDATE 1-5] (5 candidates)
- plan: [CANDIDATE 1-5] (5 candidates)
- observe: [CANDIDATE 1-3] (3 candidates)

**Source Statistics:**
- Total: 52 candidates
- Web-signal sourced: [COUNT]
- Training sourced: [COUNT]
- Hybrid sourced: [COUNT]
- User proposed: [COUNT]

**Web Research Metadata:**
- Status: ${WEB_RESEARCH_STATUS}
- Search timestamp: ${SEARCH_TIMESTAMP}
</thinking>

---

## Step 4.3: Write JSON File

```bash
JSON_OUTPUT_FILE="${PROJECT_PATH}/.metadata/agreed-trend-candidates.json"

# Use Write tool to create the JSON file
# (LLM executes Write tool with JSON content)

log_conditional INFO "Written: ${JSON_OUTPUT_FILE}"
```

---

## Step 4.4: Update trend-candidates.md Status

Update the frontmatter status from `draft` to `agreed`:

```bash
# Update frontmatter in trend-candidates.md
# Change: status: draft → status: agreed
# Add: agreed_at: ${ISO_TIMESTAMP}

TIPS_CANDIDATES_FILE="${PROJECT_PATH}/02-refined-questions/data/trend-candidates.md"

# Use Edit tool to update frontmatter
# (LLM executes Edit tool)

log_conditional INFO "Updated trend-candidates.md status to 'agreed'"
```

### Updated Frontmatter

```yaml
---
status: agreed
industry_sector: "${INDUSTRY_SECTOR}"
generated_at: ${ORIGINAL_TIMESTAMP}
agreed_at: ${ISO_TIMESTAMP}
total_candidates: 60
selected_count: 52
web_research_status: "${WEB_RESEARCH_STATUS}"
web_sourced_candidates: ${WEB_SOURCED_COUNT}
training_sourced_candidates: ${TRAINING_SOURCED_COUNT}
search_timestamp: ${SEARCH_TIMESTAMP}
---
```

---

## Step 4.5: Validate Output Files

```bash
# Verify JSON file exists and is valid
if [ -f "$JSON_OUTPUT_FILE" ]; then
  # Validate JSON structure
  candidate_count=$(jq '.candidates | length' "$JSON_OUTPUT_FILE")
  if [ "$candidate_count" -eq 52 ]; then
    log_conditional INFO "JSON validation passed: 52 candidates"
  else
    log_conditional ERROR "JSON candidate count mismatch: ${candidate_count}"
    exit 1
  fi
else
  log_conditional ERROR "JSON file not created: ${JSON_OUTPUT_FILE}"
  exit 1
fi

# Verify trend-candidates.md status
file_status=$(grep -E "^status:" "$TIPS_CANDIDATES_FILE" | sed 's/status: *//')
if [ "$file_status" == "agreed" ]; then
  log_conditional INFO "trend-candidates.md status verified: agreed"
else
  log_conditional ERROR "Status update failed: ${file_status}"
  exit 1
fi
```

---

## Step 4.6: Mark Phase 4 Complete

```bash
log_phase "Phase 4: Finalize Agreed Candidates" "complete"
log_metric "final_candidates" "52" "count"
log_metric "json_file_size" "$(stat -f%z "$JSON_OUTPUT_FILE")" "bytes"
```

---

## Step 4.7: Output Success Message

```text
---

## TIPS Selection Complete

Your selection of 52 trend candidates has been finalized.

### Output Files:

| File | Purpose |
|------|---------|
| `.metadata/agreed-trend-candidates.json` | JSON for dimension-planner integration |
| `02-refined-questions/data/trend-candidates.md` | Human-readable selection record (status: agreed) |

### Selection Summary:

| Dimension | Act | Plan | Observe | Total |
|-----------|-----|------|---------|-------|
| externe-effekte | 5 | 5 | 3 | 13 |
| neue-horizonte | 5 | 5 | 3 | 13 |
| digitale-wertetreiber | 5 | 5 | 3 | 13 |
| digitales-fundament | 5 | 5 | 3 | 13 |
| **TOTAL** | 20 | 20 | 12 | **52** |

### Next Steps:

You can now run `dimension-planner` with your smarter-service research project.
The agreed candidates will be automatically loaded from `.metadata/agreed-trend-candidates.json`.

```bash
# Invoke dimension-planner skill
# It will detect the agreed candidates and skip its own candidate generation
```

---

**Status:** Selection agreed
**Ready for:** dimension-planner

---
```

---

## Success Criteria

- [ ] `.metadata/agreed-trend-candidates.json` created with 52 candidates
- [ ] JSON structure matches schema
- [ ] trend-candidates.md status updated to `agreed`
- [ ] Both files validated
- [ ] Success message output to user

---

## Files Created/Modified

| File | Action | Content |
|------|--------|---------|
| `.metadata/agreed-trend-candidates.json` | Created | 52 agreed candidates in JSON |
| `02-refined-questions/data/trend-candidates.md` | Modified | Status → `agreed`, added `agreed_at` |

---

## Integration Point

The `dimension-planner` skill will:

1. Check for `.metadata/agreed-trend-candidates.json` in Phase 2
2. If present: Load 52 candidates, skip Step 4.5 (Trend Candidate Planning)
3. If absent: Halt with instruction to run `tips-selection` first

---

## Error Handling

| Scenario | Response |
|----------|----------|
| JSON write fails | Retry write |
| Status update fails | Retry edit |
| Candidate count mismatch | Exit 1, return to Phase 3 |
| File validation fails | Log error, retry |

---

## Skill Complete

After Phase 4 completes successfully, the `tips-selection` skill is done.

User can now:
1. Review the selection in `02-refined-questions/data/trend-candidates.md`
2. Invoke `dimension-planner` to continue research planning
