# Phase 3: Process User Selection

**Reference Checksum:** `sha256:tips-sel-p3-process-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-3-process.md | Checksum: tips-sel-p3-process-v1
```

---

## Objective

Parse user selections from `trend-candidates.md`, validate the selection counts, process any regeneration requests, and iterate until exactly 52 candidates are selected (5 ACT + 5 PLAN + 3 OBSERVE per dimension).

**Expected Duration:** 20-60 seconds (depends on validation iterations)

---

## Entry Gate

Before proceeding, verify:

- [ ] `trend-candidates.md` exists in `02-refined-questions/data/`
- [ ] File status is `draft` or `pending_review`
- [ ] User has edited the file (marked selections)

**If file doesn't exist:** Return to Phase 1-2.
**If status is `agreed`:** Nothing to do, exit.

---

## Step 3.1: Initialize Phase

```bash
log_phase "Phase 3: Process User Selection" "start"
TIPS_CANDIDATES_FILE="${PROJECT_PATH}/02-refined-questions/data/trend-candidates.md"

if [ ! -f "$TIPS_CANDIDATES_FILE" ]; then
  log_conditional ERROR "trend-candidates.md not found - run Phase 1-2 first"
  exit 1
fi

log_conditional INFO "Reading: ${TIPS_CANDIDATES_FILE}"
```

---

## Step 3.2: Parse Selected Candidates

Read the file and extract all marked selections:

### Parsing Logic

```bash
cat > /tmp/tips-p3-parse-selected.sh << 'SCRIPT_EOF'
#!/usr/bin/env bash
set -eo pipefail

# Parse all rows marked with [x]
# Format: | [x] | # | Trend Name | Keywords | Rationale | More? |

# Extract selected candidates
SELECTED_CANDIDATES=()
while IFS= read -r line; do
  if [[ "$line" =~ ^\|[[:space:]]*\[x\] ]]; then
    # Extract: sequence, trend_name, keywords, rationale
    # Determine dimension and horizon from section headers above
    SELECTED_CANDIDATES+=("$parsed_candidate")
  fi
done < "$TIPS_CANDIDATES_FILE"

SELECTED_COUNT=${#SELECTED_CANDIDATES[@]}
log_conditional INFO "Parsed ${SELECTED_COUNT} selected candidates"
SCRIPT_EOF
chmod +x /tmp/tips-p3-parse-selected.sh && bash /tmp/tips-p3-parse-selected.sh
```

### MANDATORY: Thinking Block for Parsing

<thinking>
**Parsing User Selections**

Reading trend-candidates.md sections:

**Dimension: externe-effekte**
- Act (0-2y): Selected = [LIST NUMBERS]
- Plan (2-5y): Selected = [LIST NUMBERS]
- Observe (5+y): Selected = [LIST NUMBERS]

**Dimension: neue-horizonte**
- Act (0-2y): Selected = [LIST NUMBERS]
- Plan (2-5y): Selected = [LIST NUMBERS]
- Observe (5+y): Selected = [LIST NUMBERS]

**Dimension: digitale-wertetreiber**
- Act (0-2y): Selected = [LIST NUMBERS]
- Plan (2-5y): Selected = [LIST NUMBERS]
- Observe (5+y): Selected = [LIST NUMBERS]

**Dimension: digitales-fundament**
- Act (0-2y): Selected = [LIST NUMBERS]
- Plan (2-5y): Selected = [LIST NUMBERS]
- Observe (5+y): Selected = [LIST NUMBERS]

**Selection Summary:**
- Total selected: [COUNT]
- Expected: 52 (5 ACT + 5 PLAN + 3 OBSERVE per dimension)
- Status: [VALID/INVALID]
</thinking>

---

## Step 3.3: Parse User Proposed Candidates

Check for user-proposed candidates in the "User Proposed" section:

```bash
cat > /tmp/tips-p3-parse-proposed.sh << 'SCRIPT_EOF'
#!/usr/bin/env bash
set -eo pipefail

# Parse "User Proposed Candidates" table
# Format: | Dimension | Horizon | Trend Name | Keywords | Rationale |

USER_PROPOSED=()
in_user_proposed=false
while IFS= read -r line; do
  if [[ "$line" =~ "## User Proposed Candidates" ]]; then
    in_user_proposed=true
    continue
  fi
  if [ "$in_user_proposed" = true ] && [[ "$line" =~ ^\|[[:space:]]*[a-z] ]]; then
    # Parse dimension, horizon, trend_name, keywords, rationale
    USER_PROPOSED+=("$parsed_proposal")
  fi
done < "$TIPS_CANDIDATES_FILE"

USER_PROPOSED_COUNT=${#USER_PROPOSED[@}}
log_conditional INFO "Found ${USER_PROPOSED_COUNT} user-proposed candidates"
SCRIPT_EOF
chmod +x /tmp/tips-p3-parse-proposed.sh && bash /tmp/tips-p3-parse-proposed.sh
```

---

## Step 3.4: Validate User Proposals (Industry Fit)

For each user-proposed candidate, validate it fits the industry sector:

### MANDATORY: Thinking Block for Proposal Validation

<thinking>
**Validating User Proposals for Industry Fit**

Industry sector: ${INDUSTRY_SECTOR}

Proposal 1: [TREND_NAME]
- Dimension: [DIM]
- Horizon: [HORIZON]
- Keywords: [KEYWORDS]
- Industry fit assessment: [ANALYSIS]
- Fit score: [HIGH/MEDIUM/LOW]
- Accept: [YES/NO with reason if NO]

[REPEAT FOR EACH PROPOSAL]

**Summary:**
- Proposals accepted: [COUNT]
- Proposals flagged (off-sector): [COUNT]
</thinking>

If proposal seems off-sector, warn but allow user override:

```text
WARNING: User proposal "[TREND_NAME]" may not fit industry "${INDUSTRY_SECTOR}".
Keywords: [KEYWORDS]
Proceeding anyway (user override assumed).
```

---

## Step 3.5: Parse Regeneration Requests

Check for `[+N]` markers in the "More?" column:

```bash
cat > /tmp/tips-p3-parse-regen.sh << 'SCRIPT_EOF'
#!/usr/bin/env bash
set -eo pipefail

# Parse regeneration requests
# Format: | [ ] | # | Trend Name | Keywords | Rationale | [+3] |

REGENERATION_REQUESTS=()
while IFS= read -r line; do
  if [[ "$line" =~ \[\+([0-9]+)\] ]]; then
    count="${BASH_REMATCH[1]}"
    # Determine dimension and horizon from context
    REGENERATION_REQUESTS+=("${dimension}:${horizon}:${count}")
  fi
done < "$TIPS_CANDIDATES_FILE"

if [ ${#REGENERATION_REQUESTS[@]} -gt 0 ]; then
  log_conditional INFO "Regeneration requests: ${REGENERATION_REQUESTS[*]}"
fi
SCRIPT_EOF
chmod +x /tmp/tips-p3-parse-regen.sh && bash /tmp/tips-p3-parse-regen.sh
```

---

## Step 3.6: Validate Selection Counts

Check that horizon-specific counts are met (5 ACT, 5 PLAN, 3 OBSERVE per dimension):

```bash
# Expected: 5 ACT + 5 PLAN + 3 OBSERVE per dimension = 13 per dimension, 52 total
# Bash 3.2 compatible - use parallel indexed arrays
CELL_KEYS=()
CELL_COUNTS=()
CELL_EXPECTED=()

for dim in externe-effekte neue-horizonte digitale-wertetreiber digitales-fundament; do
  for horizon in act plan observe; do
    cell_key="${dim}:${horizon}"
    CELL_KEYS+=("$cell_key")
    CELL_COUNTS+=("$(count_selected "$dim" "$horizon")")
    # Horizon-specific expected counts
    case "$horizon" in
      act|plan) CELL_EXPECTED+=(5) ;;
      observe) CELL_EXPECTED+=(3) ;;
    esac
  done
done

# Validate each cell against horizon-specific expected count
INVALID_CELLS=()
for i in "${!CELL_KEYS[@]}"; do
  cell_key="${CELL_KEYS[$i]}"
  count="${CELL_COUNTS[$i]}"
  expected="${CELL_EXPECTED[$i]}"
  if [ "$count" -ne "$expected" ]; then
    INVALID_CELLS+=("${cell_key}:${count}:expected_${expected}")
  fi
done

TOTAL_SELECTED=$(sum_all_counts)
```

---

## Step 3.7: Handle Validation Results

### Case A: Selection Valid (52 total, horizon-specific counts)

```bash
if [ ${#INVALID_CELLS[@]} -eq 0 ] && [ "$TOTAL_SELECTED" -eq 52 ]; then
  log_conditional INFO "Selection valid: 52 candidates (5 ACT + 5 PLAN + 3 OBSERVE per dimension)"
  log_conditional INFO "Proceeding to Phase 4"
  # Continue to Phase 4
fi
```

### Case B: Selection Invalid

Report errors and pause for user correction:

```text
---

## Selection Validation Failed

**Total selected:** ${TOTAL_SELECTED}/52

### Cells with Invalid Counts:

| Dimension | Horizon | Selected | Required |
|-----------|---------|----------|----------|
| ${DIM} | ${HORIZON} | ${COUNT} | ${EXPECTED} |

**Note:** Required counts are horizon-specific: ACT=5, PLAN=5, OBSERVE=3
...

### Required Actions:

1. Open `02-refined-questions/data/trend-candidates.md`
2. Adjust selections in the cells listed above
3. Re-invoke `tips-selection` skill

---
```

**⛔ PAUSE** - Wait for user to correct selections.

### Case C: Regeneration Requested

If user requested more candidates via `[+N]`:

1. Generate N additional candidates for the specified cell
2. Append new candidates to the cell's table in trend-candidates.md
3. Clear the `[+N]` marker
4. Update status to `pending_review`
5. **PAUSE** for user to review new candidates

```text
---

## New Candidates Generated

I've added ${N} new candidates to the following cells:

| Dimension | Horizon | New Candidates |
|-----------|---------|----------------|
| ${DIM} | ${HORIZON} | ${N} added |
...

### Your Next Steps:

1. Review the new candidates in `02-refined-questions/data/trend-candidates.md`
2. Adjust your selections (5 ACT, 5 PLAN, 3 OBS per dimension)
3. Re-invoke `tips-selection` skill

---
```

---

## Step 3.8: Incorporate User Proposals

If user proposed candidates and they're validated:

1. Add proposals to the appropriate cells
2. Auto-select them (mark with `[x]`) if user wants
3. Update candidate count in that cell

```bash
for proposal in "${USER_PROPOSED[@]}"; do
  # Add to appropriate cell
  # Mark as user-proposed (source: user_proposed)
  log_conditional INFO "Added user proposal: ${proposal_name} to ${dim}:${horizon}"
done
```

---

## Step 3.9: Update trend-candidates.md (if changes made)

If regeneration occurred or proposals were added:

```bash
# Rewrite trend-candidates.md with:
# - New candidates from regeneration
# - User proposals incorporated
# - Updated counts in Selection Summary
# - Status changed to pending_review

log_conditional INFO "Updated trend-candidates.md with changes"
```

---

## Step 3.10: Mark Phase 3 Complete (if valid)

Only if selection is valid:

```bash
if [ "$SELECTION_VALID" == true ]; then
  log_phase "Phase 3: Process User Selection" "complete"
  log_metric "candidates_selected" "52" "count"
  log_metric "user_proposals_accepted" "${USER_PROPOSED_COUNT}" "count"
fi
```

---

## Success Criteria (to proceed to Phase 4)

- [ ] 52 total candidates selected
- [ ] Horizon-specific counts met: 5 ACT, 5 PLAN, 3 OBSERVE per dimension
- [ ] User proposals validated and incorporated
- [ ] Regeneration requests processed (if any)
- [ ] No invalid cells remaining

---

## Iteration Pattern

```text
User edits file → Phase 3 validates → Invalid? → User corrects → Phase 3 validates → ...
                                    ↓
                                  Valid → Phase 4
```

---

## Next Phase

If validation passes: Proceed to [phase-4-finalize.md](phase-4-finalize.md)

If validation fails: PAUSE and wait for user correction.

---

## Error Handling

| Scenario | Response |
|----------|----------|
| File not found | Exit 1, return to Phase 1-2 |
| Parse error | Log error, try manual extraction |
| Selection count wrong | Report errors, PAUSE for user |
| Regeneration fails | Log warning, continue with existing candidates |
| User proposal off-sector | Warn, allow override |
