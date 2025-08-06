PY_CODE="$(dirname "${BASH_SOURCE[0]}")/geomean.py"
compute_geomean_perf() {
    python ${PY_CODE} "$1"
    return $?
}