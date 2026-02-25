---
name: cargo
description: Standardize Rust workspace operations through cargo for build, lint, test, and coverage workflows. Use when running or troubleshooting cargo-based development and CI tasks.
---

# Cargo

## Overview

Run repeatable Rust workflows through bundled scripts for build, lint, test, and coverage with CI-friendly output.

## Workflow

1. Start from the repository root so workspace discovery is correct.
2. Choose one command path: `build`, `lint`, `test`, or `coverage`.
3. Run `scripts/run.sh <mode>` or the specific script directly.
4. Review output and fix issues before moving to the next stage.
5. Re-run the same command to confirm a clean pass.

## Script Entry Points

- Dispatcher: `scripts/run.sh`
- Build: `scripts/run_build.sh`
- Lint: `scripts/run_lint.sh`
- Test: `scripts/run_tests.sh`
- Coverage: `scripts/run_coverage.sh`

## References

- Build workflow: `references/build.md`
- Lint workflow: `references/lint.md`
- Test workflow: `references/test.md`
- Coverage workflow: `references/coverage.md`
- Runtime knobs: `references/environment-variables.md`
- Additional configuration: `references/config.md`

## Troubleshooting

- `fmt` failures: format and re-run.
- `clippy` failures: apply or justify targeted lint changes.
- Missing summary tooling: install `jq` and `yq`.
- Coverage table issues: verify `cargo-llvm-cov`, `jq`, and `xan` availability.
