#!/usr/bin/env bash
set -euo pipefail
#
# parse-candidates-md.sh
# Parses tips-candidates.md and extracts selected candidates to JSON
#
# Usage:
#   bash parse-candidates-md.sh --file <tips-candidates.md> [--json]
#
# Returns:
#   JSON object with selected candidates
#   Exit 0: Success
#   Exit 1: Error
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

# Initialize
CANDIDATES_JSON="[]"
CURRENT_DIM=""
CURRENT_HORIZON=""
SEQUENCE=0

# Read file and extract selected candidates
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
    SEQUENCE=0
  elif [[ "$line" =~ "### Horizon: Plan" ]]; then
    CURRENT_HORIZON="plan"
    SEQUENCE=0
  elif [[ "$line" =~ "### Horizon: Observe" ]]; then
    CURRENT_HORIZON="observe"
    SEQUENCE=0
  fi

  # Parse selected rows (lines with [x] or [X])
  if [[ -n "$CURRENT_DIM" && -n "$CURRENT_HORIZON" ]]; then
    if [[ "$line" =~ ^\|[[:space:]]*\[x\] ]] || [[ "$line" =~ ^\|[[:space:]]*\[X\] ]]; then
      SEQUENCE=$((SEQUENCE + 1))

      # Parse table row: | [x] | # | Trend Name | Keywords | Rationale | More? |
      # Remove leading/trailing pipes and split
      row="$(echo "$line" | sed 's/^|//' | sed 's/|$//')"

      # Extract fields (simplified parsing)
      trend_name="$(echo "$row" | awk -F'|' '{print $3}' | xargs)"
      keywords="$(echo "$row" | awk -F'|' '{print $4}' | xargs)"
      rationale="$(echo "$row" | awk -F'|' '{print $5}' | xargs)"

      # Build candidate JSON
      candidate="{\"dimension\": \"$CURRENT_DIM\", \"horizon\": \"$CURRENT_HORIZON\", \"sequence\": $SEQUENCE, \"trend_name\": \"$trend_name\", \"keywords\": \"$keywords\", \"rationale\": \"$rationale\", \"source\": \"generated\"}"

      # Append to array (simplified - in production use jq)
      if [[ "$CANDIDATES_JSON" == "[]" ]]; then
        CANDIDATES_JSON="[$candidate]"
      else
        CANDIDATES_JSON="${CANDIDATES_JSON%]}, $candidate]"
      fi
    fi
  fi
done < "$FILE_PATH"

# Extract metadata from frontmatter
INDUSTRY_SECTOR="$(grep -E "^industry_sector:" "$FILE_PATH" | sed 's/industry_sector: *//' | tr -d '"' || echo "unknown")"

# Build final output
if [[ "$JSON_OUTPUT" == true ]]; then
  TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "{\"success\": true, \"data\": {\"metadata\": {\"industry_sector\": \"$INDUSTRY_SECTOR\", \"parsed_at\": \"$TIMESTAMP\"}, \"candidates\": $CANDIDATES_JSON}}"
else
  echo "Parsed candidates:"
  echo "$CANDIDATES_JSON"
fi
