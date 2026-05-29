#!/bin/bash

# Set default values if not provided
CPUNODEBIND="${CPUNODEBIND:-1}"
MEMBIND="${MEMBIND:-1}"

# Function to run benchmarks with given RUSTFLAGS and baseline name
run_bench_with_flags() {
  local benchmark="$1"
  local rustflags_val="$2"
  local outfile="$3"
  RUSTFLAGS="${rustflags_val}" \
    cargo criterion \
      --message-format=json \
      --manifest-path  ${benchmark} \
      --no-run \
  && \
  RUSTFLAGS="${rustflags_val}" \
    numactl --cpunodebind="${CPUNODEBIND}" --membind="${MEMBIND}" \
    cargo criterion \
      --message-format=json \
      --manifest-path "${benchmark}" \
      -- accumulate \
      --measurement-time "${MEASUREMENT_TIME}" | jq -s '.' > "${outfile}"
}
  