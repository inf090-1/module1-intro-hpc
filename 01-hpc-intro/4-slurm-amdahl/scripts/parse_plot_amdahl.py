#!/usr/bin/env python3
"""Parse amdahl package output and plot speedup vs Amdahl's Law.

Extracts timing data from amdahl runs and compares empirical speedup
to the theoretical Amdahl's Law prediction.

Usage:
  python3 parse_plot_amdahl.py [--results-dir amdahl_results]
"""
import argparse
import os
import re
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt


def parse_amdahl_output(filepath):
    """Parse amdahl output file and extract execution times.
    
    Looks for lines like:
      "Total execution time (according to rank 0): 18.480209 seconds"
    """
    times = []
    with open(filepath) as f:
        content = f.read()
        # Find all total execution time lines
        matches = re.findall(r'Total execution time \(according to rank 0\):\s+([\d.]+)\s+seconds', content)
        for match in matches:
            times.append(float(match))
    
    if not times:
        return None
    # Average the multiple runs
    return np.mean(times)


def amdahl_speedup(f, n):
    """Calculate theoretical Amdahl's Law speedup.
    
    f: fraction of code that is parallelizable
    n: number of processors
    """
    if n == 0:
        return 1.0
    return 1.0 / ((1.0 - f) + (f / n))


def extract_parallel_fraction(output_text):
    """Try to extract the parallel proportion from amdahl output."""
    match = re.search(r'with ([\d.]+) parallel proportion', output_text)
    if match:
        return float(match.group(1))
    return None


def main():
    p = argparse.ArgumentParser(description='Parse amdahl output and plot speedup')
    p.add_argument('--results-dir', default='amdahl_results', help='Results directory')
    p.add_argument('--out', default='amdahl_speedup.png', help='Output PNG path')
    args = p.parse_args()
    
    results_dir = Path(args.results_dir)
    if not results_dir.exists():
        print(f"Results directory {results_dir} not found")
        return 1
    
    # Parse all amdahl_*.txt files
    rank_counts = []
    times = []
    parallel_fraction = None
    
    print("Parsing amdahl output files...")
    for fpath in sorted(results_dir.glob('amdahl_[0-9]*.txt')):
        match = re.search(r'amdahl_(\d+)', fpath.name)
        if match:
            ranks = int(match.group(1))
            time_val = parse_amdahl_output(fpath)
            
            # Try to extract parallel fraction from first file
            if parallel_fraction is None:
                with open(fpath) as f:
                    content = f.read()
                    pf = extract_parallel_fraction(content)
                    if pf is not None:
                        parallel_fraction = pf
            
            if time_val is not None:
                rank_counts.append(ranks)
                times.append(time_val)
                print(f"  {ranks} ranks: {time_val:.4f} s")
    
    if not rank_counts:
        print("No data found in output files")
        return 1
    
    rank_counts = np.array(rank_counts)
    times = np.array(times)
    
    # Calculate empirical speedup relative to single rank
    baseline_idx = np.where(rank_counts == 1)[0]
    if len(baseline_idx) == 0:
        print("Warning: no 1-rank baseline found, using minimum time")
        baseline_time = np.min(times)
    else:
        baseline_time = times[baseline_idx[0]]
    
    empirical_speedup = baseline_time / times
    
    # Default to 0.8 (80% parallel) if we couldn't extract it
    if parallel_fraction is None:
        parallel_fraction = 0.8
        print(f"\nWarning: could not extract parallel fraction from output, using default f={parallel_fraction}")
    else:
        print(f"\nExtracted parallel fraction from output: f={parallel_fraction}")
    
    # Calculate theoretical Amdahl's Law speedup
    theoretical_speedup = np.array([amdahl_speedup(parallel_fraction, n) for n in rank_counts])
    
    # Plot
    plt.figure(figsize=(9, 6))
    plt.plot(rank_counts, empirical_speedup, 'o-', linewidth=2.5, markersize=10, 
             label='Empirical (observed)', color='#1f77b4')
    plt.plot(rank_counts, theoretical_speedup, 's--', linewidth=2.5, markersize=8, 
             label=f'Amdahl\'s Law (f={parallel_fraction:.2f})', color='#d62728')
    plt.plot(rank_counts, rank_counts, ':', linewidth=2, 
             label='Ideal linear speedup', color='#2ca02c')
    
    plt.xlabel('Number of MPI Ranks', fontsize=12, fontweight='bold')
    plt.ylabel('Speedup', fontsize=12, fontweight='bold')
    plt.title('Amdahl\'s Law: Empirical vs Theoretical Speedup', fontsize=14, fontweight='bold')
    plt.legend(fontsize=11, loc='upper left')
    plt.grid(True, which='both', ls='--', alpha=0.3)
    plt.xticks(rank_counts)
    
    # Set y-axis to start from 0 or 1, whichever is more sensible
    ax = plt.gca()
    ax.set_ylim(bottom=0)
    
    plt.tight_layout()
    
    out_path = Path(args.out)
    plt.savefig(out_path, dpi=100, bbox_inches='tight')
    print(f"\nPlot saved to {out_path}")
    
    # Print summary table
    print("\n" + "="*60)
    print("Speedup Summary")
    print("="*60)
    print(f"{'Ranks':<8} {'Time (s)':<12} {'Empirical':<12} {'Theoretical':<12} {'Ideal':<8}")
    print("-"*60)
    for ranks, t, emp, theo in zip(rank_counts, times, empirical_speedup, theoretical_speedup):
        print(f"{ranks:<8} {t:<12.4f} {emp:<12.3f} {theo:<12.3f} {ranks:<8.3f}")
    print("="*60)
    
    return 0


if __name__ == '__main__':
    exit(main())
