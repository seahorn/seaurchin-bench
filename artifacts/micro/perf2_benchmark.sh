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


# Source the compute_geomean_perf function
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../bench/geomean.sh"
source "${SCRIPT_DIR}/run_bench_with_flags.sh"

MEASUREMENT_TIME=5  # Default measurement time in seconds
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
summary_file=$(mktemp)
if [[ -n "$FILE_ARG" ]]; then
  compute_geomean_perf "$(readlink -f "$FILE_ARG")"
else
  TMPFILE=$(mktemp)
  run_bench_with_flags "${SCRIPT_DIR}/benches_perf/Cargo.toml" "${RUSTFLAGS_DEFAULT_LICM}" "/dev/null"
  if [[ $? -ne 0 ]]; then
   echo "Error: Benchmark with default LICM failed."
   exit $?
  fi
  run_bench_with_flags "${SCRIPT_DIR}/benches_perf/Cargo.toml" "${RUSTFLAGS_OWNSEM_LICM}" "${TMPFILE}"
  if [[ $? -ne 0 ]]; then
    echo "Error: Benchmark with ownsem LICM failed."
    exit $?
  fi
compute_geomean_perf ${TMPFILE}  
echo "Detailed results in ${TMPFILE}"
fi
