#!/bin/bash

# Assume collector does the correct setup for running benchmarks so don't use numactl here.
run_benchmark(){
  local rustflags="$1"
  local rustc_path="$2"
  local run_kind="$3"
  local db_file="$4"
  cargo build --release && \
  RUSTFLAGS="$rustflags" ./target/release/collector bench_runtime_local "$rustc_path" --id ${run_kind} --iterations 100 --db "$db_file"
  echo $?
}

build_benchmark(){
  local rustflags="$1"
  local rustc_path="$2"
  local run_kind="$3"
  local db_file="$4"
  local json_outfile="$5"
  python3 ./collect-build-stats.py --rustflags "$rustflags" --rustc-path "$rustc_path" --run-kind "$run_kind" --db-file "$db_file" --json-outfile "$json_outfile"
  echo $?
}

export_runtime_perf() {
  local DB_FILE="$1"
  local OUT_FILE="$2"
  local METRIC="${3:-instructions:u}"

  sqlite3 -header -csv "$DB_FILE" <<EOF > "$OUT_FILE"
SELECT
  s.benchmark AS benchmark,
  a.name AS artifact,
  s.metric AS metric,
  r.value
FROM runtime_pstat r
JOIN runtime_pstat_series s ON r.series = s.id
JOIN artifact a ON r.aid = a.id
WHERE r.aid IN (1, 2) AND s.metric = "${METRIC}"
ORDER BY s.benchmark, a.name;
EOF

echo "Saved to $OUT_FILE"
}
  