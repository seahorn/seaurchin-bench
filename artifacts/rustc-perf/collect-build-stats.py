import os
import re
import subprocess
import argparse
import json
from collections import defaultdict
import sys

def run_cargo_build():
  try:
    build_output = subprocess.run(
      ["cargo", "build", "--release"],
      capture_output=True, text=True,
    )
    print(f"Cargo build output:\n{build_output.stdout}\n{build_output.stderr}")
    return build_output.stdout + build_output.stderr, build_output.returncode
  except Exception as e:
    print(f"Error running cargo build: {e}")
    return "", 1

def run_collector(rustc_path, run_kind, iterations, db_file, env, rustflags):
  collector_cmd = [
    "./target/release/collector", "bench_runtime_local", rustc_path,
    "--id", run_kind, "--iterations", str(iterations), "--db", db_file, "--no-run"
  ]
  collector_env = env.copy()
  collector_env["RUSTFLAGS"] = rustflags
  print(f'Running collector with command: RUSTFLAGS="{rustflags}" {" ".join(collector_cmd)}')
  try:
    collector_output = subprocess.run(
      collector_cmd,
      capture_output=True, text=True, env=collector_env
    )
    return collector_output.stdout + collector_output.stderr, collector_output.returncode
  except Exception as e:
    print(f"Error running collector: {e}")
    return "", 1

def parse_promotion_stats(output):
  load_store_pattern = re.compile(r'^\s*(\d+)\s+licm.*Number of load and store promotions')
  load_only_pattern = re.compile(r'^\s*(\d+)\s+licm.*Number of load-only promotions')
  regalloc_spills_pattern = re.compile(r'^\s*(\d+)\s+regalloc.*Number of spills inserted')
  loop_vectorize_pattern = re.compile(r'^\s*(\d+)\s+loop-vectorize.*Number of loops vectorized')
  slp_vector_instrs_pattern = re.compile(r'^\s*(\d+)\s+SLP.*Number of vector instructions generated')
  project_pattern = re.compile(r"^Benchmark compiling\s+[`']([a-zA-Z0-9_\-\s]+)[`']")

  results = defaultdict(lambda: {
    "load_store_promotions": 0,
    "load_only_promotions": 0,
    "regalloc_spills": 0,
    "loops_vectorized": 0,
    "slp_vector_instructions": 0
  })
  current_project = None

  for line in output.splitlines():
    # Print errors or warnings to stderr
    if "error" in line.lower() or "warning" in line.lower():
      print(line, file=sys.stderr)

    m = project_pattern.match(line)
    if m:
      current_project = m.group(1)

    if current_project:
      lm = load_store_pattern.match(line)
      if lm:
        results[current_project]["load_store_promotions"] += int(lm.group(1))
      lo = load_only_pattern.match(line)
      if lo:
        results[current_project]["load_only_promotions"] += int(lo.group(1))
      rs = regalloc_spills_pattern.match(line)
      if rs:
        results[current_project]["regalloc_spills"] += int(rs.group(1))
      lv = loop_vectorize_pattern.match(line)
      if lv:
        results[current_project]["loops_vectorized"] += int(lv.group(1))
      sv = slp_vector_instrs_pattern.match(line)
      if sv:
        results[current_project]["slp_vector_instructions"] += int(sv.group(1))

  return results

def build_benchmark(rustflags, rustc_path, run_kind, db_file, iterations, json_outfile):
  env = os.environ.copy()
  env["RUSTFLAGS"] = rustflags

  build_output_text, build_returncode = run_cargo_build()
  collector_output_text, collector_returncode = run_collector(
    rustc_path, run_kind, iterations, db_file, env, rustflags
  )

  output = build_output_text + collector_output_text

  stats = parse_promotion_stats(output)

  # Write results to JSON file
  result = {
    "stats": stats,
    "build_returncode": build_returncode,
    "collector_returncode": collector_returncode
  }
  with open(json_outfile, "w") as f:
    json.dump(result, f, indent=2)

  print(f"Results written to {json_outfile}")

def main():
  parser = argparse.ArgumentParser(description="Collect build stats for Rust benchmarks.")
  parser.add_argument("--rustflags", help="RUSTFLAGS to use for the build (optional). If omitted, RUSTFLAGS from the environment will be used")
  parser.add_argument("--rustc-path", required=True, help="Path to the rustc binary")
  parser.add_argument("--run-kind", required=True, help="Run kind identifier")
  parser.add_argument("--db-file", required=True, help="Path to the database file")
  parser.add_argument("--iterations", type=int, default=100, help="Number of iterations (default: 100)")
  parser.add_argument("--json-outfile", required=True, help="Output JSON file for results")
  args = parser.parse_args()

  # Prefer explicit CLI --rustflags; fall back to environment RUSTFLAGS; default to empty string.
  rustflags = args.rustflags if args.rustflags is not None else os.environ.get("RUSTFLAGS", "")

  build_benchmark(
    rustflags=rustflags,
    rustc_path=args.rustc_path,
    run_kind=args.run_kind,
    db_file=args.db_file,
    iterations=args.iterations,
    json_outfile=args.json_outfile
  )

if __name__ == "__main__":
  main()