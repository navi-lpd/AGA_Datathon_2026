# "Problem entity" rule (logic and flags)

## What this hub is
Defines how we flag entities as “problem entities.”

---

## Rule (as implemented)
- is_problem_entity = 1 if findings_count >= 3 OR going_concern >= 1 OR material_weakness_gen >= 1, else 0

---

## Where to see the flag in outputs
- Merged detail (CSV):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/data/analysis_core/merged_detail/FAC_USAspending_Merged_Detail.csv

---

## Workflow that computes the flag
- FAC scoring workflow (feature branch):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/feature/data-cleaning/Federal%20Audit%20ClearingHouse/FAC_Master_With_Risk_Score.yxmd

---

## Supporting artifacts (variable definitions)
- Merged detail data dictionary (DOCX):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/data/analysis_core/merged_detail/FAC_USAspending_Merged_Detail_Data_Dictionary.docx
- Summary by tier data dictionary (DOCX):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/data/analysis_core/summary_by_tier/FAC_USAspending_Summary_By_Tier_Data_Dictionary.docx
