#!/usr/bin/env bash
set -euo pipefail
#
# validate-selection.sh
# Version: 1.0.0
# Purpose: Validates TIPS candidate selection counts from tips-candidates.md
#
# Usage:
#   bash validate-selection.sh --file <tips-candidates.md> [--json]
#
# Returns:
#   JSON object with validation results
#
# Exit codes:
#   0 - Valid selection (52 candidates: 5 ACT + 5 PLAN + 3 OBSERVE per dimension)
#   1 - Invalid selection or error
#


# Defaults
FILE_PATH=""
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      FILE_PATH="$2"
      shift 2
      ;;
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$FILE_PATH" ]]; then
  echo '{"success": false, "error": "Missing required argument: --file"}' >&2
  exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "{\"success\": false, \"error\": \"File not found: $FILE_PATH\"}" >&2
  exit 1
fi

# Initialize counters
# Bash 3.2 compatible - indexed arrays (declare -A requires Bash 4.0+)
CELL_KEYS=()
CELL_VALUES=()

# Helper function to get count for a cell key
get_cell_count() {
  local key="$1"
  local i=0
  for k in "${CELL_KEYS[@]}"; do
    if [[ "$k" == "$key" ]]; then
      echo "${CELL_VALUES[$i]}"
      return 0
    fi
    i=$((i + 1))
  done
  echo "0"
}

# Helper function to increment count for a cell key
increment_cell_count() {
  local key="$1"
  local i=0
  for k in "${CELL_KEYS[@]}"; do
    if [[ "$k" == "$key" ]]; then
      CELL_VALUES[$i]=$((CELL_VALUES[$i] + 1))
      return
    fi
    i=$((i + 1))
  done
  # Key not found, add new entry
  CELL_KEYS+=("$key")
  CELL_VALUES+=("1")
}

TOTAL_SELECTED=0
DIMENSIONS=("externe-effekte" "neue-horizonte" "digitale-wertetreiber" "digitales-fundament")
HORIZONS=("act" "plan" "observe")

# Current parsing context
CURRENT_DIM=""
CURRENT_HORIZON=""

# Read file and count selections
while IFS= read -r line; do
  # Detect dimension headers
  if [[ "$line" =~ "## Dimension: Externe Effekte" ]]; then
    CURRENT_DIM="externe-effekte"
  elif [[ "$line" =~ "## Dimension: Neue Horizonte" ]]; then
    CURRENT_DIM="neue-horizonte"
  elif [[ "$line" =~ "## Dimension: Digitale Wertetreiber" ]]; then
    CURRENT_DIM="digitale-wertetreiber"
  elif [[ "$line" =~ "## Dimension: Digitales Fundament" ]]; then
    CURRENT_DIM="digitales-fundament"
  fi

  # Detect horizon headers
  if [[ "$line" =~ "### Horizon: Act" ]]; then
    CURRENT_HORIZON="act"
  elif [[ "$line" =~ "### Horizon: Plan" ]]; then
    CURRENT_HORIZON="plan"
  elif [[ "$line" =~ "### Horizon: Observe" ]]; then
    CURRENT_HORIZON="observe"
  fi

  # Count selections (lines with [x])
  if [[ -n "$CURRENT_DIM" && -n "$CURRENT_HORIZON" ]]; then
    if [[ "$line" =~ ^\|[[:space:]]*\[x\] ]] || [[ "$line" =~ ^\|[[:space:]]*\[X\] ]]; then
      cell_key="${CURRENT_DIM}:${CURRENT_HORIZON}"
      increment_cell_count "$cell_key"
      TOTAL_SELECTED=$((TOTAL_SELECTED + 1))
    fi
  fi
done < "$FILE_PATH"

# Validate counts with horizon-specific expected values
# ACT: 5, PLAN: 5, OBSERVE: 3 per dimension
INVALID_CELLS=()
VALID=true

for dim in "${DIMENSIONS[@]}"; do
  for horizon in "${HORIZONS[@]}"; do
    cell_key="${dim}:${horizon}"
    count=$(get_cell_count "$cell_key")
    # Horizon-specific expected counts
    case "$horizon" in
      act|plan) expected=5 ;;
      observe) expected=3 ;;
    esac
    if [[ "$count" -ne "$expected" ]]; then
      INVALID_CELLS+=("{\"dimension\": \"$dim\", \"horizon\": \"$horizon\", \"selected\": $count, \"required\": $expected}")
      VALID=false
    fi
  done
done

# Build JSON output
if [[ "$JSON_OUTPUT" == true ]]; then
  if [[ "$VALID" == true ]]; then
    echo "{\"success\": true, \"data\": {\"total_selected\": $TOTAL_SELECTED, \"valid\": true, \"invalid_cells\": []}}"
    exit 0
  else
    invalid_json="$(printf '%s,' "${INVALID_CELLS[@]}" | sed 's/,$//')"
    echo "{\"success\": true, \"data\": {\"total_selected\": $TOTAL_SELECTED, \"valid\": false, \"invalid_cells\": [$invalid_json]}}"
    exit 1
  fi
else
  if [[ "$VALID" == true ]]; then
    echo "Selection valid: $TOTAL_SELECTED candidates (5 ACT + 5 PLAN + 3 OBSERVE per dimension)"
    exit 0
  else
    echo "Selection invalid: $TOTAL_SELECTED candidates selected"
    echo "Invalid cells:"
    for cell_info in "${INVALID_CELLS[@]}"; do
      echo "  $cell_info"
    done
    exit 1
  fi
fi
