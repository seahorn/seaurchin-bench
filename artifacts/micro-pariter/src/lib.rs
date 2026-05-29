use rayon::prelude::*;

pub fn sum_of_squares_cmplx(input: &[i32]) -> i32 {
    input.par_iter()
         .map(|&i| {
             // A "super complex" manual hash-like computation
             let mut x = i as u64;
             x = x.wrapping_mul(0x9E3779B97F4A7C15);
             x ^= x >> 33;
             x = x.wrapping_mul(0xC2B2AE3D27D4EB4F);
             x ^= x >> 29;
             x = x.wrapping_mul(0x165667B19E3779F9);
             x ^= x >> 32;
             (x as i32).wrapping_abs()
         })
         .sum()
}


pub fn sum_of_squares(input: &[i32]) -> i32 {
    input.par_iter()
         .map(|&i| i * i)
         .sum()
}