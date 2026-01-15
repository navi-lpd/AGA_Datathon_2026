# Alteryx workflows (screenshots + .yxmd files)

## What this hub is
This page links to the exact Alteryx workflow files (.yxmd) used to produce the cleaned, scored, merged, and ML training datasets, plus any screenshots that document the workflows.

---

## Core workflow used in the repo pipeline (main branch)
- MERGE pipeline workflow (main):  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/main/pipeline/alteryx/FAC_USAspending_Merged.yxmd

---

## Full workflow set (authoritative snapshot, archive branch)
These are the complete workflows from the OneDrive snapshot.

### Federal Audit Clearinghouse (FAC) clean + score
- Folder:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/tree/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Alteryx%20Workflows
- Includes:
  - FAC_Master_Clean.yxmd
  - FAC_With_Risk_Score.yxmd

### Merged outputs (FAC + USAspending + SAM merges)
- Folder:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/tree/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Alteryx%20Workflows
- Includes:
  - FAC_USAspending_Merged.yxmd
  - SAM_FAC_Merged.yxmd
  - SAM_USAspending_Merged.yxmd

### ML training dataset build
- Folder:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/tree/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML%20Training/Alteryx%20Workflows
- Includes:
  - FAC_USAspending_ML_Training.yxmd

### SAM exclusions cleaning
- Folder:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/tree/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/SAM/Alteryx%20Workflows
- Includes:
  - SAM_Exclusion_Cleaning.yxmd

### USAspending pulls (All years + FY-specific)
- Folder:  
  https://github.com/fiscalpatriots/AGA_Datathon_2026/tree/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/USAspending/Alteryx%20Workflows
- Includes:
  - USAspending_All_Years.yxmd
  - USAspending_FY2019.yxmd
  - USAspending_FY2020.yxmd
  - USAspending_FY2021.yxmd
  - USAspending_FY2022.yxmd
  - USAspending_FY2023.yxmd
  - USAspending_FY2024.yxmd

---

## Workflow screenshots
- NOT IN REPO YET (have to ask Khaled), chore: create folder `docs/appendix_assets/alteryx_screenshots/`
  and have PNG screenshots of the workflows there, then link it here once committed.
