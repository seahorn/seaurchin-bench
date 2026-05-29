#!/bin/bash
RUSTFLAGS_NO_LOAD_ONLY_LICM="${RUSTFLAGS_NO_LOAD_ONLY_LICM:-"-C opt-level=3 -Zprint_codegen_stats -Cllvm-args=-licm-uses-ownsem=false -Cllvm-args=-licm-no-promote-load-only"}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/util.sh"
DB_FILE="${SCRIPT_DIR}/results_no_load_only.db"
OUT_FILE=$(mktemp)
RUSTC_PATH=$(rustup which --toolchain seaurchin rustc)
NO_LOAD_ONLY_LICM_KEY="no_load_only_licm"

# delete DB_FILE if it exists
if [ -f "$DB_FILE" ]; then
  rm "$DB_FILE" 
fi
# Run with no-load-only flags (default is run as part of ownsem)
build_benchmark "$RUSTFLAGS_NO_LOAD_ONLY_LICM" "$RUSTC_PATH" "$NO_LOAD_ONLY_LICM_KEY" "$DB_FILE" "rustc_build_stats_no_load_only_licm.json"
