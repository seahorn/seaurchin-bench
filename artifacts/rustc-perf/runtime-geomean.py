import csv
import math
import sys
from collections import defaultdict

def geomean(values):
    if not values:
        return float('nan')
    product = 1.0
    for v in values:
        product *= v
        #print(f"Multiplying value: {v}, current product: {product}")
    return product ** (1.0 / len(values))

def median(lst):
    n = len(lst)
    if n == 0:
        return float('nan')
    sorted_lst = sorted(lst)
    mid = n // 2
    if n % 2 == 0:
        return (sorted_lst[mid - 1] + sorted_lst[mid]) / 2.0
    else:
        return sorted_lst[mid]

def min_value(lst):
    if not lst:
        return float('nan')
    return min(lst)

def read_csv(filename, new_key, old_key):
    data = defaultdict(lambda: {new_key: [], old_key: []})
    with open(filename, newline='') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            if len(row) != 4:
                continue  # skip malformed lines
            benchmark, artifact, metric, value = row
            if artifact in (new_key, old_key):
                try:
                    data[benchmark][artifact].append(float(value))
                except ValueError:
                    continue  # skip invalid values
    return data

def compute_ratios(data, new_key, old_key):
    ratios = []
    for benchmark, values in sorted(data.items()):
        g_old = median(values[old_key])
        g_new = median(values[new_key])
        ratio = None
        if g_old > 0 and not math.isnan(g_new):
            ratio = g_new / g_old
            ratios.append((benchmark, g_new, g_old, ratio))
        elif g_old == 0 and g_new == 0:
            ratio = 1.0
            ratios.append((benchmark, g_new, g_old, ratio))
        else:
            ratios.append((benchmark, None, None, None))
        print(f"Processed {benchmark}: new={g_new}, old={g_old}, ratio={ratio if ratio is not None else 'N/A'}")
    return ratios

def print_ratios(ratios, new_key, old_key):
    valid_ratios = []
    for benchmark, g_new, g_old, ratio in ratios:
        if ratio is not None:
            valid_ratios.append(ratio)
            print(f"{benchmark}: {new_key}={g_new:.2f}, {old_key}={g_old:.2f}, ratio={ratio:.4f}")
        else:
            print(f"{benchmark}: insufficient data")
    if valid_ratios:
        for i, ratio in enumerate(valid_ratios[:]):
            if ratio == 0:
                print(f"Removing benchmark: Zero ratio found for benchmark: {ratios[i][0]}")
                valid_ratios.remove(ratio)
        overall = geomean(valid_ratios)
        print(f"Geometric Mean: {overall:.10f}")
        improvement = (1.0 - overall) * 100
        print(f"Percentage Improvement: {improvement:.10f} %")
    else:
        print("No valid ratios computed.")

def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <input.csv> <new_key> <old_key>")
        sys.exit(1)
    filename = sys.argv[1]
    new_key = sys.argv[2]
    old_key = sys.argv[3]
    data = read_csv(filename, new_key, old_key)
    ratios = compute_ratios(data, new_key, old_key)
    print_ratios(ratios, new_key, old_key)

if __name__ == "__main__":
    main()
