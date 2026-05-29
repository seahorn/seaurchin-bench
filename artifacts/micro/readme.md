

```
bench_accumulate::bench_loop_acc_group::bench_loop_accumulate ten:10
  Instructions:                        2956|2942                 (+0.47587%) [+1.00476x]
  L1 Hits:                             3611|3600                 (+0.30556%) [+1.00306x]
  LL Hits:                                0|0                    (No change)
  RAM Hits:                              18|19                   (-5.26316%) [-1.05556x]
  Total read+write:                    3629|3619                 (+0.27632%) [+1.00276x]
  Estimated Cycles:                    4241|4265                 (-0.56272%) [-1.00566x]
  Ge:                                     0|0                    (No change)
bench_accumulate::bench_loop_acc_group::bench_loop_accumulate hundred:100
  Instructions:                       29236|29069                (+0.57450%) [+1.00574x]
  L1 Hits:                            35740|35615                (+0.35098%) [+1.00351x]
  LL Hits:                                0|0                    (No change)
  RAM Hits:                              19|20                   (-5.00000%) [-1.05263x]
  Total read+write:                   35759|35635                (+0.34797%) [+1.00348x]
  Estimated Cycles:                   36405|36315                (+0.24783%) [+1.00248x]
  Ge:                                     0|0                    (No change)
bench_accumulate::bench_loop_acc_group::bench_loop_accumulate thousand:1000
  Instructions:                      292036|290447               (+0.54709%) [+1.00547x]
  L1 Hits:                           357040|355919               (+0.31496%) [+1.00315x]
  LL Hits:                                0|0                    (No change)
  RAM Hits:                              19|20                   (-5.00000%) [-1.05263x]
  Total read+write:                  357059|355939               (+0.31466%) [+1.00315x]
  Estimated Cycles:                  357705|356619               (+0.30453%) [+1.00305x]
  Ge:                                     0|0                    (No change)
bench_accumulate::bench_loop_acc_group::bench_loop_accumulate tenthousand:10000
  Instructions:                     2920036|2904926              (+0.52015%) [+1.00520x]
  L1 Hits:                          3570040|3559891              (+0.28509%) [+1.00285x]
  LL Hits:                                0|0                    (No change)
  RAM Hits:                              19|20                   (-5.00000%) [-1.05263x]
  Total read+write:                 3570059|3559911              (+0.28506%) [+1.00285x]
  Estimated Cycles:                 3570705|3560591              (+0.28405%) [+1.00284x]
  Ge:                                     0|0                    (No change)
bench_accumulate::bench_loop_acc_group::bench_loop_accumulate hundredthousand:100000
  Instructions:                    29200036|29050133             (+0.51601%) [+1.00516x]
  L1 Hits:                         35700040|35600167             (+0.28054%) [+1.00281x]
  LL Hits:                                0|0                    (No change)
  RAM Hits:                              19|20                   (-5.00000%) [-1.05263x]
  Total read+write:                35700059|35600187             (+0.28054%) [+1.00281x]
  Estimated Cycles:                35700705|35600867             (+0.28044%) [+1.00280x]
  Ge:                                     0|0                    (No change)
```