mod accumulate;
use accumulate::loop_accumulate;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <n>", args[0]);
        std::process::exit(1);
    }
    let n: u64 = args[1].parse().expect("Please provide a valid integer for n");
    let mut sum = 0;
    loop_accumulate(&mut sum, n);
    std::hint::black_box(sum);
}
