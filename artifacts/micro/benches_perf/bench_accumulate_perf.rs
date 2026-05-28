use micro::accumulate::*;
use criterion::{criterion_group, criterion_main, Criterion};
use perfcnt::linux::PerfCounterBuilderLinux;
use perfcnt::{AbstractPerfCounter, PerfCounter};
use criterion_perf_events::Perf;
use perfcnt::linux::PerfCounterBuilderLinux as Builder;
use perfcnt::linux::HardwareEventType as Hardware;

fn bench_fold_accumulate(c: &mut Criterion<Perf>) {
    for n in [1, 10, 100, 1_000, 10_000, 100_000,] {
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

fn bench_loop_accumulate(c: &mut Criterion<Perf>) {
    for n in [1, 10, 100, 1_000, 10_000, 100_000,] {
        c.bench_function(&format!("loop_accumulate_{}", n), |b| {
            b.iter(|| {
                let mut sum = 0i64;
                std::hint::black_box(loop_accumulate(&mut sum, n));
            });
        });
    }
}

criterion_group!(
    name = micro_bench_perf;
    config = Criterion::default().with_measurement(
        {
            let builder = PerfCounterBuilderLinux::from_intel_event_description(
                x86::perfcnt::intel::events().expect("Cannot load Intel event descriptions")
                    .get("MEM_UOPS_RETIRED.ALL_STORES")
                    //.get("INST_RETIRED.ANY_")
                    .expect("No MEM_UOPS_RETIRED.ALL_STORES counter"));
            Perf::new(builder)
        }
    );
    targets = bench_fold_accumulate, bench_loop_accumulate
);

criterion_main!(micro_bench_perf);
