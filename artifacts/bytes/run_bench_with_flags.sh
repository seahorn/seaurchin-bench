#!/bin/bash

# Function to run benchmarks with given RUSTFLAGS and baseline name
run_bench_with_flags() {
  local rustflags_val="$1"
  local baseline_name="$2"
  local cpu_node="${CPUNODEBIND:-1}"
  local mem_node="${MEMBIND:-1}"
  RUSTFLAGS="${rustflags_val}" \
    cargo bench \
      --no-run \
  && \
  RUSTFLAGS="${rustflags_val}" setarch $(uname -m) -R \
    numactl --cpunodebind="${cpu_node}" --membind="${mem_node}" \
      cargo bench > "$baseline_name"
  return $?
}

