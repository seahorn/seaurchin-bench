use micro::accumulate::*;
use iai_callgrind::{main, LibraryBenchmarkConfig, ValgrindTool, library_benchmark_group, library_benchmark, Callgrind};
use std::hint::black_box;
//use iai_callgrind::client_requests::cachegrind as cr;

#[library_benchmark]
#[bench::ten(10)]
#[bench::hundred(100)]
#[bench::thousand(1000)]
#[bench::tenthousand(10000)]
#[bench::hundredthousand(100000)]
fn bench_loop_accumulate(n: u64) {
    let mut sum = 0i64;
    loop_accumulate(&mut sum, n);
    black_box(sum);}

library_benchmark_group!(
    name = bench_loop_acc_group;
    benchmarks = bench_loop_accumulate
);

main!(
    config = LibraryBenchmarkConfig::default()
        .env_clear(false)
        .tool(Callgrind::with_args(["--collect-bus=yes"]));
        //.default_tool(ValgrindTool::Cachegrind)
        //.tool(Cachegrind::with_args(["--instr-at-start=no"]));
    library_benchmark_groups = bench_loop_acc_group
);


