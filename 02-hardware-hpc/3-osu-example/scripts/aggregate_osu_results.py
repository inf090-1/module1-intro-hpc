#!/usr/bin/env python3
"""Aggregate OSU benchmark results across multiple trials and compute statistics."""

import argparse
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path


def read_osu_file(path):
    """Parse a single OSU output file."""
    rows = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split()
            if len(parts) >= 2:
                try:
                    size = float(parts[0])
                    value = float(parts[1])
                    rows.append((size, value))
                except ValueError:
                    continue
    if rows:
        return pd.DataFrame(rows, columns=['size', 'value'])
    return None


def aggregate_trials(file_pattern, results_dir):
    """Aggregate results from multiple trial files matching a pattern."""
    files = sorted(results_dir.glob(file_pattern))
    if not files:
        print(f"No files matching {file_pattern}")
        return None
    
    # Read all files and aggregate by message size
    all_dfs = []
    for f in files:
        df = read_osu_file(f)
        if df is not None:
            all_dfs.append(df)
    
    if not all_dfs:
        return None
    
    # Combine and aggregate
    combined = pd.concat(all_dfs, ignore_index=True)
    aggregated = combined.groupby('size')['value'].agg(['mean', 'std', 'min', 'max'])
    return aggregated


def main():
    parser = argparse.ArgumentParser(description='Aggregate OSU benchmark trials')
    parser.add_argument('--results-dir', default='osu_results', help='Directory containing results')
    parser.add_argument('--out-prefix', default='aggregated', help='Output file prefix')
    parser.add_argument('--type', choices=['latency', 'bw'], default='latency')
    args = parser.parse_args()
    
    configs = [
        ('single_node_latency_trial*.txt', 'Single-Node'),
        ('multinode_eth_latency_trial*.txt', 'Multi-Node Ethernet'),
    ]
    
    if args.type == 'bw':
        configs = [
            ('single_node_bw_trial*.txt', 'Single-Node'),
            ('multinode_eth_bw_trial*.txt', 'Multi-Node Ethernet'),
        ]
    
    results_dir = Path(args.results_dir)
    if not results_dir.exists():
        print(f"Results directory {results_dir} not found")
        return 1
    

    # Aggregate each configuration
    results = {}
    for pattern, label in configs:
        agg = aggregate_trials(pattern, results_dir)
        if agg is not None:
            results[label] = agg
    
    if not results:
        print("No data to aggregate")
        return
    
    # Plot with error bars
    plt.figure(figsize=(10, 6))
    ylabel = 'Latency (µs)' if args.type == 'latency' else 'Bandwidth (MB/s)'
    
    for label, agg in results.items():
        plt.plot(agg.index, agg['mean'], marker='o', label=label, linewidth=2)
        plt.fill_between(agg.index, agg['min'], agg['max'], alpha=0.2)
    
    plt.xscale('log', base=2)
    plt.xlabel('Message Size (bytes)')
    plt.ylabel(ylabel)
    plt.title(f'OSU Benchmark: {ylabel} across Configurations (Mean ± Min/Max)')
    plt.legend()
    plt.grid(True, which='both', ls='--', lw=0.5)
    plt.tight_layout()
    
    outfile = results_dir / f'{args.out_prefix}_{args.type}_comparison.png'
    plt.savefig(outfile, dpi=150)
    print(f"Plot saved to {outfile}")
    
    # Save aggregated data to CSV
    csv_file = results_dir / f'{args.out_prefix}_{args.type}_stats.csv'
    for label, agg in results.items():
        agg['config'] = label
    combined_agg = pd.concat([agg.assign(config=label) for label, agg in results.items()])
    combined_agg.to_csv(csv_file)
    print(f"Statistics saved to {csv_file}")


if __name__ == '__main__':
    main()
