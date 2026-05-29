
```
benches_callgrind::bench_sum_of_squares_group::bench_sum_of_squares ten:10
  Baselines:                               |default_licm
  Instructions:                      182695|183082               (-0.21138%) [-1.00212x]
  L1 Hits:                           252383|253151               (-0.30338%) [-1.00304x]
  LL Hits:                             3057|2956                 (+3.41678%) [+1.03417x]
  RAM Hits:                            2158|2166                 (-0.36934%) [-1.00371x]
  Total read+write:                  257598|258273               (-0.26135%) [-1.00262x]
  Estimated Cycles:                  343198|343741               (-0.15797%) [-1.00158x]
  Ge:                                  1168|1168                 (No change)
benches_callgrind::bench_sum_of_squares_group::bench_sum_of_squares hundred:100
  Baselines:                               |default_licm
  Instructions:                      182656|183029               (-0.20379%) [-1.00204x]
  L1 Hits:                           252253|253095               (-0.33268%) [-1.00334x]
  LL Hits:                             3119|2930                 (+6.45051%) [+1.06451x]
  RAM Hits:                            2158|2166                 (-0.36934%) [-1.00371x]
  Total read+write:                  257530|258191               (-0.25601%) [-1.00257x]
  Estimated Cycles:                  343378|343555               (-0.05152%) [-1.00052x]
  Ge:                                  1158|1158                 (No change)
benches_callgrind::bench_sum_of_squares_group::bench_sum_of_squares thousand:1000
  Baselines:                               |default_licm
  Instructions:                      184569|184934               (-0.19737%) [-1.00198x]
  L1 Hits:                           254639|255412               (-0.30265%) [-1.00304x]
  LL Hits:                             3164|3036                 (+4.21607%) [+1.04216x]
  RAM Hits:                            2220|2228                 (-0.35907%) [-1.00360x]
  Total read+write:                  260023|260676               (-0.25050%) [-1.00251x]
  Estimated Cycles:                  348159|348572               (-0.11848%) [-1.00119x]
  Ge:                                  1172|1172                 (No change)
benches_callgrind::bench_sum_of_squares_group::bench_sum_of_squares tenthousand:10000
  Baselines:                               |default_licm
  Instructions:                      192536|192901               (-0.18922%) [-1.00190x]
  L1 Hits:                           263824|264531               (-0.26727%) [-1.00268x]
  LL Hits:                             3286|3224                 (+1.92308%) [+1.01923x]
  RAM Hits:                            2783|2791                 (-0.28664%) [-1.00287x]
  Total read+write:                  269893|270546               (-0.24136%) [-1.00242x]
  Estimated Cycles:                  377659|378336               (-0.17894%) [-1.00179x]
  Ge:                                  1170|1170                 (No change)
benches_callgrind::bench_sum_of_squares_group::bench_sum_of_squares hundredthousand:100000
  Baselines:                               |default_licm
  Instructions:                      282900|283287               (-0.13661%) [-1.00137x]
  L1 Hits:                           371290|372062               (-0.20749%) [-1.00208x]
  LL Hits:                             3163|3058                 (+3.43362%) [+1.03434x]
  RAM Hits:                            8418|8426                 (-0.09494%) [-1.00095x]
  Total read+write:                  382871|383546               (-0.17599%) [-1.00176x]
  Estimated Cycles:                  681735|682262               (-0.07724%) [-1.00077x]
  Ge:                                  1174|1174                 (No change)
```
