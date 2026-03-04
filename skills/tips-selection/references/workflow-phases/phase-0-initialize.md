# Phase 0: Initialize & Load Context

**Reference Checksum:** `sha256:tips-sel-p0-init-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-0-initialize.md | Checksum: tips-sel-p0-init-v1
```

---

## Objective

Initialize the tips-selection workflow by loading project context and validating prerequisites.

**Expected Duration:** 10-15 seconds

---

## Step 0.1: Extract PROJECT_PATH

Extract the project path from the question file provided by the user:

```bash
# User provides question file path, extract project root
QUESTION_FILE="$1"  # e.g., /path/to/project/00-initial-question/data/question-foo-abc123.md
PROJECT_PATH=$(dirname "$(dirname "$QUESTION_FILE")")

# Validate project structure
if [ ! -d "$PROJECT_PATH/$DIR_INITIAL_QUESTION" ]; then
  echo "ERROR: Invalid project structure - missing $DIR_INITIAL_QUESTION/"
  exit 1
fi
```

---

## Step 0.2: Read Question Frontmatter

Read the question file and extract key metadata:

```bash
# Read question file
QUESTION_CONTENT=$(cat "$QUESTION_FILE")

# Extract frontmatter fields
RESEARCH_TYPE=$(echo "$QUESTION_CONTENT" | grep -E "^research_type:" | sed 's/research_type: *//' | tr -d '"')
INDUSTRY_SECTOR=$(echo "$QUESTION_CONTENT" | grep -E "^industry_sector:" | sed 's/industry_sector: *//' | tr -d '"')
RESEARCH_CONTEXT=$(echo "$QUESTION_CONTENT" | grep -A50 "^research_context:" | head -50)
```

---

## Step 0.3: Validate Research Type

Ensure this is a smarter-service research project:

```bash
if [ "$RESEARCH_TYPE" != "smarter-service" ]; then
  echo "ERROR: tips-selection skill only supports research_type: smarter-service"
  echo "Found: research_type: $RESEARCH_TYPE"
  exit 1
fi
```

---

## Step 0.4: Extract or Request Industry Sector

**Priority order:**

1. Explicit `industry_sector` field in frontmatter
2. Extract from `research_context` text
3. Prompt user to provide

### MANDATORY: Thinking Block Template

Use extended thinking to extract industry sector if not explicit:

<thinking>
**Industry Sector Extraction**

Checking frontmatter for explicit industry_sector field:
- Field present: [YES/NO]
- Value: [VALUE or "not found"]

If not found, analyzing research_context for industry indicators:
- Context excerpt: "[FIRST 200 CHARS]"
- Industry keywords detected: [LIST]
- Inferred sector: [SECTOR]
- Confidence: [HIGH/MEDIUM/LOW]

Final industry_sector value: [VALUE]
</thinking>

```bash
if [ -z "$INDUSTRY_SECTOR" || "$INDUSTRY_SECTOR" == "null" ]; then
  # Attempt extraction from research_context
  # (LLM performs this using extended thinking above)

  if [ -z "$INDUSTRY_SECTOR" ]; then
    echo "WARNING: industry_sector not found in frontmatter or context"
    echo "Please provide the industry sector for this research project:"
    # User must provide industry_sector to continue
    exit 0  # Pause for user input
  fi
fi

log_conditional INFO "Industry sector: $INDUSTRY_SECTOR"
```

---

## Step 0.5: Create Required Directories

```bash
# Create refined-questions directory if it doesn't exist
mkdir -p "${PROJECT_PATH}/$DIR_QUESTIONS"

# Create .logs directory for skill logging
mkdir -p "${PROJECT_PATH}/.logs"

# Create .metadata directory if needed
mkdir -p "${PROJECT_PATH}/.metadata"

log_conditional INFO "Created required directories"
```

---

## Step 0.6: Initialize Logging

```bash
# Source enhanced logging utility (if available)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname $(dirname $(dirname $(dirname "$0"))))}"
if [ -f "${PLUGIN_ROOT}/scripts/utils/enhanced-logging.sh" ]; then
  source "${PLUGIN_ROOT}/scripts/utils/enhanced-logging.sh"
fi

# Initialize skill-specific log file
SKILL_NAME="tips-selection"
LOG_FILE="${PROJECT_PATH}/.logs/${SKILL_NAME}-execution-log.txt"

# Log initialization
log_phase "Phase 0: Initialize & Load Context" "start"
log_conditional INFO "Skill: tips-selection"
log_conditional INFO "Project: ${PROJECT_PATH}"
log_conditional INFO "Question file: ${QUESTION_FILE}"
log_conditional INFO "Research type: ${RESEARCH_TYPE}"
log_conditional INFO "Industry sector: ${INDUSTRY_SECTOR}"
```

---

## Step 0.7: Configure Web Research

Set web research configuration (enabled by default):

```bash
# Web research is enabled by default
# Can be disabled via question frontmatter: web_research: false
WEB_RESEARCH_ENABLED=$(echo "$QUESTION_CONTENT" | grep -E "^web_research:" | sed 's/web_research: *//' | tr -d '"')

if [ -z "$WEB_RESEARCH_ENABLED" || "$WEB_RESEARCH_ENABLED" = "true" ]; then
  WEB_RESEARCH_ENABLED=true
  log_conditional INFO "Web research: ENABLED (live search before generation)"
else
  WEB_RESEARCH_ENABLED=false
  log_conditional INFO "Web research: DISABLED (training-only generation)"
fi
```

---

## Step 0.8: Check for Existing Selection

Check if trend-candidates.md already exists (for re-invocation):

```bash
TIPS_CANDIDATES_FILE="${PROJECT_PATH}/02-refined-questions/data/trend-candidates.md"

if [ -f "$TIPS_CANDIDATES_FILE" ]; then
  # Check status in frontmatter
  EXISTING_STATUS=$(grep -E "^status:" "$TIPS_CANDIDATES_FILE" | sed 's/status: *//' | tr -d '"')

  if [ "$EXISTING_STATUS" == "agreed" ]; then
    log_conditional INFO "trend-candidates.md already agreed - nothing to do"
    log_conditional INFO "To re-select, delete the file or change status to 'draft'"
    exit 0
  elif [ "$EXISTING_STATUS" == "draft" || "$EXISTING_STATUS" == "pending_review" ]; then
    log_conditional INFO "Existing trend-candidates.md found with status: $EXISTING_STATUS"
    log_conditional INFO "Proceeding to Phase 3 (Process User Selection)"
    SKIP_TO_PHASE=3
  fi
else
  # No existing file - determine if web research should run
  if [ "$WEB_RESEARCH_ENABLED" = "true" ]; then
    SKIP_TO_PHASE=0.5
    log_conditional INFO "No existing trend-candidates.md - starting fresh with web research"
  else
    SKIP_TO_PHASE=1
    log_conditional INFO "No existing trend-candidates.md - starting fresh (training-only)"
  fi
fi
```

---

## Step 0.9: Mark Phase 0 Complete

```bash
log_phase "Phase 0: Initialize & Load Context" "complete"
```

---

## Success Criteria

- [ ] PROJECT_PATH extracted and validated
- [ ] RESEARCH_TYPE confirmed as `smarter-service`
- [ ] INDUSTRY_SECTOR extracted or requested from user
- [ ] Required directories created
- [ ] Logging initialized
- [ ] WEB_RESEARCH_ENABLED configured
- [ ] Existing selection state checked
- [ ] SKIP_TO_PHASE determined (0.5 for new with web research, 1 for new without, 3 for existing)

---

## Variables Set

| Variable | Description | Example |
|----------|-------------|---------|
| PROJECT_PATH | Root path of research project | `/users/foo/research-project` |
| QUESTION_FILE | Path to question file | `/.../00-initial-question/data/question-foo.md` |
| RESEARCH_TYPE | Must be `smarter-service` | `smarter-service` |
| INDUSTRY_SECTOR | Target industry for candidates | `manufacturing` |
| LOG_FILE | Path to execution log | `/.../tips-selection-execution-log.txt` |
| WEB_RESEARCH_ENABLED | Whether to run web research | `true` or `false` |
| SKIP_TO_PHASE | Next phase to execute | `0.5`, `1`, or `3` |
| TIPS_CANDIDATES_FILE | Path to trend-candidates.md | `/.../02-refined-questions/data/trend-candidates.md` |

---

## Next Phase

- If `SKIP_TO_PHASE=0.5` (new + web research enabled): Proceed to [phase-0.5-web-research.md](phase-0.5-web-research.md)
- If `SKIP_TO_PHASE=1` (new + web research disabled): Proceed to [phase-1-generate.md](phase-1-generate.md)
- If `SKIP_TO_PHASE=3` (existing selection): Proceed to [phase-3-process.md](phase-3-process.md)

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Invalid project structure | Exit 1 |
| research_type not smarter-service | Exit 1 |
| industry_sector not found | Exit 0 (pause for user input) |
| trend-candidates.md already agreed | Exit 0 (nothing to do) |
