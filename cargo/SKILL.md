---
name: cargo
description: Triggers when running any task with the cargo CLI. Special references are written for build, lint, test, and report coverage for Rust workspaces.
compatibility: Requires cargo, rustfmt, cargo-clippy, cargo-nextest, cargo-llvm-cov, jq, yq, xan
---

# Cargo

## Overview

Unified Rust workflow skill that standardizes:

- **Build**: format then `cargo build` across workspace/targets/features
- **Lint**: format then `cargo clippy` with safe auto-fixes
- **Test**: run tests via `cargo llvm-cov nextest` and summarize results
- **Coverage**: generate a per-file coverage table via `cargo llvm-cov report`

All commands aim for **deterministic, colorless output** suitable for CI/log parsing.

## Workflows

Full, per-command docs (preserved from the original `cargo-*` skills) are available here:

- [Build](references/build.md)
- [Lint](references/lint.md)
- [Test](references/test.md)
- [Coverage](references/coverage.md)

## Scripts

### [Unified Dispatcher](scripts/run.sh)

Dispatches to the appropriate script based on the first argument (`build|lint|test|coverage`).

### [Build](scripts/run_build.sh)

1. `cargo fmt --all`
2. `cargo build --all-features --workspace --all-targets --message-format=short` with `CARGO_TERM_COLOR=never`

### [Lint](scripts/run_lint.sh)

1. `cargo fmt --all`
2. `cargo clippy --all-features --fix --allow-dirty --message-format=short` with `CARGO_TERM_COLOR=never`

### [Test](scripts/run_tests.sh)

Runs tests using nextest under llvm-cov instrumentation and prints a JSON summary derived from the generated JUnit report.

### [Coverage](scripts/run_coverage.sh)

Prints a per-file coverage table (functions/lines/regions) by extracting JSON from `cargo llvm-cov report` and formatting via `jq` + `xan`.

## Best Practices

- Run from the repo root to ensure workspace discovery and paths resolve correctly.
- Prefer `--workspace --all-targets --all-features` to catch cross-crate/feature-gated issues.
- Review changes after clippy auto-fix before committing.

## Failure Handling

- **fmt fails**: fix formatting issues first.
- **clippy fails**: address lints or add targeted `#[allow(...)]` with justification.
- **test summary tools missing**: install `jq` and `yq` (used to convert JUnit XML to JSON).
- **coverage formatting missing**: install `jq` and `xan`.

# [Environment Variables](references/environment-variables.md)

Full list of environment variables available for customizing behavior.
