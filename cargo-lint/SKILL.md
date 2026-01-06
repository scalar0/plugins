---
name: cargo-lint
description: Run cargo fmt and clippy with consistent flags in sequence. Formats code first, then runs clippy with auto-fixes. Trigger when asked to lint, check, or format Rust code.
compatibility: Requires cargo, rustfmt, cargo-clippy
---

# Cargo Lint

## Overview

Standardize linting by running `cargo-fmt` and `cargo-clippy` in sequence with consistent flags. Formats code first, then applies clippy suggestions automatically.

## Quick Start

1. Run `skills/cargo-lint/scripts/run_lint.sh` from repository root.
2. Review and fix any formatting issues first.
3. Allow clippy to apply auto-fixes, then review changes.
4. Rerun script until all checks pass.

## Workflow

1. **Format first**: `cargo fmt --all` formats all code in the workspace.
2. **Lint with clippy**: `cargo clippy --all-features --fix --allow-dirty --message-format=short`
3. **Environment**: Disable color output by prefixing cargo commands with `NO_COLOR=1`
4. **Execution order**: Formatting must succeed before clippy runs.
5. **Fix mode**: `--fix --allow-dirty` applies safe automatic fixes to all files.

## Best Practices

- **Order matters**: Always run format before `cargo clippy` to avoid style conflicts.
- **Disable colors**: Use colorless output for CI and log parsing.
- **Workspace scope**: Lint entire workspace with `--all-features` to catch feature-gated issues.
- **Review auto-fixes**: Inspect changes made by `--fix` before committing.
- **Run from root**: Execute from repository root for proper workspace resolution.
- **Consistent flags**: Use the same lint configuration across all environments.

## Clippy Configuration

- **Auto-fix mode**: `--fix` applies suggestions automatically
- **Allow dirty**: `--allow-dirty` permits fixes in uncommitted files
- **Message format**: `--message-format=short` provides concise output
- **All features**: `--all-features` checks feature-gated code

## Failure Handling

1. **Formatting failures**: Fix code to match rustfmt style guidelines.
2. **Clippy warnings**: Address lints or add `#[allow(...)]` attributes where appropriate.
3. **Review changes**: If clippy modifies code, review before committing.
4. **Restage files**: After auto-fixes, restage modified files for commit.
