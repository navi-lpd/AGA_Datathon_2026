# Weighting rationale (risk factors vs mitigating factors)

## What this hub is
Explains the scoring weights and why they matter.

---

## Risk factors (add points)
- Going Concern: +25  
- Material Weakness (General): +20  
- Material Weakness (Findings): +20  
- Repeat Finding: +15  
- Questioned Costs: +15  
- Prior Findings: +10  
- Significant Deficiency: +10  
- Modified Opinion: +10  
- Internal Control Deficiency: +5  
- Noncompliance: +5  
- Other Findings: +2  
- Other Matters: +2  

---

## Mitigating factors (subtract points)
- Low Risk Auditee: -15  
- Has Corrective Action Plan: -5  

---

## Rationale (high level)
- Higher weights reflect audit signals that indicate higher likelihood of sustained reporting or control issues.  
- Mitigations reduce risk when the audit indicates lower risk status or documented remediation.

---

## Where this is applied
- Score formula and tiers:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/docs/appendix_hubs/scoring/score_formula_and_tiers.md
- Scoring workflow (feature branch):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/feature/data-cleaning/Federal%20Audit%20ClearingHouse/FAC_Master_With_Risk_Score.yxmd
- Outputs (main):
  - Merged detail: https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/data/analysis_core/merged_detail/FAC_USAspending_Merged_Detail.csv
  - Summary by tier: https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/data/analysis_core/summary_by_tier/FAC_USAspending_Summary_By_Tier.csv
