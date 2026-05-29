#!/usr/bin/env bash
set -euo pipefail

RUSTC_PATH="$(rustup which --toolchain seaurchin rustc)"
RUSTDOC_PATH="$(rustup which --toolchain seaurchin rustdoc)"
SEAURCHIN_SYSROOT="$(rustc +seaurchin --print sysroot)"

mkdir -p benches/target/release/deps

RUSTC="${RUSTC_PATH}" \
RUSTDOC="${RUSTDOC_PATH}" \
RUSTFLAGS="--sysroot=${SEAURCHIN_SYSROOT}" \
RUSTC_WRAPPER= \
RUSTC_WORKSPACE_WRAPPER= \
TMPDIR="$(pwd)/benches/target/release/deps" \
cargo +nightly-2025-04-24 remark wrap -- bench \
  --manifest-path=benches/Cargo.toml \
  --no-run \
  -p benches \
  --bench iter \
  2>&1 | tee remark_full.log | sed -n '/\[\[SB-GEPMerge-BEGIN\]\]/,/\[\[SB-GEPMerge-END\]\]/p' > violations.log
