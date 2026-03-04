---
name: trend-report
description: |
  Generate a narrative TIPS trend report with inline citations and verifiable claims from trend-scout output. Reads agreed trend candidates, enriches each with web-sourced quantitative evidence via parallel agents, assembles a full report with executive summary and portfolio analysis, generates a trend-panorama insight summary via cogni-narrative, and invokes cogni-claims:claim-work for automated verification. Use when: (1) trend-scout has completed and candidates are agreed, (2) User wants a written trend report, (3) User mentions "trend report", "TIPS report", "write up trends", (4) Preparing a deliverable from scouted trends.
---

# Trend Report

Generate a narrative TIPS trend report from agreed trend-scout candidates. Dispatches 4 parallel agents (one per TIPS dimension) to enrich trends with web-sourced quantitative evidence, then assembles a full report with executive summary, dimension sections, portfolio analysis, and a claims registry for automated verification.

## Purpose

This skill enables users to:

1. Transform agreed trend-scout candidates into a narrative report
2. Enrich each trend with quantitative evidence from web research
3. Generate inline citations for every quantitative claim
4. Produce a claims registry compatible with `cogni-claims:claim-work`
5. Generate a trend-panorama narrative insight summary via cogni-narrative
6. Verify claims automatically via cogni-claims:claim-work

## Bilingual Support

Full German and English support throughout:

- Language auto-detected from `trend-scout-output.json` config
- All section headers and TIPS labels have EN/DE variants
- Report prose written in the target language
- Web searches executed bilingually (EN + DE) for maximum coverage
- German text uses proper umlauts (never ASCII transliterations)

## Prerequisites

- `trend-scout` skill completed with `execution.workflow_state == "agreed"` and 52 candidates
- Web access enabled for evidence enrichment
- Optional: `cogni-narrative` plugin for insight summary generation (graceful fallback if absent)
- `cogni-claims` plugin (for claim verification of trend report citations)

## Shell Execution Constraints

**CRITICAL - Only these shell commands are allowed:**

1. This skill is a pure orchestrator with NO custom scripts
2. All file I/O uses Read/Write tools directly
3. All web research is delegated to agents
4. Allowed Bash commands (exhaustive list):
   - `cat file1 file2 ... > output` — concatenation of log files into final report
   - `rm -f file` — cleanup of stale output files on re-run
   - `[ -f file ]` — existence checks before concatenation
5. Do NOT use `jq`, `sed`, `awk`, `grep`, or any other shell tools for data processing

**Path Variable Distinction:**

| Variable | Purpose | Example |
|----------|---------|---------|
| `CLAUDE_PLUGIN_ROOT` | Plugin installation (skills, references) | `~/.claude/plugins/marketplaces/cogni-tips` |
| `COGNI_RESEARCH_ROOT` | Workspace (project data, outputs) | `~/cogni-research/trends` |

**IMPORTANT - Environment Variables:**

- `COGNI_RESEARCH_ROOT` and `CLAUDE_PLUGIN_ROOT` are automatically injected by Claude Code from `settings.local.json`
- DO NOT source `.workplace-env.sh` - variables are already available at runtime

## References Index

Read references **only when needed** for the specific task:

| Reference | Read when... |
|-----------|--------------|
| [references/report-structure.md](references/report-structure.md) | Assembling the final report (Phase 2) |
| [references/evidence-enrichment.md](references/evidence-enrichment.md) | Configuring agent web search strategy (Phase 1) |
| [references/claims-format.md](references/claims-format.md) | Extracting/merging claims (Phase 1-2) |
| [references/i18n/labels-en.md](references/i18n/labels-en.md) | English report headings and labels |
| [references/i18n/labels-de.md](references/i18n/labels-de.md) | German report headings and labels |
| [references/phase-2.5-insight-summary.md](references/phase-2.5-insight-summary.md) | Generating arc-aware insight summary (Phase 2.5) |

## Immediate Action: Initialize TodoWrite

**MANDATORY:** Initialize TodoWrite immediately with workflow phases:

1. Phase 0: Project Discovery + Input Loading [in_progress]
2. Phase 1: Evidence Enrichment + Section Generation (4 parallel agents) [pending]
3. Phase 2: Report Assembly [pending]
4. Phase 2.5: Insight Summary (trend-panorama) [pending]
5. Phase 3: Claim Verification (optional) [pending]
6. Phase 4: Finalization [pending]

Update todo status as you progress through each phase.

---

## Core Workflow

```text
Phase 0 → Phase 1 → Phase 2 → Phase 2.5 → Phase 3 → Phase 4
   │          │          │         │            │          │
   │          │          │         │            │          └─ Update metadata, display summary
   │          │          │         │            └─ Optional claim-work verification
   │          │          │         └─ Default: trend-panorama narrative via cogni-narrative
   │          │          └─ Exec summary + portfolio analysis + assemble report
   │          └─ 4 parallel agents: enrich trends, write sections, extract claims
   └─ Project discovery, load trend-scout output, validate gate
```

### Phase 0: Project Discovery + Input Loading

**Objective:** Find an eligible trend-scout project and load its output data.

#### Step 0.1: Project Discovery

> **Note:** Trend-scout projects use `trend-scout-output.json` (not `sprint-log.json`), so the shared `project-picker.md` pattern does not apply. Use the custom discovery logic below.

**Custom discovery logic:**

1. If `--project-path` was provided as argument, use it directly
2. Otherwise, run `discover-projects.sh --json` to enumerate all projects
3. For each project, check if `{path}/.metadata/trend-scout-output.json` exists
4. Read the file and check `execution.workflow_state == "agreed"` and `tips_candidates.total >= 52`
5. Collect eligible projects, then branch:
   - 0 eligible: ERROR — "No agreed trend-scout projects found. Run trend-scout first and agree on candidates."
   - 1 eligible: Auto-select
   - 2+ eligible: Present via AskUserQuestion

#### Step 0.2: Load Input Data

Read the following files from the selected project:

```
REQUIRED:
  {PROJECT_PATH}/.metadata/trend-scout-output.json
    → Extract: config.industry (industry/subsector), config.research_topic (topic)
    → Extract: project_language (top-level, NOT config.language)
    → Extract: tips_candidates.items (52 candidates)

OPTIONAL (raw web signals — try sources in order):
  1. {PROJECT_PATH}/.logs/web-research-raw.json
     → Extract: signals from .raw_signals_before_dedup array (full field names)
     → Each signal has: dimension, signal, keywords, source, freshness, indicator_type, source_type
  2. FALLBACK: {PROJECT_PATH}/phase1-research-summary.json
     → Extract: .items array (compact abbreviated fields)
     → Expand: d→dimension, n→signal, k→keywords, u→source, f→freshness, a→authority, t→source_type, i→indicator_type, lt→lead_time
     → Use when web-research-raw.json is missing OR has no .raw_signals_before_dedup array
```

#### Step 0.3: Validate Entry Gate

| Check | Condition | On Failure |
|-------|-----------|------------|
| Output file exists | `.metadata/trend-scout-output.json` present | HALT: Run trend-scout first |
| Workflow state | `execution.workflow_state == "agreed"` | HALT: Complete trend-scout candidate selection first |
| Candidate count | `tips_candidates.total >= 52` | HALT: Expected 52 agreed candidates |
| Config complete | `industry`, `subsector`, `language` present | HALT: Incomplete trend-scout config |

#### Step 0.4: Prepare Agent Inputs

Group the 52 candidates by dimension (4 groups of ~13):

| Dimension Slug | TIPS Role | Expected Count |
|----------------|-----------|----------------|
| `externe-effekte` | T (Trends) | 13 |
| `digitale-wertetreiber` | I (Implications) | 13 |
| `neue-horizonte` | P (Possibilities) | 13 |
| `digitales-fundament` | S (Solutions) | 13 |

For each dimension, prepare:
- Candidate list (JSON array of candidate objects)
- Matching raw web signals (from primary or fallback source loaded in Step 0.2, already expanded to full field names), filtered by `dimension`. Pass "none" if neither source was available.
- Shared config: industry (en/de), subsector (en/de), topic, language

**IMPORTANT:** Use the Read tool + LLM parsing to extract and group candidates. Do NOT use `jq` or any shell JSON processing — see Shell Execution Constraints above.

#### Step 0.5: Load i18n Labels

Read the appropriate labels file based on detected language:
- English: [references/i18n/labels-en.md](references/i18n/labels-en.md)
- German: [references/i18n/labels-de.md](references/i18n/labels-de.md)

#### Step 0.6: Clean Up Stale Output Files

On re-runs, stale files from a previous execution must be removed before Phase 1. Use `rm -f` (allowed per Shell Execution Constraints) to delete all output files:

```bash
rm -f "{PROJECT_PATH}/.logs/report-header.md"
rm -f "{PROJECT_PATH}/.logs/report-section-externe-effekte.md"
rm -f "{PROJECT_PATH}/.logs/report-section-digitale-wertetreiber.md"
rm -f "{PROJECT_PATH}/.logs/report-section-neue-horizonte.md"
rm -f "{PROJECT_PATH}/.logs/report-section-digitales-fundament.md"
rm -f "{PROJECT_PATH}/.logs/claims-externe-effekte.json"
rm -f "{PROJECT_PATH}/.logs/claims-digitale-wertetreiber.json"
rm -f "{PROJECT_PATH}/.logs/claims-neue-horizonte.json"
rm -f "{PROJECT_PATH}/.logs/claims-digitales-fundament.json"
rm -f "{PROJECT_PATH}/.logs/report-portfolio.md"
rm -f "{PROJECT_PATH}/.logs/report-claims-registry.md"
rm -f "{PROJECT_PATH}/tips-trend-report.md"
rm -f "{PROJECT_PATH}/tips-trend-report-claims.json"
```

---

### Phase 1: Evidence Enrichment + Section Generation (PARALLEL)

**Objective:** Dispatch 4 agents in parallel to enrich trends with quantitative evidence and generate narrative sections.

Read [references/evidence-enrichment.md](references/evidence-enrichment.md) for web search strategy details.
Read [references/claims-format.md](references/claims-format.md) for claims extraction schema.

#### Step 1.1: Dispatch 4 Agents

**CRITICAL:** Dispatch ALL 4 agents in a SINGLE message using 4 parallel Task tool calls.

```yaml
Agent 1 - External Effects (T):
  subagent_type: "cogni-tips:trend-report-writer"
  model: sonnet
  prompt: |
    Dimension: externe-effekte
    TIPS Role: T (Trends)
    Project Path: {PROJECT_PATH}
    Language: {LANGUAGE}
    Industry EN: {INDUSTRY_EN}
    Industry DE: {INDUSTRY_DE}
    Subsector EN: {SUBSECTOR_EN}
    Subsector DE: {SUBSECTOR_DE}
    Topic: {TOPIC}
    Candidates: {JSON array of ~13 candidates for this dimension}
    Raw Signals: {JSON array of matching web signals, or "none"}
    Labels: {relevant i18n labels for headings}

Agent 2 - Digital Value Drivers (I):
  subagent_type: "cogni-tips:trend-report-writer"
  # Same structure, dimension: digitale-wertetreiber

Agent 3 - New Horizons (P):
  subagent_type: "cogni-tips:trend-report-writer"
  # Same structure, dimension: neue-horizonte

Agent 4 - Digital Foundation (S):
  subagent_type: "cogni-tips:trend-report-writer"
  # Same structure, dimension: digitales-fundament
```

Each agent will:
1. Scan raw signals for matching evidence per trend (signal-first strategy)
2. Execute WebSearches ONLY for trends lacking signal evidence (gap-fill)
3. Generate a narrative section (~200-400 words per trend)
4. Extract quantitative claims to JSON
5. Write section to `{PROJECT_PATH}/.logs/report-section-{dimension}.md`
6. Write claims to `{PROJECT_PATH}/.logs/claims-{dimension}.json`
7. Return compact JSON summary with signal reuse metrics

#### Step 1.2: Collect Agent Results

Wait for all 4 agents to complete. Each returns:

```json
{
  "ok": true,
  "dimension": "externe-effekte",
  "trends_covered": 13,
  "claims_extracted": 18,
  "signals_matched": 8,
  "trends_signal_sufficient": 4,
  "trends_signal_partial": 4,
  "trends_signal_none": 5,
  "searches_executed": 14,
  "searches_skipped_via_signals": 16,
  "section_file": ".logs/report-section-externe-effekte.md",
  "claims_file": ".logs/claims-externe-effekte.json"
}
```

**Error handling:**
- If an agent returns `"ok": false`: Retry ONCE by re-dispatching the same agent
- If retry also fails: HALT and report which dimension failed
- All 4 must succeed before proceeding to Phase 2

---

### Phase 2: Report Assembly

**Objective:** Assemble the final report from the 4 dimension sections plus cross-cutting analysis.

Read [references/report-structure.md](references/report-structure.md) for the full report template.

#### Step 2.1: Read Section Files

Read all 4 section files and all 4 claims files:

```
{PROJECT_PATH}/.logs/report-section-externe-effekte.md
{PROJECT_PATH}/.logs/report-section-digitale-wertetreiber.md
{PROJECT_PATH}/.logs/report-section-neue-horizonte.md
{PROJECT_PATH}/.logs/report-section-digitales-fundament.md
{PROJECT_PATH}/.logs/claims-externe-effekte.json
{PROJECT_PATH}/.logs/claims-digitale-wertetreiber.json
{PROJECT_PATH}/.logs/claims-neue-horizonte.json
{PROJECT_PATH}/.logs/claims-digitales-fundament.json
```

#### Step 2.2: Generate Executive Summary

Write a ~500-word executive summary that:
- Identifies 3-5 cross-cutting themes across all 4 dimensions
- Highlights the most impactful trends with supporting evidence
- Notes the balance between leading and lagging indicators
- Summarizes the overall strategic posture (proactive vs reactive)

Use the appropriate language (EN/DE) matching the project language.

#### Step 2.3: Generate Portfolio Analysis

Create quantitative portfolio analysis tables:

1. **Horizon Distribution**: Count of trends per horizon (ACT/PLAN/OBSERVE) per dimension
2. **Confidence Distribution**: Count by confidence tier (high/medium/low/uncertain) per dimension
3. **Signal Intensity**: Average signal intensity per dimension
4. **Leading/Lagging Balance**: Ratio of leading vs lagging indicators per dimension
5. **Evidence Coverage**: Number of trends with quantitative evidence vs qualitative-only

#### Step 2.4: Write Report Header

Write frontmatter + title + executive summary to a separate log file. This is only the content generated in Steps 2.2 — the 4 dimension sections stay on disk.

```
Path: {PROJECT_PATH}/.logs/report-header.md
Content:
  - YAML frontmatter (from report-structure.md template)
  - H1 title
  - Executive Summary (from Step 2.2)
  - Must end with two trailing newlines (\n\n)
```

#### Step 2.4a: Write Portfolio Analysis

Write the portfolio analysis section (from Step 2.3) to a separate log file.

```
Path: {PROJECT_PATH}/.logs/report-portfolio.md
Content:
  - Portfolio Analysis H2 header + all sub-tables (from Step 2.3)
  - Must end with two trailing newlines (\n\n)
```

#### Step 2.4b: Write Claims Registry

Read all 4 `.logs/claims-{dimension}.json` files. Transform each claim into a markdown table row and write the claims registry section.

```
Path: {PROJECT_PATH}/.logs/report-claims-registry.md
Content:
  - Claims Registry H2 header + intro text
  - Markdown table: | # | {CLAIM_LABEL} | {VALUE_LABEL} | {SOURCE_LABEL} | {DIMENSION_LABEL} |
  - Each claim row: | {seq} | {claim text} | {value + unit} | [{title}](url) | {dimension} |
  - Total line: {TOTAL_LABEL}: {N} {CLAIMS_LABEL}
  - Must end with two trailing newlines (\n\n)
```

#### Step 2.4c: Assemble Final Report

**Pre-check:** Verify all 7 files exist before concatenation. HALT if any are missing — this indicates an agent failure in Phase 1 or a skipped step in Phase 2.

```bash
for f in \
  "{PROJECT_PATH}/.logs/report-header.md" \
  "{PROJECT_PATH}/.logs/report-section-externe-effekte.md" \
  "{PROJECT_PATH}/.logs/report-section-digitale-wertetreiber.md" \
  "{PROJECT_PATH}/.logs/report-section-neue-horizonte.md" \
  "{PROJECT_PATH}/.logs/report-section-digitales-fundament.md" \
  "{PROJECT_PATH}/.logs/report-portfolio.md" \
  "{PROJECT_PATH}/.logs/report-claims-registry.md"; do
  [ -f "$f" ] || { echo "MISSING: $f"; exit 1; }
done
```

**CRITICAL:** Use bash `cat` to concatenate the 7 log files in section order. The 4 dimension sections go directly from disk to disk — never through LLM output. This avoids token overflow.

```bash
cat \
  "{PROJECT_PATH}/.logs/report-header.md" \
  "{PROJECT_PATH}/.logs/report-section-externe-effekte.md" \
  "{PROJECT_PATH}/.logs/report-section-digitale-wertetreiber.md" \
  "{PROJECT_PATH}/.logs/report-section-neue-horizonte.md" \
  "{PROJECT_PATH}/.logs/report-section-digitales-fundament.md" \
  "{PROJECT_PATH}/.logs/report-portfolio.md" \
  "{PROJECT_PATH}/.logs/report-claims-registry.md" \
  > "{PROJECT_PATH}/tips-trend-report.md"
```

**Verify:** Read first 3 + last 3 lines to confirm frontmatter opens with `---` and file ends with claims total.

See [references/report-structure.md](references/report-structure.md) for the full assembly strategy and file-to-section mapping.

#### Step 2.5: Merge Claims

Merge all 4 dimension claims files into a single file:

```json
{
  "status": "success",
  "file_path": "tips-trend-report.md",
  "language": "{LANGUAGE}",
  "total_claims": N,
  "claims": [... all claims from all dimensions ...]
}
```

Write to: `{PROJECT_PATH}/tips-trend-report-claims.json`

---

### Phase 2.5: Insight Summary (trend-panorama)

**Objective:** Generate an arc-aware narrative insight summary by delegating to `cogni-narrative:narrative-writer` using the `trend-panorama` arc.

Read [references/phase-2.5-insight-summary.md](references/phase-2.5-insight-summary.md) for the full phase workflow.

#### Entry Gate

- `tips-trend-report.md` must exist (Phase 2 complete)

#### Step 2.5.1: Delegate to cogni-narrative

**No user prompts required.** This phase runs automatically using the `trend-panorama` arc, which is purpose-built for TIPS output (Forces → Impact → Horizons → Foundations maps directly to T → I → P → S).

Invoke `cogni-narrative:narrative-writer` with:
- `source_path`: `{PROJECT_PATH}/`
- `arc_id`: user-selected arc
- `language`: from `trend-scout-output.json` config
- `output_path`: `{PROJECT_PATH}/tips-insight-summary.md`
- `content_map`: trend-report artifacts (report, dimension sections, claims)

#### Step 2.5.2: Validate (Non-Blocking)

- **Success:** Log file path and arc, proceed to Phase 3
- **Failure:** WARNING only, continue to Phase 3
- **cogni-narrative not installed:** WARNING only, continue to Phase 3

All failures in Phase 2.5 are **non-blocking**. The insight summary is an enhancement, not a pipeline-critical artifact.

---

### Phase 3: Claim Verification (Optional)

**Objective:** Optionally verify quantitative claims via `cogni-claims:claim-work`.

#### Step 3.1: Ask User

Present the user with a choice:

```yaml
AskUserQuestion:
  question: "{total_claims} quantitative claims were extracted. Would you like to verify them now?"
  header: "Verify"
  options:
    - label: "Verify now (Recommended)"
      description: "Run automated claim verification against source URLs"
    - label: "Skip verification"
      description: "Save claims file for later verification"
```

#### Step 3.2: Run Verification (if chosen)

```yaml
Skill:
  skill: "cogni-claims:claim-work"
  args: "--file-path {PROJECT_PATH}/tips-trend-report.md --claims-file {PROJECT_PATH}/tips-trend-report-claims.json --verdict-mode --language {LANGUAGE}"
```

**If `cogni-claims` is not installed:** Display WARNING and skip verification. Do NOT halt.

#### Step 3.3: Process Verification Results

If claim-work was run:
- Parse the QualityGateResult
- Display summary: PASS / REVIEW / FAIL with counts
- Write verification metadata to `{PROJECT_PATH}/.metadata/trend-report-verification.json`

```json
{
  "verified_at": "ISO-8601",
  "verdict": "PASS|REVIEW|FAIL",
  "total_claims": N,
  "verified": N,
  "passed": N,
  "failed": N,
  "review": N
}
```

**If FAIL:** Present the list of failed claims with suggested corrections. This is INFORMATIONAL ONLY — do NOT auto-correct the report.

---

### Phase 4: Finalization

**Objective:** Update metadata and present summary to user.

#### Step 4.1: Update Metadata

Read `{PROJECT_PATH}/.metadata/trend-scout-output.json` and add:

```json
{
  "trend_report_complete": true,
  "trend_report_path": "tips-trend-report.md",
  "trend_report_claims_path": "tips-trend-report-claims.json",
  "trend_report_generated_at": "ISO-8601",
  "insight_summary_path": "tips-insight-summary.md or null",
  "insight_summary_arc": "trend-panorama or null"
}
```

Note: `insight_summary_path` and `insight_summary_arc` are only set if Phase 2.5 succeeded. Set to `null` if failed (cogni-narrative unavailable).

Write the updated JSON back.

#### Step 4.2: Display Summary

Present to the user:

```
Trend Report Complete
─────────────────────
Report:       {PROJECT_PATH}/tips-trend-report.md
Claims:       {PROJECT_PATH}/tips-trend-report-claims.json
Insight:      {PROJECT_PATH}/tips-insight-summary.md (or "failed")
Trends:       52 across 4 dimensions
Claims:       {total_claims} quantitative claims extracted
Arc:          Trend Panorama (or "failed")
Verification: {verdict or "skipped"}

Recommended next steps:
  1. export-html-report — Generate interactive HTML report
  2. export-pdf-report — Generate formal PDF report
  3. cogni-claims:claim-work — Verify claims (if skipped)
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| `trend-scout-output.json` missing | HALT: "No trend-scout output found. Run trend-scout first." |
| `execution.workflow_state != "agreed"` | HALT: "Trend candidates not yet agreed. Complete trend-scout selection first." |
| `tips_candidates.total < 52` | HALT: "Expected 52 agreed candidates, found {N}." |
| `web-research-raw.json` missing or has no `raw_signals_before_dedup` | Try fallback: `phase1-research-summary.json` `.items[]` (expand abbreviated fields). If both unavailable: WARNING and proceed without raw signals (~120 searches) |
| Agent returns `ok: false` | Retry once, then HALT with dimension name |
| All agents fail | HALT: "All dimension agents failed. Check web access." |
| `cogni-narrative` not installed | WARNING: Skip insight summary, proceed to Phase 3 |
| `cogni-claims` not installed | WARNING: Skip verification, proceed to finalization |
| claim-work returns FAIL | Present failed claims to user. Do NOT auto-correct. |

## Integration

### Upstream

- **trend-scout** — Produces the `trend-scout-output.json` consumed by this skill

### Downstream

- **export-html-report** — Can render `tips-trend-report.md` as interactive HTML
- **export-pdf-report** — Can render `tips-trend-report.md` as formal PDF
- **cogni-claims:claim-work** — Can verify claims from `tips-trend-report-claims.json`

## Debugging

**Log files:**

```
{PROJECT_PATH}/.logs/report-header.md                  — Frontmatter + title + exec summary
{PROJECT_PATH}/.logs/report-section-{dimension}.md     — Individual dimension sections (4 files)
{PROJECT_PATH}/.logs/claims-{dimension}.json           — Individual dimension claims (4 files)
{PROJECT_PATH}/.logs/report-portfolio.md               — Portfolio analysis tables
{PROJECT_PATH}/.logs/report-claims-registry.md         — Claims registry markdown table
{PROJECT_PATH}/tips-insight-summary.md                 — Arc-aware insight summary (Phase 2.5)
```

**Common issues:**

| Issue | Check |
|-------|-------|
| Agent hangs | Verify web access is enabled |
| Empty claims | Check if trends have quantitative data in trend-scout output |
| Wrong language | Verify `language` field in trend-scout-output.json |
| Missing sections | Check `.logs/` for partial agent output |
