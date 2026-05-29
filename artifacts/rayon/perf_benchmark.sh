#!/bin/bash

# This script benchmarks the performance of a Bevy application.

RUSTFLAGS_DEFAULT_LICM="${RUSTFLAGS_DEFAULT_LICM:-"-C opt-level=3"}"
RUSTFLAGS_OWNSEM_LICM="${RUSTFLAGS_OWNSEM_LICM:-"-C opt-level=3 -Cllvm-args=-licm-uses-ownsem -Cllvm-args=-licm-ownsem-safeset-ignores-throw=false -Cllvm-args=-licm-ownsem-safeset-store-threadsafe"}"

# Source the compute_geomean_perf function
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../bench/geomean.sh"
source "${SCRIPT_DIR}/run_bench_with_flags.sh"

MEASUREMENT_TIME=10  # Default measurement time in seconds
FILE_ARG=""

usage() {
  echo "Usage: $0 [--measurement-time <seconds>] [--file <critcmp_output>]"
  echo "  --measurement-time <seconds>   Ignored"
  echo "  --file <critcmp_output>        Ignored"
  echo "  -h, --help                     Show this help message"
  echo
  echo "Note: --measurement-time and --file cannot be used together."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --measurement-time)
      if [[ -n "$FILE_ARG" ]]; then
        echo "Error: --measurement-time and --file cannot be used together."
        usage
        exit 1
      fi
      MEASUREMENT_TIME="$2"
      shift 2
      ;;
    --file)
      if [[ "$MEASUREMENT_TIME" != "1" ]]; then
        echo "Error: --measurement-time and --file cannot be used together."
        usage
        exit 1
      fi
      FILE_ARG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

TMPFILE_DEFAULT=$(mktemp)
run_bench_with_flags "${RUSTFLAGS_DEFAULT_LICM}" $TMPFILE_DEFAULT
if [[ $? -ne 0 ]]; then
  echo "Error: Benchmark with default LICM failed."
  exit $?
fi
TMPFILE_OWNSEM=$(mktemp)
run_bench_with_flags "${RUSTFLAGS_OWNSEM_LICM}" $TMPFILE_OWNSEM
if [[ $? -ne 0 ]]; then
  echo "Error: Benchmark with ownsem LICM failed."
  exit $?
fi
# Treat the new as old
geomean=$(cargo benchcmp ${TMPFILE_OWNSEM} ${TMPFILE_DEFAULT} \
  | grep -o 'x [0-9.]\+' \
  | awk '{print $2}' \
  | awk 'BEGIN {prod=1} {prod *= $1} END {print prod ** (1/NR)}')
improvement=$(awk -v g="$geomean" 'BEGIN { printf "%.2f", (1 - g) * 100 }')
printf "Geometric Mean: %.10f\n" "$geomean"
printf "Percentage Improvement: %s %%\n" "$improvement"
echo "default: $TMPFILE_DEFAULT"
echo "ownsem: $TMPFILE_OWNSEM"
