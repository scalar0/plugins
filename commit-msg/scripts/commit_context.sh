#!/usr/bin/env bash
set -euo pipefail

# Provide color-free staged diff context for commit message generation.
# Mirrors .github/scripts/commit.sh but lives inside the skill for portability.

export NO_COLOR=1

declare -r context=$(echo "${1:-null}" | rg -viP '^(diff --git |\+\+\+ |--- |@@ )')
declare -r root=$(git rev-parse --show-toplevel)

cp -f "$root/.config/hooks/.gitcommit" "$root/.gitcommit"

declare -r name_status=$(git --no-pager diff --staged --name-status -M -C --no-color)
declare -r diff=$(git --no-pager diff --staged --diff-algorithm=minimal -U0 -M -C -w --no-color | rg -viP '\s+-+\s+IGNORE\s+-+')
declare -r mutants=$(git --no-pager diff --staged --diff-algorithm=minimal -U0 -M -C -w --no-color | rg -iP '/* ~ changed by cargo-mutants ~ */')

declare final_context=""

if [[ -n $context ]]; then final_context+="===CONTEXT===\n$context"; fi
if [[ -n $name_status ]]; then final_context+="\n===STAGED CHANGES SUMMARY===\n$name_status"; fi
if [[ -n $diff ]]; then final_context+="\n===DIFF===\n$diff"; fi
if [[ -n $mutants ]]; then final_context+="\n===CARGO-MUTANTS===\n$mutants"; fi

echo -e "$final_context"
