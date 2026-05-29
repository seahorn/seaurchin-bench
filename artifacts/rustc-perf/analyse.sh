#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEOMEAN_SCRIPT="${SCRIPT_DIR}/runtime-geomean.py"

source "${SCRIPT_DIR}/util.sh"

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <results_db_file> <metric> <new_key> <old_key>"
  exit 1
fi

results_db="$1"
metric="$2"
new_key="$3"
old_key="$4"

if [ ! -f "$results_db" ]; then
  echo "Error: File '$results_db' not found."
  exit 2
fi

echo "Analyzing metric '$metric' in '$results_db'..."
echo "Comparing new_key '$new_key' with old_key '$old_key'..."

TMP_FILE=$(mktemp)

# export the runtime performance data to a CSV file
export_runtime_perf "$results_db" "$TMP_FILE" "$metric"

python3 "$GEOMEAN_SCRIPT" "$TMP_FILE" "$new_key" "$old_key"

rm "$TMP_FILE"
