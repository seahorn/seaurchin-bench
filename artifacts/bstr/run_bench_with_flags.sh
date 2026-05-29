#!/bin/bash

# Set default values if not provided
CPUNODEBIND="${CPUNODEBIND:-1}"
MEMBIND="${MEMBIND:-1}"

# Function to run benchmarks with given RUSTFLAGS and baseline name
run_bench_with_flags() {
  local rustflags_val="$1"
  local outfile="$2"
  RUSTFLAGS="${rustflags_val}" \
    /home/siddharth/cargo-criterion/target/release/cargo-criterion \
      --message-format=json \
      --no-run \
      --manifest-path=bench/Cargo.toml \
      --bench bstr \
  && \
  RUSTFLAGS="${rustflags_val}" setarch $(uname -m) -R numactl --cpunodebind="${CPUNODEBIND}" --membind="${MEMBIND}" \
     /home/siddharth/cargo-criterion/target/release/cargo-criterion \
      --message-format=json \
      --manifest-path=bench/Cargo.toml \
      --bench bstr \
      -- \
      --measurement-time "${MEASUREMENT_TIME}" | jq -s '.' > "${outfile}"
  return $?
}

