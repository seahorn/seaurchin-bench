#!/bin/bash

run_perf_test() {
  # 1. Clear file system caches
  sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

  # 2. Evict CPU cache manually (not guaranteed but helps)
  dd if=/dev/zero of=/dev/null bs=1M count=4096 & wait
  
  # run performance test
  echo "Disabling NMI watchdog to prevent interference with perf measurements..."
  echo 0 | sudo tee /proc/sys/kernel/nmi_watchdog
  taskset -c 2-12 perf stat -r 100 -e mem_uops_retired.all_loads,mem_uops_retired.all_stores,L1-dcache-loads,L1-dcache-stores,L1-dcache-load-misses,L1-dcache-store-misses,LLC-load-misses,LLC-store-misses ./target/release/micro-fold "$k" "$m" > /dev/null
  echo 1 | sudo tee /proc/sys/kernel/nmi_watchdog
  echo -e "Enabled NMI watchdog back!\n"
}

if [ $# -lt 2 ] || [ "$1" -le 0 ] || [ "$2" -le 0 ]; then
  echo "Usage: $0 <k> <m> (where k > 0, m > 0)"
  exit 1
fi
k=$1
m=$2
echo -e "Default\n-------"
# build with default
RUSTFLAGS="-C opt-level=3" cargo build --release
run_perf_test

echo -e "Ownsem\n-------"
# build with ownsem
RUSTFLAGS="-C opt-level=3 -Cllvm-args=-licm-uses-ownsem -Cllvm-args=-licm-ownsem-safeset-ignores-throw -Cllvm-args=-licm-ownsem-safeset-store-threadsafe" cargo build --release
run_perf_test

echo -e "Default\n-------"
# build with default
RUSTFLAGS="-C opt-level=3" cargo build --release
run_perf_test

echo -e "Ownsem\n-------"
# build with ownsem
RUSTFLAGS="-C opt-level=3 -Cllvm-args=-licm-uses-ownsem -Cllvm-args=-licm-ownsem-safeset-ignores-throw -Cllvm-args=-licm-ownsem-safeset-store-threadsafe" cargo build --release
run_perf_test
