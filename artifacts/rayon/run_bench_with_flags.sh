#!/bin/bash

# Set default values if not provided
CPUNODEBIND="${CPUNODEBIND:-1}"
MEMBIND="${MEMBIND:-1}"

run_bench_with_flags() {
  local rustflags_val="$1"
  local baseline_name="$2"
  RUSTFLAGS="${rustflags_val}" \
    cargo bench --manifest-path=rayon-demo/Cargo.toml --no-run \
  && \
  RUSTFLAGS="${rustflags_val}" setarch $(uname -m) -R \
       numactl --cpunodebind="${CPUNODEBIND}" --membind="${MEMBIND}" \
    cargo bench --manifest-path=rayon-demo/Cargo.toml > "$baseline_name"
}
