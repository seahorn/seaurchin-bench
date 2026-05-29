use criterion::{criterion_group, criterion_main, Criterion,};
use micro_pariter::sum_of_squares;
use micro_pariter::sum_of_squares_cmplx;

use criterion_perf_events::Perf;
// use perfcnt::linux::{
//     CacheId, CacheOpId, CacheOpResultId};
use perfcnt::linux::PerfCounterBuilderLinux as Builder;
use perfcnt::{AbstractPerfCounter, PerfCounter};
//use criterion_perf_events::Perf;
//use perfcnt::linux::HardwareEventType as Hardware;

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

fn bench_sum_of_squares_generic<M: criterion::measurement::Measurement + 'static>(
    c: &mut Criterion<M>,
    label: &str,
) {
    let sizes = [100, 1_000, 10_000, 100_000, 1_000_000];
    for &size in &sizes {
        let data: Vec<i32> = (0..size as i32).collect();
        c.bench_function(&format!("{}_{}", label, size), |b| {
            b.iter(|| {
                std::hint::black_box(sum_of_squares(std::hint::black_box(&data)));
            });
        });
    }
}

fn bench_sum_of_squares(c: &mut Criterion) {
    bench_sum_of_squares_generic(c, "sum_of_squares_walltime");
}

fn bench_sum_of_squares_perf(c: &mut Criterion<Perf>) {
    bench_sum_of_squares_generic(c, "sum_of_squares_perf");
}

criterion_group!(
    name = pariter_bench_perf;
    config = Criterion::default().with_measurement(
         {
            let events = x86::perfcnt::intel::events().expect("Cannot load Intel event descriptions");
            // UNCOMMENT THIS TO DEBUG EVENT DESCRIPTIONS: in case we are not sure
            // that the underlying hardware supports the event.
            // if let Some(event) = events.get("MEM_UOPS_RETIRED.ALL_STORES") {
            //     println!("DEBUG: Event name: {:?}", event.event_name);
            //     println!("DEBUG: Event description: {:?}", event.brief_description);
            // }
            let builder = Builder::from_intel_event_description(
                events.get("MEM_UOPS_RETIRED.ALL_STORES")
                    .expect("No ALL_STORES counter"));
            Perf::new(builder)
         }
         );
    targets = bench_sum_of_squares_perf
);

criterion_group!(
    name = pariter_bench_walltime;
    config = Criterion::default();
    targets = bench_sum_of_squares
);

criterion_main!(pariter_bench_perf, pariter_bench_walltime);
