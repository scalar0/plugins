#!/usr/bin/env bash
set -euo pipefail

# Unified entrypoint for the `cargo` skill.
# Usage:
#   ./skills/cargo/scripts/run.sh build|lint|test|coverage

cmd=${1:-}
case "$cmd" in
  build)
    exec "$(dirname "$0")/run_build.sh"
    ;;
  lint)
    exec "$(dirname "$0")/run_lint.sh"
    ;;
  test)
    exec "$(dirname "$0")/run_tests.sh"
    ;;
  coverage)
    exec "$(dirname "$0")/run_coverage.sh"
    ;;
  *)
    echo "Usage: $0 build|lint|test|coverage" >&2
    exit 2
    ;;
esac
