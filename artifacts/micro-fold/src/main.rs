use std::hash::{Hash, Hasher};
use std::collections::hash_map::DefaultHasher;
use std::thread;
use std::env;

fn parallel_fold(vec: Vec<u64>, k: usize) -> Vec<i64> {
    let n = vec.len();
    assert!(n % k == 0, "n must be divisible by k");
    let m = n / k;

    let mut handles = Vec::with_capacity(k);

    for i in 0..k {
        let chunk = vec[i * m..(i + 1) * m].to_vec();
        handles.push(thread::spawn(move || {
            let mut acc = 0i64;
            for &x in &chunk {
                match get_now(x) {
                    Ok(now) => {
                        if now % 2 == 0 {
                            acc += x as i64;
                        }
                    }
                    Err(e) => {
                        //eprintln!("Error in get_now: {}", e);
                        break;
                    }
                }
            }
            acc
        }));
    }

    handles
        .into_iter()
        .map(|h| h.join().unwrap())
        .collect::<Vec<i64>>()
}

// inlining is detrimental to ownsem based licm opt
// so don't inline this function
// 1% vs 7%
#[inline(never)]
fn get_now(i: u64) -> Result<u64, String> {
    let mut hasher = DefaultHasher::new();
    i.hash(&mut hasher);
    let r1 = hasher.finish();
    (i.wrapping_sub(1)).hash(&mut hasher);
    let rminus1 = hasher.finish();
    if r1 == rminus1 {
        Err("Intentional error during hashing!".to_string())
    } else {
        Ok(r1)
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <k> <m>", args[0]);
        std::process::exit(1);
    }

    let k: usize = args[1].parse().expect("k must be a positive integer");
    let m: usize = args[2].parse().expect("m must be a positive integer");
    let n = k * m;
    let vec: Vec<u64> = (1..=n as u64).collect();

    std::hint::black_box(parallel_fold(vec, k));

}