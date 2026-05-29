#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --benchmark {large|micro}" >&2
}

BENCHMARK=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --benchmark)
      BENCHMARK="${2:-}"
      shift 2
      ;;
    --benchmark=*)
      BENCHMARK="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$BENCHMARK" != "large" && "$BENCHMARK" != "micro" ]]; then
  echo "Missing or invalid --benchmark value: '$BENCHMARK'" >&2
  usage
  exit 1
fi

if [[ "$BENCHMARK" == "large" ]]; then
  ARTIFACTS="bevy;bstr;bytes;glam;itertools;nalgebra;rayon"
else
  ARTIFACTS="micro"
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_TS="$(date +%Y%m%d_%H%M%S)"
ARTIFACTS="$ARTIFACTS" reframe \
  -C "$REPO_DIR/bench/settings.py" \
  -c "$REPO_DIR/bench/rfm_cargo_build_test.py" \
  --exec-policy "serial" \
  --performance-report \
  -S sourcesdir="$REPO_DIR" \
  --system=local \
  --run \
  --report-file "$PWD/build_numpromo_${BENCHMARK}_${REPORT_TS}.json"
