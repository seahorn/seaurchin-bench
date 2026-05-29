#!/bin/bash

# Set default values if not provided
CPUNODEBIND="${CPUNODEBIND:-1}"
MEMBIND="${MEMBIND:-1}"

# Function to run benchmarks with given RUSTFLAGS and baseline name
run_bench_with_flags() {
  local rustflags_val="$1"
  local outfile="$2"
  echo 'Ignoring measurement time for this benchmark'
  RUSTFLAGS="${rustflags_val}" \
    cargo criterion \
      --message-format=json \
      --no-run \
  && \
  RUSTFLAGS="${rustflags_val}" setarch $(uname -m) -R \
    numactl --cpunodebind="${CPUNODEBIND}" --membind="${MEMBIND}" \
      cargo criterion \
        --message-format=json \
        -- fold --measurement-time "${MEASUREMENT_TIME}" | jq -s '.' > "${outfile}"
}
