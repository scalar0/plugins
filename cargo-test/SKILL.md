---
name: cargo-test
description: Replaces cargo-test with cargo-nextest with llvm-cov for coverage and structured output. Provides JSON summaries of test results. Trigger when asked to run tests, get coverage, or validate code changes.
compatibility: Requires cargo-nextest
---

# Cargo Test

## Overview

Run tests using `cargo-nextest`. Provides colorless output, structured results, and coverage metrics in a single command.

## Quick Start

1. Run `skills/cargo-test/scripts/run_tests.sh` from repository root.
2. Wait for test execution to complete.
3. Review JSON summary showing pass/fail ratio and failing tests.
4. Fix failures and rerun.

## Workflow

1. **Run tests with coverage**: `cargo nextest run --workspace --all-targets --all-features`
2. **Environment**: Disable color output by prefixing cargo commands with `NO_COLOR=1` and hiding progress bar with `NEXTEST_SHOW_PROGRESS=none`
3. **Scope**: Runs all tests across workspace, including unit, integration, and doc tests.
4. **Output**: Generates JUnit XML and JSON summaries for CI integration.

## Best Practices

- **Use nextest**: Always prefer `cargo-nextest` over `cargo-test`.
- **Disable colors**: Keep output colorless for CI/log parsing.
- **Workspace scope**: Test entire workspace with `--workspace` to catch cross-crate issues.
- **All features**: Use `--all-features` to test feature-gated code paths.
- **Run from root**: Execute from repository root for proper artifact resolution.

## Output Formats

- **JUnit XML**: Structured test results for CI integration
- **JSON**: Machine-readable summary with fail ratios
- **Human-readable**: Console output showing pass/fail status

## Failure Handling

1. **Review failures**: Check test output for specific failure messages.
2. **Check artifacts**: Examine captured stdout/stderr in nextest output.
3. **Rerun failed tests**: Use nextest's retry and filtering capabilities.
4. **Fix and verify**: Address issues and rerun full test suite.

## Advantages over `cargo test`

- **Faster execution**: Parallel test running with better scheduling
- **Cleaner output**: Structured, less verbose test results
- **Better retries**: Intelligent retry logic for flaky tests
- **JUnit output**: Native CI integration format
- **Coverage integration**: Works seamlessly with cargo-llvm-cov
