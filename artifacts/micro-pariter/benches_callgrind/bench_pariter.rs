use criterion::{criterion_group, criterion_main, Criterion,};
use micro_pariter::sum_of_squares;

use iai_callgrind::{main, LibraryBenchmarkConfig, ValgrindTool, library_benchmark_group, library_benchmark, Callgrind, OutputFormat};


// fn bench_sum_of_squares<T>(c: &mut Criterion<T>) {
//     let sizes = [100, 1_000, 10_000, 100_000, 1_000_000];
//     for &size in &sizes {
//         let data: Vec<i32> = (0..size as i32).collect();
//         c.bench_function(&format!("sum_of_squares_{}", size), |b| {
//             b.iter(|| {
//                 std::hint::black_box(sum_of_squares(std::hint::black_box(&data)));
//             });
//         });
//     }
// }

// fn bench_sum_of_squares_perf(c: &mut Criterion<Perf>) {
//     let sizes = [100, 1_000, 10_000, 100_000, 1_000_000];
//     for &size in &sizes {
//         let data: Vec<i32> = (0..size as i32).collect();
//         c.bench_function(&format!("sum_of_squares_{}", size), |b| {
//             b.iter(|| {
//                 std::hint::black_box(sum_of_squares(std::hint::black_box(&data)));
//             });
//         });
//     }
// }

#[library_benchmark]
#[bench::ten(10)]
#[bench::hundred(100)]
#[bench::thousand(1000)]
#[bench::tenthousand(10000)]
#[bench::hundredthousand(100000)]
fn bench_sum_of_squares(n: u64) {
    let data: Vec<i32> = (0..n as i32).collect();
    std::hint::black_box(sum_of_squares(std::hint::black_box(&data)));
}

library_benchmark_group!(
    name = bench_sum_of_squares_group;
    benchmarks = bench_sum_of_squares
);

main!(
    config = LibraryBenchmarkConfig::default()
        .env_clear(false)
        .tool(Callgrind::with_args(["--collect-bus=yes"]));
    library_benchmark_groups = bench_sum_of_squares_group
);

