use std::hash::{Hash, Hasher};
use std::collections::hash_map::DefaultHasher;
use unwind_aborts::unwind_aborts;

pub fn fold_in_place<T, I, F>(iter: I, acc: &mut T, mut f: F)
where
    I: IntoIterator,
    F: FnMut(&mut T, I::Item),
{
    for item in iter {
        f(acc, item);
    }
}

pub fn loop_accumulate(sum: &mut i64, n : u64)
{
  for i in 0..n {
    let now = {
      42u64.wrapping_shr((i & 63) as u32)
    };
    if now % 2 == 0 {
      *sum += i as i64;
    }
  }
}

//#[unwind_aborts]
pub fn hash_cmp(i: u64) -> u64 {
  let mut hasher = DefaultHasher::new();
  i.hash(&mut hasher);
  let r1 = hasher.finish();
  (i.wrapping_sub(1)).hash(&mut hasher);
  let rminus1 = hasher.finish();
  if r1  == rminus1 {
    return r1 - 1;
  }  
  r1
}

#[unwind_aborts]
pub fn get_now2(i: u64) -> u64 {
    if i == 0 {
        return 0;
    }
    if let Some(den) = i.checked_add(1) { 42 / den } else { 0 }
}
