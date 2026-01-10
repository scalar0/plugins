#!/usr/bin/env bash
set -euo pipefail

# Enforce repo lint contract for fmt + clippy.
# Mirrors .github/scripts/check.sh per AGENTS.md guidance.

cargo fmt --all && \
CARGO_TERM_COLOR=never cargo clippy --all-features --fix --allow-dirty --message-format=short
