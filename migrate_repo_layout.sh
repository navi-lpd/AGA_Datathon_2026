#!/usr/bin/env bash
set -euo pipefail

# bash quality-of-life
shopt -s nullglob

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

is_tracked() {
  git ls-files --error-unmatch "$1" >/dev/null 2>&1
}

safe_mkdir() {
  mkdir -p "$1"
}

safe_move() {
  # Moves using git mv if tracked, else mv.
  # Refuses to overwrite destination.
  local src="$1"
  local dst="$2"

  [ -e "$src" ] || return 0
  [ ! -e "$dst" ] || die "Refusing to overwrite existing destination: $dst"

  safe_mkdir "$(dirname "$dst")"

  if is_tracked "$src"; then
    git mv "$src" "$dst"
  else
    mv "$src" "$dst"
  fi
}

safe_remove() {
  # Removes tracked content via git rm, else rm -rf
  local path="$1"
  [ -e "$path" ] || return 0

  if is_tracked "$path"; then
    git rm -r "$path"
  else
    rm -rf "$path"
  fi
}

cleanup_empty_dir() {
  local d="$1"
  if [ -d "$d" ]; then
    rmdir "$d" 2>/dev/null || true
  fi
}

import_from_branch() {
  # Import file from another branch without keeping the archive path.
  # Steps: checkout that file -> move into destination -> clean archive dir later.
  local br="$1"
  local src="$2"
  local dst="$3"

  # Only import if it exists in that branch
  if git cat-file -e "${br}:${src}" 2>/dev/null; then
    info "Importing from ${br}: ${src} -> ${dst}"
    safe_mkdir "$(dirname "$dst")"
    git checkout "$br" -- "$src"
    safe_move "$src" "$dst"
  else
    info "Skipping missing in ${br}: ${src}"
  fi
}

main() {
  require_cmd git

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Run from inside a git repository."
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"
  [ "$branch" = "main" ] || die "You must run this on the main branch (current: $branch)."

  # Require clean working tree
  if [ -n "$(git status --porcelain)" ]; then
    die "Working tree is not clean. Commit or stash your changes first."
  fi

  # Safety tag
  local ts
  ts="$(date +"%Y%m%d-%H%M%S")"
  info "Creating safety tag: pre-migration-${ts}"
  git tag "pre-migration-${ts}"

  info "Creating final folder structure..."
  safe_mkdir "deliverables/dashboard/tableau_workbooks"
  safe_mkdir "deliverables/model_artifact"

  safe_mkdir "webapp/pages"
  safe_mkdir "webapp/assets/img"
  safe_mkdir "webapp/assets/icons"
  safe_mkdir "webapp/assets/embeds"
  safe_mkdir "webapp/legacy"

  safe_mkdir "pipeline/alteryx/workflows"
  safe_mkdir "pipeline/alteryx/exports"
  safe_mkdir "pipeline/python/src"
  safe_mkdir "pipeline/python/notebooks"

  safe_mkdir "data/fac"
  safe_mkdir "data/sam"
  safe_mkdir "data/merged"
  safe_mkdir "data/ml"

  safe_mkdir "models/audit_health_score"
  safe_mkdir "models/predictive_audit_findings"
  safe_mkdir "models/predictive_audit_findings/notebooks"

  safe_mkdir "docs/data_dictionaries/analysis_core"
  safe_mkdir "docs/data_dictionaries/fac"
  safe_mkdir "docs/data_dictionaries/sam"
  safe_mkdir "docs/data_dictionaries/merged"
  safe_mkdir "docs/data_dictionaries/ml"

  # -----------------------------
  # deliverables/dashboard -> nested tableau_workbooks
  # -----------------------------
  info "Restructuring deliverables/dashboard..."
  for f in deliverables/dashboard/*.twbx; do
    safe_move "$f" "deliverables/dashboard/tableau_workbooks/$(basename "$f")"
  done

  # -----------------------------
  # ML model -> deliverables/model_artifact + models/
  # -----------------------------
  info "Restructuring ML model notebooks..."
  # Prefer the most recent notebook if multiple exist
  if [ -e "ML model/Datathon Predictive Modeling v3.ipynb" ]; then
    safe_move "ML model/Datathon Predictive Modeling v3.ipynb" \
      "deliverables/model_artifact/Datathon_Predictive_Modeling_v3.ipynb"
  fi

  if [ -e "ML model/Datathon Predictive Modeling.ipynb" ]; then
    safe_move "ML model/Datathon Predictive Modeling.ipynb" \
      "deliverables/model_artifact/Datathon_Predictive_Modeling.ipynb"
  fi

  if [ -e "ML model/FAC_Data_RandomForest.ipynb" ]; then
    safe_move "ML model/FAC_Data_RandomForest.ipynb" \
      "models/predictive_audit_findings/notebooks/FAC_Data_RandomForest.ipynb"
  fi

  # Remove temp artifacts under ML model
  safe_remove "ML model/temp"
  cleanup_empty_dir "ML model"

  # deliverables/model/features.md -> models (source-of-truth)
  if [ -e "deliverables/model/features.md" ]; then
    safe_move "deliverables/model/features.md" \
      "models/predictive_audit_findings/features.md"
  fi
  cleanup_empty_dir "deliverables/model"

  # -----------------------------
  # pipeline/alteryx workflow (main) -> pipeline/alteryx/workflows
  # -----------------------------
  info "Restructuring pipeline/alteryx..."
  if [ -e "pipeline/alteryx workflow (main)/FAC_USAspending_Merged.yxmd" ]; then
    safe_move "pipeline/alteryx workflow (main)/FAC_USAspending_Merged.yxmd" \
      "pipeline/alteryx/workflows/FAC_USAspending_Merged.yxmd"
  fi
  # Remove old folder if empty
  if [ -d "pipeline/alteryx workflow (main)" ]; then
    # If anything else is inside, move it too
    for f in "pipeline/alteryx workflow (main)"/*; do
      [ -e "$f" ] || true
      safe_move "$f" "pipeline/alteryx/workflows/$(basename "$f")"
    done
    cleanup_empty_dir "pipeline/alteryx workflow (main)"
  fi

  # -----------------------------
  # Move analysis-core data dictionaries into docs/data_dictionaries/analysis_core
  # -----------------------------
  info "Moving analysis_core data dictionaries into docs/data_dictionaries/analysis_core..."
  for d in data/analysis_core/*/*_Data_Dictionary.docx; do
    safe_move "$d" "docs/data_dictionaries/analysis_core/$(basename "$d")"
  done

  # -----------------------------
  # webapp development -> webapp/pages + webapp/legacy
  # -----------------------------
  info "Restructuring webapp..."
  if [ -d "webapp development" ]; then
    # Move README if destination doesn't exist
    if [ -e "webapp development/README.md" ] && [ ! -e "webapp/README.md" ]; then
      safe_move "webapp development/README.md" "webapp/README.md"
    fi

    # Choose index source: prefer v10 if present, else the non-versioned file
    local_index_src=""
    if [ -e "webapp development/sample_webapp_aga_datathon_v10.html" ]; then
      local_index_src="webapp development/sample_webapp_aga_datathon_v10.html"
    elif [ -e "webapp development/sample_webapp_aga_datathon.html" ]; then
      local_index_src="webapp development/sample_webapp_aga_datathon.html"
    fi

    if [ -n "${local_index_src}" ]; then
      safe_move "${local_index_src}" "webapp/pages/index.html"
    fi

    # Archive remaining versions
    for f in "webapp development"/sample_webapp_aga_datathon_v*.html; do
      [ -e "$f" ] || continue
      safe_move "$f" "webapp/legacy/$(basename "$f")"
    done
    if [ -e "webapp development/sample_webapp_aga_datathon.html" ]; then
      safe_move "webapp development/sample_webapp_aga_datathon.html" \
        "webapp/legacy/sample_webapp_aga_datathon.html"
    fi

    # If folder now empty, remove it
    cleanup_empty_dir "webapp development"
  fi

  # -----------------------------
  # Import key files from archive/onedrive-snapshot
  # -----------------------------
  info "Importing missing data/workflows from archive/onedrive-snapshot (if branch exists)..."
  ARCH_BRANCH="archive/onedrive-snapshot"
  if git rev-parse --verify --quiet "${ARCH_BRANCH}" >/dev/null; then
    # FAC outputs
    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/CSV Files/FAC_Master_With_Risk_Score.csv" \
      "data/fac/FAC_Master_With_Risk_Score.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/CSV Files/FAC_Risk_Summary_By_Tier.csv" \
      "data/fac/FAC_Risk_Summary_By_Tier.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/CSV Files/FAC_Top_10_Red_Entities_By_Spending.csv" \
      "data/fac/FAC_Top_10_Red_Entities_By_Spending.csv"

    # FAC dictionaries
    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Data Dictionaries/FAC_Master_With_Risk_Score_Data_Dictionary.docx" \
      "docs/data_dictionaries/fac/FAC_Master_With_Risk_Score_Data_Dictionary.docx"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Data Dictionaries/FAC_Risk_Summary_By_Tier_Data_Dictionary.docx" \
      "docs/data_dictionaries/fac/FAC_Risk_Summary_By_Tier_Data_Dictionary.docx"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Data Dictionaries/FAC_Top_10_Red_Entities_By_Spending_Data_Dictionary.docx" \
      "docs/data_dictionaries/fac/FAC_Top_10_Red_Entities_By_Spending_Data_Dictionary.docx"

    # SAM outputs + dictionary
    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/SAM/CSV Files/SAM_Exclusions_with_UEI.csv" \
      "data/sam/SAM_Exclusions_with_UEI.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/SAM/Data Dictionaries/SAM_Master_Data_Dictionary.docx" \
      "docs/data_dictionaries/sam/SAM_Master_Data_Dictionary.docx"

    # Merged outputs + dictionaries
    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/CSV Files/SAM_FAC_Merged.csv" \
      "data/merged/SAM_FAC_Merged.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/CSV Files/SAM_USAspending_Merged.csv" \
      "data/merged/SAM_USAspending_Merged.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Data Dictionaries/SAM_FAC_Merged_Data_Dictionary.docx" \
      "docs/data_dictionaries/merged/SAM_FAC_Merged_Data_Dictionary.docx"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Data Dictionaries/SAM_USAspending_Merged_Data_Dictionary.docx" \
      "docs/data_dictionaries/merged/SAM_USAspending_Merged_Data_Dictionary.docx"

    # ML training outputs + dictionary
    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML Training/CSV Files/FAC_ML_Train.csv" \
      "data/ml/FAC_ML_Train.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML Training/CSV Files/FAC_ML_Test.csv" \
      "data/ml/FAC_ML_Test.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML Training/CSV Files/FAC_ML_Features_Master.csv" \
      "data/ml/FAC_ML_Features_Master.csv"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML Training/Data Dictionaries/FAC_USAspending_ML_Training_Data_Dictionary.docx" \
      "docs/data_dictionaries/ml/FAC_USAspending_ML_Training_Data_Dictionary.docx"

    # Core workflows (Alteryx)
    safe_mkdir "pipeline/alteryx/workflows/fac"
    safe_mkdir "pipeline/alteryx/workflows/sam"
    safe_mkdir "pipeline/alteryx/workflows/merged"
    safe_mkdir "pipeline/alteryx/workflows/ml_training"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Alteryx Workflows/FAC_With_Risk_Score.yxmd" \
      "pipeline/alteryx/workflows/fac/FAC_With_Risk_Score.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/FAC/Alteryx Workflows/FAC_Master_Clean.yxmd" \
      "pipeline/alteryx/workflows/fac/FAC_Master_Clean.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/SAM/Alteryx Workflows/SAM_Exclusion_Cleaning.yxmd" \
      "pipeline/alteryx/workflows/sam/SAM_Exclusion_Cleaning.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Alteryx Workflows/SAM_FAC_Merged.yxmd" \
      "pipeline/alteryx/workflows/merged/SAM_FAC_Merged.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Alteryx Workflows/SAM_USAspending_Merged.yxmd" \
      "pipeline/alteryx/workflows/merged/SAM_USAspending_Merged.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/Merged/Alteryx Workflows/FAC_USAspending_Merged.yxmd" \
      "pipeline/alteryx/workflows/merged/FAC_USAspending_Merged.yxmd"

    import_from_branch "$ARCH_BRANCH" \
      "archive/onedrive/AGA_Datathon_OneDrive/Datasets/ML Training/Alteryx Workflows/FAC_USAspending_ML_Training.yxmd" \
      "pipeline/alteryx/workflows/ml_training/FAC_USAspending_ML_Training.yxmd"

    # Clean up any archive folder created during checkout
    if [ -d "archive" ]; then
      info "Removing leftover archive folder created during import..."
      rm -rf "archive"
    fi
  else
    info "Branch ${ARCH_BRANCH} not found locally. Skipping archive import."
    info "If it exists only as a remote branch, fetch it first (git fetch --all) then re-run."
  fi

  # -----------------------------
  # Cleanup known junk folders if they still exist
  # -----------------------------
  info "Cleaning known junk folders (if present)..."
  safe_remove ".DS_Store"
  find . -name ".DS_Store" -print0 2>/dev/null | xargs -0 -I {} rm -f "{}" 2>/dev/null || true
  find . -name "__pycache__" -type d -print0 2>/dev/null | xargs -0 -I {} rm -rf "{}" 2>/dev/null || true

  info "Migration complete."
  info "Next: review changes, then commit."
  git status -sb
}

main "$@"

