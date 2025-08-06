#!/usr/bin/env bash

# Find all directories containing Cargo.toml files from the given dir.
find_cargo_toml_dirs() {
  local dir="$1"
  # 'dirname' on each Cargo.toml is unique per file, so duplicates are unlikely unless symlinks or weird FS.
  find "$dir" -type f -name "Cargo.toml" -exec dirname {} \;
}


# Run cargo clean on all directories that are passed in the array cargo_toml_dirs
run_cargo_clean() {
  for dir in "$@"; do
    echo "Cleaning directory: $dir"
    (cd "$dir" && cargo clean)
  done
}

# Main script execution
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <directory>"
  echo "Example: $0 ."
  exit 1
fi

# Get the directory to search for Cargo.toml files
search_dir="$1" 

# Find all directories containing Cargo.toml files
cargo_toml_dirs=($(find_cargo_toml_dirs "$search_dir"))

# Run cargo clean on all found directories
run_cargo_clean "${cargo_toml_dirs[@]}"
