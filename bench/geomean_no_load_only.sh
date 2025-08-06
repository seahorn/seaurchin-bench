PY_CODE="$(dirname "${BASH_SOURCE[0]}")/geomean_no_load_only.py"
compute_geomean_perf() {
    python ${PY_CODE} "$1"
    return $?
}