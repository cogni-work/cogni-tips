# Phase 2: Present Candidates

**Reference Checksum:** `sha256:tips-sel-p2-present-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-2-present.md | Checksum: tips-sel-p2-present-v1
```

---

## Objective

Write `trend-candidates.md` to the project with all 60 candidates formatted for user selection, then PAUSE for user input.

**Expected Duration:** 15-20 seconds (file write)

---

## Entry Gate

Before proceeding, verify Phase 1 outputs:

- [ ] 60 candidates generated and stored in memory
- [ ] All candidates include trend_name, keywords, rationale
- [ ] INDUSTRY_SECTOR available

**If any missing:** STOP. Return to Phase 1.

---

## Step 2.1: Initialize Phase

```bash
log_phase "Phase 2: Present Candidates" "start"
log_conditional INFO "Writing trend-candidates.md to project"
```

---

## Step 2.2: Build File Content

Use the template from [../../templates/trend-candidates-template.md](../../templates/trend-candidates-template.md) and populate with generated candidates.

### File Structure

```markdown
---
status: draft
industry_sector: "${INDUSTRY_SECTOR}"
generated_at: ${ISO_TIMESTAMP}
total_candidates: 60
selected_count: 0
---

# TIPS Candidate Selection

**Industry:** ${INDUSTRY_SECTOR}
**Status:** DRAFT - Awaiting your selection

## Instructions

1. Mark candidates with `[x]` to select (5 ACT + 5 PLAN + 3 OBSERVE per dimension = 52 total)
2. Add your own candidates in "User Proposed" section at the bottom
3. Request more candidates: Add `[+N]` in the "More?" column (e.g., `[+3]`)
4. Re-invoke `tips-selection` skill when ready

---

## Dimension: Externe Effekte (External Effects)

### Horizon: Act (0-2 years) — Select 5

| Select | # | Trend Name | Keywords | Rationale | More? |
|--------|---|------------|----------|-----------|-------|
| [ ] | 1 | ${CANDIDATE_1_NAME} | ${KEYWORDS_1} | ${RATIONALE_1} | |
| [ ] | 2 | ${CANDIDATE_2_NAME} | ${KEYWORDS_2} | ${RATIONALE_2} | |
| [ ] | 3 | ${CANDIDATE_3_NAME} | ${KEYWORDS_3} | ${RATIONALE_3} | |
| [ ] | 4 | ${CANDIDATE_4_NAME} | ${KEYWORDS_4} | ${RATIONALE_4} | |
| [ ] | 5 | ${CANDIDATE_5_NAME} | ${KEYWORDS_5} | ${RATIONALE_5} | |

### Horizon: Plan (2-5 years) — Select 5

| Select | # | Trend Name | Keywords | Rationale | More? |
|--------|---|------------|----------|-----------|-------|
| [ ] | 1 | ... | ... | ... | |
...

### Horizon: Observe (5+ years) — Select 3

| Select | # | Trend Name | Keywords | Rationale | More? |
|--------|---|------------|----------|-----------|-------|
| [ ] | 1 | ... | ... | ... | |
...

---

## Dimension: Neue Horizonte (New Horizons)

[SAME STRUCTURE AS ABOVE]

---

## Dimension: Digitale Wertetreiber (Digital Value Drivers)

[SAME STRUCTURE AS ABOVE]

---

## Dimension: Digitales Fundament (Digital Foundation)

[SAME STRUCTURE AS ABOVE]

---

## User Proposed Candidates

Add your own candidates below. They will be validated for industry fit.

| Dimension | Horizon | Trend Name | Keywords | Rationale |
|-----------|---------|------------|----------|-----------|
| | | | | |

**Valid dimension values:** externe-effekte, neue-horizonte, digitale-wertetreiber, digitales-fundament
**Valid horizon values:** act, plan, observe

---

## Selection Summary

| Dimension | Act | Plan | Observe | Total |
|-----------|-----|------|---------|-------|
| externe-effekte | 0/5 | 0/5 | 0/3 | 0/13 |
| neue-horizonte | 0/5 | 0/5 | 0/3 | 0/13 |
| digitale-wertetreiber | 0/5 | 0/5 | 0/3 | 0/13 |
| digitales-fundament | 0/5 | 0/5 | 0/3 | 0/13 |
| **TOTAL** | 0/20 | 0/20 | 0/12 | **0/52** |
```

---

## Step 2.3: Write File

Write the populated content to the project:

```bash
TIPS_CANDIDATES_FILE="${PROJECT_PATH}/02-refined-questions/data/trend-candidates.md"

# Use Write tool to create the file
# (LLM executes Write tool with populated content)

log_conditional INFO "Written: ${TIPS_CANDIDATES_FILE}"
log_conditional INFO "Total candidates: 60 (5 per cell × 12 cells)"
```

---

## Step 2.4: Mark Phase 2 Complete

```bash
log_phase "Phase 2: Present Candidates" "complete"
```

---

## Step 2.5: PAUSE and Instruct User

**CRITICAL:** After writing the file, output clear instructions to the user and STOP:

```text
---

## TIPS Candidate Selection Ready

I've generated 60 trend candidates for your ${INDUSTRY_SECTOR} research project.

**File created:** `02-refined-questions/data/trend-candidates.md`

### Your Next Steps:

1. **Open** the file `02-refined-questions/data/trend-candidates.md`

2. **Select** candidates by changing `[ ]` to `[x]}
   - 5 per ACT horizon, 5 per PLAN horizon, 3 per OBSERVE horizon per dimension
   - Total selections needed: 52 (4 dimensions × 13 per dimension)

3. **Optionally** add your own candidates in the "User Proposed" section

4. **Optionally** request more candidates by adding `[+N]` in the "More?" column
   - Example: `[+3]` to generate 3 more candidates for that cell

5. **Re-invoke** this skill when ready:
   - Just ask me to continue with tips-selection
   - Or invoke: `tips-selection`

---

**Current Selection:** 0/52
**Status:** Awaiting your selections

---
```

**⛔ STOP EXECUTION HERE** - Do not proceed to Phase 3 until user re-invokes the skill.

---

## Success Criteria

- [ ] trend-candidates.md written to `02-refined-questions/data/`
- [ ] File contains all 60 candidates in correct format
- [ ] All tables have selection checkboxes
- [ ] User Proposed section included
- [ ] Selection Summary table included
- [ ] Clear instructions provided to user
- [ ] Execution paused for user input

---

## File Validation

Before pausing, verify the file was written correctly:

```bash
if [ -f "$TIPS_CANDIDATES_FILE" ]; then
  # Count candidate rows (should be 60)
  candidate_count=$(grep -c "^\| \[ \]" "$TIPS_CANDIDATES_FILE")
  if [ "$candidate_count" -eq 60 ]; then
    log_conditional INFO "File validation passed: 60 candidate rows"
  else
    log_conditional WARN "Candidate count mismatch: expected 60, found ${candidate_count}"
  fi
else
  log_conditional ERROR "File not written: ${TIPS_CANDIDATES_FILE}"
  exit 1
fi
```

---

## Next Phase

User will edit `trend-candidates.md` and re-invoke the skill.

Upon re-invocation:
- Phase 0 will detect existing file with status `draft`
- Phase 0 will set SKIP_TO_PHASE=3
- Proceed to [phase-3-process.md](phase-3-process.md)

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Write tool fails | Retry write |
| Directory doesn't exist | Create 02-refined-questions/data/ first |
| Candidate data missing | Return to Phase 1 |
