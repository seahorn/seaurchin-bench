#!/bin/bash

# Set default values if not provided
CPUNODEBIND_VAL="${CPUNODEBIND_VAL:-1}"
MEMBIND_VAL="${MEMBIND_VAL:-1}"

# Function to run benchmarks with given RUSTFLAGS and baseline name
run_bench_with_flags() {
  local rustflags_val="$1"
  local outfile="$2"
  RUSTFLAGS="${rustflags_val}" \
    cargo criterion \
      --message-format=json \
      --manifest-path benches/Cargo.toml \
      --bench ecs \
      --no-run \
  && \
  RUSTFLAGS="${rustflags_val}" \
    setarch $(uname -m) -R numactl --cpunodebind="${CPUNODEBIND_VAL}" --membind="${MEMBIND_VAL}" cargo criterion \
      --message-format=json \
      --manifest-path benches/Cargo.toml \
      --bench ecs \
      --  \
      --measurement-time "${MEASUREMENT_TIME}" | jq -s '.' > "${outfile}"
  return $?
}
