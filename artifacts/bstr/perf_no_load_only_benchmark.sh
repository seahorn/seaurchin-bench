#!/bin/bash

# This script benchmarks the performance of a bstr application with no-load-only LICM.

RUSTFLAGS_DEFAULT_LICM="${RUSTFLAGS_DEFAULT_LICM:-"-C opt-level=3"}"
RUSTFLAGS_NO_LOAD_ONLY_LICM="${RUSTFLAGS_NO_LOAD_ONLY_LICM:-"-C opt-level=3 -Cllvm-args=-licm-uses-ownsem=false -Cllvm-args=-licm-no-promote-load-only"}"

# Source the compute_geomean_perf function and run_bench_with_flags
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../bench/geomean_no_load_only.sh"
source "${SCRIPT_DIR}/run_bench_with_flags.sh"

MEASUREMENT_TIME=10  # Default measurement time in seconds
FILE_ARG=""

usage() {
  echo "Usage: $0 [--measurement-time <seconds>] [--file <critcmp_output>]"
  echo "  --measurement-time <seconds>   Set the measurement time for benchmarks (default: 5)"
  echo "  --file <critcmp_output>        Compute geomean from an existing critcmp output file"
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
      if [[ "$MEASUREMENT_TIME" != "10" ]]; then
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

if [[ -n "$FILE_ARG" ]]; then
  compute_geomean_perf "$(readlink -f "$FILE_ARG")"
else
  TMPFILE=$(mktemp)
  run_bench_with_flags "${RUSTFLAGS_NO_LOAD_ONLY_LICM}" "/dev/null"
  if [[ $? -ne 0 ]]; then
    echo "Error: Benchmark with no-load-only LICM failed."
    exit $?
  fi
  run_bench_with_flags "${RUSTFLAGS_DEFAULT_LICM}" "$TMPFILE"
  if [[ $? -ne 0 ]]; then
    echo "Error: Benchmark with default LICM failed."
    exit $?
  fi
  compute_geomean_perf "$TMPFILE"
fi
