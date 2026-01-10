#!/usr/bin/env bash
set -euo pipefail

# Enforce repo coverage contract per AGENTS.md using llvm-cov report.

export NO_COLOR=1

echo "Files Coverage in Percentages:"
CARGO_TERM_COLOR=never cargo llvm-cov report --json --summary-only \
| jq -rc '[.data[].files[] | {file: .filename,functions: .summary.functions.percent,lines: .summary.lines.percent,regions: .summary.regions.percent}]' \
| xan from -f json \
| xan transform 1,2,3 'trunc(_*100)/100'
