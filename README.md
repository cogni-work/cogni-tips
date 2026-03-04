# cogni-tips

A Claude Code plugin for scouting, selecting, and reporting on strategic trends using the TIPS framework (Trends, Implications, Possibilities, Solutions).

## Why this exists

Strategic trend analysis is hard to do well. It requires scanning hundreds of sources across languages and regions, scoring candidates against multiple frameworks, and synthesizing everything into a coherent report with verifiable evidence. Most trend reports are either shallow (top-10 lists without evidence) or expensive (months of consultant time). The gap between "we should watch trends" and "here's an actionable, evidence-backed trend report" is where most organizations stall.

| Problem | What happens | Impact |
|---------|-------------|--------|
| Source coverage gaps | English-only research misses DACH-specific signals | Blind spots in regulated EU markets |
| Scoring subjectivity | Trends selected by gut feel, not framework | Portfolio imbalance, hype bias |
| Evidence-free narratives | Trend reports cite no quantitative data | Low credibility with decision-makers |
| Manual effort | Weeks of desk research per trend cycle | Outdated by the time it ships |

This plugin automates the research-heavy parts while keeping strategic judgment where it belongs — with you.

## What it is

A three-stage TIPS trend pipeline for Claude Code. Scout trends across an industry, select the most relevant candidates, and generate a narrative report with web-sourced quantitative evidence and inline citations. Full bilingual support (EN/DE) for DACH market coverage.

## What it does

1. **Scout** trends across 4 TIPS dimensions with bilingual web research (32 searches + academic, patent, and regulatory API queries)
2. **Select** from scored candidates using multi-framework analysis (Ansoff signal intensity, Rogers diffusion stages, CRAAP source quality)
3. **Report** with 4 parallel agents enriching each dimension with quantitative evidence, producing a narrative report with inline citations and a verifiable claims registry

## What it means for you

If you need to stay ahead of industry trends for strategy, advisory, or portfolio decisions, this is your research accelerator.

- **Broad coverage, fast.** 32+ bilingual web searches plus academic and patent sources, executed in minutes.
- **Framework-scored, not gut-feel.** Every candidate scored on impact, probability, strategic fit, source quality, and signal strength.
- **Evidence-backed output.** Every quantitative claim in the report has an inline citation you can verify.
- **Bilingual by default.** German and English research queries, DACH-specific source targeting, output in your chosen language.

## Installation

```bash
claude plugins add cogni-work/cogni-tips
```

**Prerequisites:**
- Web access enabled (for trend research)
- `cogni-claims` plugin (for claim verification of trend report citations)
- Optional: `cogni-narrative` plugin (for insight summary generation)

## Quick start

Describe what you want in natural language:

- "scout trends for the automotive industry"
- "select trend candidates for manufacturing"
- "generate a TIPS trend report"

Or invoke skills directly:

```
trend-scout    → interactive industry selection + trend scouting
tips-selection → TIPS candidate generation for smarter-service research
trend-report   → narrative report from agreed candidates
```

## How it works

**trend-scout** initializes a research project, dispatches a **trend-web-researcher** agent for bilingual web research (32 queries + API sources), then a **trend-generator** agent to produce scored candidates using extended thinking. You review and select candidates through an interactive workflow or visual selector app.

**trend-report** reads agreed candidates and dispatches 4 parallel **trend-report-writer** agents (one per TIPS dimension). Each agent enriches trends with web-sourced quantitative evidence, writes a narrative section, and extracts verifiable claims. The skill assembles the final report with executive summary, portfolio analysis, and claims registry.

## Components

| Component | Type | What it does |
|-----------|------|--------------|
| `tips-selection` | skill | TIPS candidate generation (60 candidates, auto-selected) for smarter-service research |
| `trend-scout` | skill | End-to-end trend scouting with industry selection and bilingual research |
| `trend-report` | skill | Narrative report generation with evidence enrichment and claims extraction |
| `trend-web-researcher` | agent | Executes 32 bilingual web searches + API queries, returns aggregated signals |
| `trend-generator` | agent | Generates scored trend candidates using multi-framework analysis (Opus) |
| `trend-report-writer` | agent | Writes one TIPS dimension section with inline citations and claims |

## License

[CC-BY-NC-SA-4.0](LICENSE)
