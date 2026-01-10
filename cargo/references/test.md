# Cargo Test

This is the original `cargo-test` skill documentation, preserved as reference after merging into the unified `cargo` skill.

## Overview

Run tests using `cargo-nextest` (via `cargo llvm-cov nextest` in this repo’s scripts). Provides colorless output, structured results, and integrates well with CI.

## Quick Start

1. Run `skills/cargo/scripts/run_tests.sh` from repository root.
2. Wait for test execution to complete.
3. Review the JSON summary showing pass/fail ratio and failing tests.
4. Fix failures and rerun.

## Workflow

1. **Run tests (instrumented)**: `cargo llvm-cov nextest --profile=agent --workspace --all-targets --all-features`
2. **Environment**: Disable color output (`NO_COLOR=1`, `CARGO_TERM_COLOR=never`) and hide nextest progress (`NEXTEST_SHOW_PROGRESS=none`).
3. **Scope**: Runs all tests across the workspace.
4. **Output**: Uses the generated JUnit XML to produce a concise JSON summary.

## Best Practices

- **Use nextest**: Prefer `cargo-nextest` over `cargo test` for speed and better output.
- **Disable colors**: Keep output colorless for CI/log parsing.
- **Workspace scope**: Test the entire workspace to catch cross-crate issues.
- **All features**: Use `--all-features` to test feature-gated code paths.
- **Run from root**: Execute from repository root for proper artifact resolution.

## Failure Handling

1. **Review failures**: Check test output for specific failure messages.
2. **Check artifacts**: Examine captured stdout/stderr in nextest output.
3. **Rerun failed tests**: Use nextest filtering/retries when appropriate.
4. **Fix and verify**: Address issues and rerun the full suite.

## Advantages over `cargo test`

- Faster execution via better parallel scheduling
- Cleaner/structured output
- Better retry support for flaky tests
- JUnit output for CI integration
