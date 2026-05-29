#!/bin/bash

RUSTFLAGS_DEFAULT_LICM="${RUSTFLAGS_DEFAULT_LICM:-"-C opt-level=3"}"
RUSTFLAGS_OWNSEM_LICM="${RUSTFLAGS_OWNSEM_LICM:-"-C opt-level=3 \
  -Cllvm-args=-licm-uses-ownsem \
  -Cllvm-args=-licm-ownsem-safeset-ignores-throw=false \
  -Cllvm-args=-licm-ownsem-safeset-store-threadsafe \
  -Cllvm-args=-licm-ownsem-only-after-vectorization=false \
  -Cllvm-args=-sroa-preserve-ownsem=true \
  -Cllvm-args=-instcombine-preserve-ownsem=true \
  -Cllvm-args=-loop-rotate-preserves-ownsem=true"}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/util.sh"
DB_FILE="${SCRIPT_DIR}/results_ownsem.db"
OUT_FILE=$(mktemp)
RUSTC_PATH=$(rustup which --toolchain seaurchin rustc)
GEOMEAN_SCRIPT="${SCRIPT_DIR}/runtime-geomean.py"
OWNSEM_KEY="ownsem_licm"
DEFAULT_LICM_KEY="default_licm"

# delete DB_FILE if it exists
if [ -f "$DB_FILE" ]; then
  rm "$DB_FILE" 
fi
# first run with default flags
run_benchmark "$RUSTFLAGS_DEFAULT_LICM" "$RUSTC_PATH" "$DEFAULT_LICM_KEY" "$DB_FILE"

# then run with ownsem flags
run_benchmark "$RUSTFLAGS_OWNSEM_LICM" "$RUSTC_PATH" "$OWNSEM_KEY" "$DB_FILE"

# export the runtime performance data to a CSV file
export_runtime_perf "$DB_FILE" "$OUT_FILE"

# run geomean script
python3 "$GEOMEAN_SCRIPT" "$OUT_FILE" "$OWNSEM_KEY" "$DEFAULT_LICM_KEY"
