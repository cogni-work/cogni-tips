# Phase 0.5: Web Research

**Reference Checksum:** `sha256:tips-sel-p0.5-web-v1`

**Verification Protocol:** After reading, confirm complete load:

```text
Reference Loaded: phase-0.5-web-research.md | Checksum: tips-sel-p0.5-web-v1
```

---

## Objective

Execute live web searches to gather current trend signals before candidate generation. This enriches Phase 1 generation with fresh, real-world data beyond LLM training knowledge.

**Expected Duration:** 30-60 seconds (8 web searches)

---

## Entry Gate

Before proceeding, verify Phase 0 outputs:

- [ ] PROJECT_PATH set and validated
- [ ] INDUSTRY_SECTOR extracted
- [ ] RESEARCH_TYPE = `smarter-service`
- [ ] WEB_RESEARCH_ENABLED = true (default)

**If WEB_RESEARCH_ENABLED = false:** Skip to Phase 1.

---

## Step 0.5.1: Initialize Web Research Phase

```bash
log_phase "Phase 0.5: Web Research" "start"
log_conditional INFO "Industry sector: ${INDUSTRY_SECTOR}"
log_conditional INFO "Target: 8 search configs (4 dimensions x 2 regions)"
```

---

## Step 0.5.2: Build Search Configurations

### Search Query Templates

Build 8 search configurations (4 dimensions x 2 regions: global + DACH):

| Dimension | Region | Query Template |
|-----------|--------|----------------|
| externe-effekte | global | `"{INDUSTRY_SECTOR} external trends regulations market forces 2025"` |
| externe-effekte | dach | `"{INDUSTRY_SECTOR} externe Trends Regulierung Markt Deutschland 2025"` |
| neue-horizonte | global | `"{INDUSTRY_SECTOR} business model innovation strategic trends 2025"` |
| neue-horizonte | dach | `"{INDUSTRY_SECTOR} Geschäftsmodell Innovation strategische Trends Deutschland 2025"` |
| digitale-wertetreiber | global | `"{INDUSTRY_SECTOR} digital value creation customer experience ROI 2025"` |
| digitale-wertetreiber | dach | `"{INDUSTRY_SECTOR} digitale Wertschöpfung Kundenerfahrung Deutschland 2025"` |
| digitales-fundament | global | `"{INDUSTRY_SECTOR} digital infrastructure technology foundation 2025"` |
| digitales-fundament | dach | `"{INDUSTRY_SECTOR} digitales Fundament Infrastruktur Technologie Deutschland 2025"` |

### Industry-Specific Query Adjustment

For German industry terms, use appropriate translations:

| English | German |
|---------|--------|
| manufacturing | Maschinenbau, Fertigung |
| healthcare | Gesundheitswesen |
| financial services | Finanzdienstleistungen |
| retail | Einzelhandel |
| logistics | Logistik |

---

## Step 0.5.3: Execute WebSearch for Each Config

Execute searches sequentially (to respect rate limits):

### MANDATORY: Thinking Block for Search Execution

<thinking>
**Web Research Execution for ${INDUSTRY_SECTOR}**

**Search Configuration:**
- Industry: ${INDUSTRY_SECTOR}
- Regions: global, dach
- Dimensions: 4
- Total searches: 8

**Executing searches:**

1. externe-effekte (global): "${INDUSTRY_SECTOR} external trends regulations market forces 2025"
2. externe-effekte (dach): "${INDUSTRY_SECTOR_DE} externe Trends Regulierung Markt Deutschland 2025"
3. neue-horizonte (global): "${INDUSTRY_SECTOR} business model innovation strategic trends 2025"
4. neue-horizonte (dach): "${INDUSTRY_SECTOR_DE} Geschäftsmodell Innovation strategische Trends 2025"
5. digitale-wertetreiber (global): "${INDUSTRY_SECTOR} digital value creation customer experience ROI 2025"
6. digitale-wertetreiber (dach): "${INDUSTRY_SECTOR_DE} digitale Wertschöpfung Kundenerfahrung 2025"
7. digitales-fundament (global): "${INDUSTRY_SECTOR} digital infrastructure technology foundation 2025"
8. digitales-fundament (dach): "${INDUSTRY_SECTOR_DE} digitales Fundament Infrastruktur Technologie 2025"
</thinking>

### WebSearch Parameters

For each search, use these parameters:

```yaml
WebSearch:
  query: "{constructed_query}"
  blocked_domains:
    - pinterest.com
    - facebook.com
    - instagram.com
    - tiktok.com
    - reddit.com
```

### Target Sources by Dimension

| Dimension | Preferred Source Types |
|-----------|------------------------|
| externe-effekte | Regulatory bodies, industry associations, news (EU Commission, VDMA, BITKOM, Handelsblatt, Reuters) |
| neue-horizonte | Consulting firms, analysts (McKinsey, BCG, Roland Berger, Gartner, Forrester) |
| digitale-wertetreiber | Tech providers, case studies (SAP, Siemens, industrie.de, business publications) |
| digitales-fundament | Research institutes, tech vendors (Fraunhofer, MIT, DIN/ISO, cloud providers) |

---

## Step 0.5.4: Extract Trend Signals from Results

For each search result, extract trend signals:

### Signal Extraction Template

```yaml
trend_signal:
  dimension: "{dimension_slug}"
  region: "global" | "dach"
  signal_name: "{trend name from title/snippet}"
  signal_keywords:
    - "{keyword1}"
    - "{keyword2}"
    - "{keyword3}"
  source_url: "{result_url}"
  source_snippet: "{snippet_text}"
  freshness_indicator: "{date from URL/snippet or 'recent'}"
```

### Extraction Rules

**Allowed:**
- Extract trend names from search result titles
- Extract keywords from snippets
- Note source URLs for provenance
- Infer freshness from dates in URLs/snippets

**Prohibited:**
- Inventing signals not in search results
- Extrapolating beyond snippet content
- Creating fake source URLs
- Adding signals from training knowledge in this phase

### MANDATORY: Thinking Block for Signal Extraction

<thinking>
**Signal Extraction from Search Results**

**Search 1: externe-effekte (global)**
Results: [N] results received
Extracted signals:
1. Signal: "{name}" | Keywords: [kw1, kw2, kw3] | URL: {url} | Freshness: {date}
2. Signal: "{name}" | Keywords: [kw1, kw2, kw3] | URL: {url} | Freshness: {date}
[Continue for each result...]

**Search 2: externe-effekte (dach)**
[Same format...]

[Continue for all 8 searches...]

**Extraction Summary:**
- Total results processed: [N]
- Unique signals extracted: [N]
- Signals per dimension: externe-effekte=[N], neue-horizonte=[N], digitale-wertetreiber=[N], digitales-fundament=[N]
</thinking>

---

## Step 0.5.5: Aggregate and Deduplicate Signals

### Aggregation Process

1. Group signals by dimension
2. Merge global and DACH signals per dimension
3. Deduplicate by similar signal names (fuzzy match on trend name)
4. Rank by: (1) freshness, (2) source quality, (3) regional diversity
5. Keep top 5-10 signals per dimension

### Deduplication Rules

- Same trend name (case-insensitive) = duplicate
- Similar keywords (2+ overlap) = potential duplicate, keep most specific
- Same source URL = duplicate

### Output Structure

```yaml
aggregated_signals:
  externe-effekte:
    count: [N]
    signals:
      - signal_name: "..."
        keywords: [...]
        source_url: "..."
        freshness: "..."
        region: "global|dach"
  neue-horizonte:
    count: [N]
    signals: [...]
  digitale-wertetreiber:
    count: [N]
    signals: [...]
  digitales-fundament:
    count: [N]
    signals: [...]
```

---

## Step 0.5.6: Build WEB_RESEARCH_CONTEXT

Structure the signals for Phase 1 consumption:

### MANDATORY: Thinking Block for Context Building

<thinking>
**Building WEB_RESEARCH_CONTEXT**

**Research Metadata:**
- Timestamp: ${ISO_TIMESTAMP}
- Industry: ${INDUSTRY_SECTOR}
- Searches executed: 8
- Searches successful: [N]
- Searches failed: [N]

**Signals by Dimension:**

**externe-effekte (${COUNT} signals):**
1. ${signal_name} | Keywords: ${keywords} | Source: ${url} | Fresh: ${date}
2. ...

**neue-horizonte (${COUNT} signals):**
1. ...

**digitale-wertetreiber (${COUNT} signals):**
1. ...

**digitales-fundament (${COUNT} signals):**
1. ...

**Total unique signals: ${TOTAL}**
</thinking>

### WEB_RESEARCH_CONTEXT Structure

Store in memory for Phase 1:

```json
{
  "research_timestamp": "2025-12-16T10:30:00Z",
  "industry_sector": "${INDUSTRY_SECTOR}",
  "web_research_status": "success|partial|failed",
  "total_signals": 32,
  "search_metadata": {
    "configs_executed": 8,
    "configs_successful": 8,
    "configs_failed": 0,
    "total_results": 45
  },
  "signals_by_dimension": {
    "externe-effekte": {
      "signal_count": 8,
      "signals": [
        {
          "signal_name": "EU AI Act Compliance Deadline",
          "keywords": ["ai-act", "regulation", "2025"],
          "source_url": "https://...",
          "freshness": "2024-12",
          "region": "global"
        }
      ]
    },
    "neue-horizonte": {...},
    "digitale-wertetreiber": {...},
    "digitales-fundament": {...}
  }
}
```

---

## Step 0.5.7: Mark Phase 0.5 Complete

```bash
log_phase "Phase 0.5: Web Research" "complete"
log_metric "total_signals_extracted" "${SIGNAL_COUNT}" "count"
log_metric "search_success_rate" "${SUCCESS_RATE}" "percent"
log_conditional INFO "WEB_RESEARCH_AVAILABLE = true"
```

Set variables for Phase 1:
- `WEB_RESEARCH_AVAILABLE = true`
- `WEB_RESEARCH_CONTEXT = {structured signals}`

---

## Error Handling

### Search Failure Handling

| Scenario | Detection | Response |
|----------|-----------|----------|
| Rate limiting | HTTP 429 or slow response | Wait 5s, retry once, then skip config |
| Empty results | result_count = 0 | Log warning, continue with other configs |
| Network timeout | No response in 60s | Retry once, then mark config as failed |
| All searches fail | search_failures = 8 | Set `WEB_RESEARCH_AVAILABLE=false`, proceed with warning |

### Partial Failure Handling

| Failure Rate | Action |
|--------------|--------|
| 1-2 configs fail (25%) | Continue with available signals |
| 3-4 configs fail (50%) | Log warning, continue with partial signals |
| 5-7 configs fail (62-87%) | Log severe warning, use available signals |
| 8 configs fail (100%) | Fallback to training-only mode |

### Fallback Mode

If `WEB_RESEARCH_AVAILABLE = false`:

```bash
log_conditional WARN "Web research failed - proceeding with training-only generation"
log_conditional WARN "Candidates may lack freshness indicators"

# Set fallback context
WEB_RESEARCH_CONTEXT = null
WEB_RESEARCH_AVAILABLE = false
```

Phase 1 will proceed with training-only generation and output will include warning.

---

## Success Criteria

- [ ] 8 search configurations built
- [ ] WebSearch executed for each config
- [ ] Signals extracted from results (not invented)
- [ ] Signals aggregated by dimension
- [ ] Duplicates removed
- [ ] WEB_RESEARCH_CONTEXT built
- [ ] WEB_RESEARCH_AVAILABLE flag set

---

## Variables Set

| Variable | Description | Example |
|----------|-------------|---------|
| WEB_RESEARCH_AVAILABLE | Whether web research succeeded | `true` |
| WEB_RESEARCH_CONTEXT | Structured signals for Phase 1 | `{...}` |
| SEARCH_SUCCESS_RATE | Percentage of successful searches | `87.5` |
| TOTAL_SIGNALS | Number of unique signals extracted | `32` |

---

## Next Phase

Proceed to [phase-1-generate.md](phase-1-generate.md) with web research context.

---

## Anti-Hallucination Rules

This phase has strict anti-hallucination requirements:

1. **Web-signal extraction** - ONLY extract from actual WebSearch results
2. **No signal invention** - Never create signals that weren't in search results
3. **No fake URLs** - Only store URLs from actual results
4. **No training knowledge injection** - Save training knowledge for Phase 1
5. **Transparent failures** - If search fails, log it; don't fabricate results

**Verification:** Each signal must have a traceable source_url from the search results.
