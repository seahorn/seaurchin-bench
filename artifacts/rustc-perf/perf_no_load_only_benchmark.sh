#!/bin/bash

RUSTFLAGS_DEFAULT_LICM="${RUSTFLAGS_DEFAULT_LICM:-"-C opt-level=3"}"
RUSTFLAGS_NO_LOAD_ONLY_LICM="${RUSTFLAGS_NO_LOAD_ONLY_LICM:-"-C opt-level=3 -Cllvm-args=-licm-uses-ownsem=false -Cllvm-args=-licm-no-promote-load-only"}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/util.sh"
DB_FILE="${SCRIPT_DIR}/results_no_load_only.db"
OUT_FILE=$(mktemp)
RUSTC_PATH=$(rustup which --toolchain seaurchin rustc)
GEOMEAN_SCRIPT="${SCRIPT_DIR}/runtime-geomean.py"
DEFAULT_LICM_KEY="default_licm"
NO_LOAD_ONLY_LICM_KEY="no_load_only_licm"

# delete DB_FILE if it exists
if [ -f "$DB_FILE" ]; then
  rm "$DB_FILE"
fi

# First run with no_load_only flags
run_benchmark "$RUSTFLAGS_NO_LOAD_ONLY_LICM" "$RUSTC_PATH" "$NO_LOAD_ONLY_LICM_KEY" "$DB_FILE"

# Then run with default flags
run_benchmark "$RUSTFLAGS_DEFAULT_LICM" "$RUSTC_PATH" "$DEFAULT_LICM_KEY" "$DB_FILE"

# export the runtime performance data to a CSV file
export_runtime_perf "$DB_FILE" "$OUT_FILE"

# run geomean script
python3 "$GEOMEAN_SCRIPT" "$OUT_FILE" "$DEFAULT_LICM_KEY" "$NO_LOAD_ONLY_LICM_KEY"