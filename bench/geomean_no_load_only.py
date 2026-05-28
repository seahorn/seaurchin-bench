#!/usr/bin/env python3
import sys
import math

def parse_ratios_from_strict_blocks(filename):
    ratios = []

    with open(filename, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]

    i = 0
    while i + 3 < len(lines):
        name = lines[i]
        line2 = lines[i + 2]
        line3 = lines[i + 3]
        i += 4  # Skip to next block

        # Detect which is no_load_only and which is default
        if line2.startswith("no_load_only_licm"):
            no_load_only_line = line2
            default_line = line3
        elif line2.startswith("default_licm"):
            default_line = line2
            no_load_only_line = line3
        else:
            print(f"⚠️ Unrecognized format at benchmark '{name}'")
            sys.exit(1)
        default_metric = 0    
        no_load_only_metric = 0
        default_metric = 0
        try:
            no_load_only_metric = float(no_load_only_line.split()[1])
            default_metric = float(default_line.split()[1])
            if default_metric != 0:
                ratio = default_metric / no_load_only_metric
                ratios.append(ratio)
            else:
                print(f"⚠️ Zero default metric for benchmark '{name}'")
        except Exception as e:
            print(f"⚠️ Error parsing ratios for '{name}': {e}")
        print(f"Parsed benchmark '{name}': no_load_only={no_load_only_metric}, default={default_metric}, ratio={ratio if 'ratio' in locals() else 'undefined'}")
    return ratios

def geometric_mean(values):
    product = math.prod(values)
    return product ** (1 / len(values))

def main():
    if len(sys.argv) != 2:
        print("Usage: python geomean_structured.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    ratios = parse_ratios_from_strict_blocks(filename)

    if not ratios:
        print("No valid ratios found.")
        sys.exit(1)

    geomean = geometric_mean(ratios)
    improvement = (1 - geomean) * 100

    print(f"Geometric Mean: {geomean:.10f}")
    print(f"Percentage Improvement: {improvement:.2f} %")

if __name__ == "__main__":
    main()
