use micro::accumulate::*;
use criterion::{criterion_group, criterion_main, Criterion};

fn bench_fold_accumulate(c: &mut Criterion) {
    for n in [1, 10, 100, 1_000, 10_000, 100_000, /*1_000_000, 10_000_000, 100_000_000*/] {
        c.bench_function(&format!("fold_accumulate_{}", n), |b| {
            b.iter(|| {
                let mut sum = 0i64;
                fold_in_place(0..n, &mut sum, |accum, x| {
                    let now = 42u64.wrapping_shr((x & 63) as u32);
                    if now % 2 == 0 {
                        *accum += x as i64;
                    }
                });
                std::hint::black_box(sum);
            });
        });
    }
}

fn bench_loop_accumulate(c: &mut Criterion) {
    for n in [1, 10, 100, 1_000, 10_000, 100_000, /*1_000_000, 10_000_000, 100_000_000*/] {
        c.bench_function(&format!("loop_accumulate_{}", n), |b| {
            b.iter(|| {
                let mut sum = 0i64;
                std::hint::black_box(loop_accumulate(&mut sum, n));
            });
        });
    }
}

criterion_group!(benches, bench_fold_accumulate, bench_loop_accumulate);
criterion_main!(benches);
