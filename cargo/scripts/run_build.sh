#!/usr/bin/env bash
set -euo pipefail

# Enforce repo build contract for cargo build.
# Mirrors .github/scripts/build.sh and AGENTS.md quality gates.

cargo fmt --all && \
CARGO_TERM_COLOR=never cargo build --all-features --workspace --all-targets --message-format=short
