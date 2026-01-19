# Pipeline (Overview)

This folder is here to explain what goes in, what happens, and what comes out.

See:
- [inputs_outputs.md](https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/pipeline/inputs_outputs.md) for the short pipeline map
- [data_contract.md](https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/pipeline/data_contract.md) for required fields and join keys
- workflows/ for the actual workflow files

# Pipeline

This folder documents the data transformation pipeline for the Fiscal Patriots AGA Datathon project. It explains what goes in, what happens, and what comes out.

## Quick Navigation

- `inputs_outputs.md` — Short pipeline map (sources to deliverables)
- `data_contract.md` — Required fields, join keys, and schema definitions
- `workflows/` — Alteryx .yxmd workflow files

## Pipeline Overview

**Inputs:**
- USAspending.gov (74M records, FY2019–2024)
- FAC.gov (57K entities, FY2016–2024)
- SAM.gov (167K records, Public Extract V2)

**Processing:**
- Alteryx workflows for cleaning, scoring, merging, and flagging

**Outputs:**
- merged_detail.csv
- summary_by_tier.csv
- top_10_red.csv
- ML training dataset
- Tableau hyper files

## Processing Steps

**Step 1: Data Acquisition**
Download raw extracts from federal data sources.

**Step 2: Data Cleaning**
Standardize formats, handle nulls, and prepare for joins using Alteryx.

**Step 3: Data Integration**
Join datasets using UEI (Unique Entity Identifier) as the primary key.
- FAC.auditee_uei joins to USAspending.recipient_uei

**Step 4: Scoring and Flagging**
Apply the Audit Health Score methodology and flag problem entities.
- audit_health_score: 0–100 score based on risk factors
- risk_tier: Green (80–100), Yellow (60–79), Red (0–59)
- is_problem_entity: Boolean flag for high-risk recipients

**Step 5: Aggregation and Export**
Generate analysis-ready outputs for visualizations and ML.

## Workflows

The workflows/ folder contains Alteryx .yxmd files for each pipeline stage. See that folder for specific workflow documentation.

## Related Documentation

- data_contract.md — Full join logic and required fields
- inputs_outputs.md — Source to output mapping
