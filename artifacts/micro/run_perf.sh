#!/bin/bash

run_perf_test() {
  # run performance test
  echo 0 | sudo tee /proc/sys/kernel/nmi_watchdog
  #taskset -c 2 perf stat -r 100 -e mem_uops_retired.all_loads,mem_uops_retired.all_stores,node-loads,node-stores,L1-dcache-load-misses,L1-dcache-store-misses,LLC-load-misses,LLC-store-misses,vx_insts.all,simd_fp_128.packed,simd_fp_256.packed ./target/release/micro "$n"
  taskset -c 2 perf stat -r 100 \
  -e mem_uops_retired.all_loads,mem_uops_retired.all_stores,node-loads,node-stores,L1-dcache-load-misses,L1-dcache-store-misses,LLC-loads,LLC-load-misses,LLC-stores,LLC-store-misses \
  ./target/release/micro "$n" > /dev/null
  echo 1 | sudo tee /proc/sys/kernel/nmi_watchdog
}

if [ $# -lt 1 ] || [ "$1" -le 0 ]; then
  echo "Usage: $0 <n> (where n > 0)"
  exit 1
fi
n=$1

echo -e "Default 1\n-------"
# build with default
RUSTFLAGS="-C opt-level=3" cargo build --release
run_perf_test

echo -e "Default 2\n-------"
# build with default
RUSTFLAGS="-C opt-level=3" cargo build --release
run_perf_test

echo -e "Ownsem 1\n-------"
# build with ownsem
RUSTFLAGS="-C opt-level=3 -Cllvm-args=-licm-uses-ownsem -Cllvm-args=-licm-ownsem-safeset-ignores-throw -Cllvm-args=-licm-ownsem-safeset-store-threadsafe" cargo build --release
run_perf_test

echo -e "Ownsem 2\n-------"
# build with ownsem
RUSTFLAGS="-C opt-level=3 -Cllvm-args=-licm-uses-ownsem -Cllvm-args=-licm-ownsem-safeset-ignores-throw -Cllvm-args=-licm-ownsem-safeset-store-threadsafe" cargo build --release
run_perf_test
