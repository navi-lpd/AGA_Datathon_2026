# FAC Next-Year Audit Findings Risk Model (Entity-Year Panel)

## Objective
Build an **entity-year (EIN-based)** panel from Federal Audit Clearinghouse (FAC) audit + federal awards data (2019–2022) to:
1) predict whether a federal grant recipient will have **audit findings in the next audit year (t+1)**, and  
2) explain key drivers of risk using **permutation importance** and **SHAP**.

---

## What This Model Does (In Plain Language)
This project creates an **early warning risk score**. For each organization in a given audit year (**entity-year snapshot**), the model estimates the probability of having audit findings in the **following audit year**. This supports prioritization (oversight, outreach, technical assistance) and is **not a causal model** or a final decision tool.

---

## Data Sources
Federal Audit Clearinghouse (FAC) CSVs by **Audit Year (AY)** for:
- `general-ay` (submission metadata)
- `findings-ay` (audit findings records)
- `federal_awards-ay` (SEFA award line items)

Audit years used: **2019, 2020, 2021, 2022**

> Note: Older years include placeholder UEIs (e.g., `GSA_MIGRATION`). This repo uses **EIN as the entity key** to ensure consistent entity identity across years.

---

## Tech Stack
- Python (Jupyter Notebook)
- pandas, NumPy
- scikit-learn
- SHAP
- Parquet support (pyarrow or fastparquet) for optional intermediate saves

---
