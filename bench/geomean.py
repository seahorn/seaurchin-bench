#!/usr/bin/env python3
import sys
import math

def parse_ratios_from_strict_blocks(filename, mode):
    ratios = []

    with open(filename, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]

    i = 0
    while i + 3 < len(lines):
        name = lines[i]
        line2 = lines[i + 2]
        line3 = lines[i + 3]
        i += 4  # Skip to next block

        # Determine which line is "new" and which is "old" based on mode
        if mode == "ownsem":
            if line2.startswith("ownsem_licm"):
                new_line = line2
                old_line = line3
            elif line2.startswith("default_licm"):
                old_line = line2
                new_line = line3
            else:
                print(f"⚠️ Unrecognized format at benchmark '{name}'")
                sys.exit(1)
        elif mode == "no_load_only":
            if line2.startswith("default_licm"):
                new_line = line2
                old_line = line3
            elif line2.startswith("no_load_only_licm"):
                old_line = line2
                new_line = line3
            else:
                print(f"⚠️ Unrecognized format at benchmark '{name}'")
                sys.exit(1)
        else:
            print(f"Unknown mode: {mode}")
            sys.exit(1)

        new_metric = 0
        old_metric = 0
        try:
            new_metric = float(new_line.split()[1])
            old_metric = float(old_line.split()[1])
            if old_metric != 0:
                ratios.append(new_metric / old_metric)
            else:
                print(f"⚠️ Zero old metric for benchmark '{name}'")
        except Exception as e:
            print(f"⚠️ Error parsing ratios for '{name}': {e}")
        print(f"Parsed benchmark '{name}': new={new_metric}, old={old_metric}, ratio={new_metric / old_metric if old_metric != 0 else 'undefined'}")
    return ratios

def geometric_mean(values):
    product = math.prod(values)
    return product ** (1 / len(values))

def main():
    if len(sys.argv) != 3:
        print("Usage: python geomean.py <filename> <mode>")
        print("mode: ownsem or no_load_only")
        sys.exit(1)

    filename = sys.argv[1]
    mode = sys.argv[2]
    ratios = parse_ratios_from_strict_blocks(filename, mode)

    if not ratios:
        print("No valid ratios found.")
        sys.exit(1)

    geomean = geometric_mean(ratios)
    improvement = (1 - geomean) * 100

    print(f"Geometric Mean: {geomean:.10f}")
    print(f"Percentage Improvement: {improvement:.2f} %")

if __name__ == "__main__":
    main()
