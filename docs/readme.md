# HOWTO benchmark SeaUrchin

There are three test suites for `SeaUrchin`.

### Complilation benchmarks

### Performance benchmarks

```sh
ARTIFACTS="bstr" reframe  -c ../seaurchin-bench/bench/rfm_cargo_perf_test.py --exec-policy "serial" --performance-report  -S sourcesdir=$PWD/../seaurchin-bench  --run
```

### Micro benchmarks


### Building SeaUrchin

#### Building SeaUrchin-LLVM

#### Building SeaUrchin
