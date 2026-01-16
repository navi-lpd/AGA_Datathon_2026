# Train/test split methodology

## What this hub is
Documents how we split data into train and test sets.

---

## Target variable
- is_high_risk (binary): 1 if Red-tier, 0 otherwise. 

---

## Split method (as implemented in the files)
- Random split using split_value (0–1).
- Train set: split_value < 0.8
- Test set: split_value >= 0.8

Current file row counts:
- Train: 33,722 rows
- Test: 8,511 rows
- Total: 42,233 rows

Class balance (is_high_risk):
- Total: 9,975 high-risk, 32,258 not high-risk

---

## Reference
- ML training data dictionary:
  https://github.com/fiscalpatriots/AGA_Datathon_2026/blob/archive/onedrive-snapshot/archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML%20Training/Data%20Dictionaries/FAC_USAspending_ML_Training_Data_Dictionary.docx
