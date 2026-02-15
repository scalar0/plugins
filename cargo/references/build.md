# Cargo Build

This is the original `cargo-build` skill documentation, preserved as reference after merging into the unified `cargo` skill.

## Overview

Standardize build runs with consistent flags, colorless output, and format-first workflow. Ensures reproducible builds across environments.

## Quick Start

1. Run `skills/cargo/scripts/run_build.sh` from repository root.
2. Fix formatting errors first, then address compiler errors.
3. Rerun script until build succeeds.

## Workflow

1. **Format first**: `cargo fmt --all` ensures code is formatted before building.
2. **Build command**: `cargo build --all-features --workspace --all-targets --message-format=short`
3. **Scope**: Builds all targets (lib, bin, tests, examples, benches) across entire workspace with all features enabled.
4. **Output format**: `--message-format=short` provides concise, parseable output.

## Best Practices

- **Always disable colors**: Use `CARGO_TERM_COLOR=never` for consistent, parseable output.
- **Format before build**: Run `cargo fmt --all` to catch formatting issues early.
- **Use workspace builds**: Build entire workspace with `--workspace` unless targeting specific packages.
- **Enable all features**: Use `--all-features` to catch feature-gated compilation errors.
- **Run from root**: Execute from repository root to ensure proper workspace resolution.
- **Avoid ad hoc flags**: Use consistent, documented build commands rather than one-off invocations.

## Failure Handling

1. **Formatting failures**: Fix code formatting issues reported by `cargo fmt`.
2. **Compilation errors**: Address errors in the order reported by the compiler.
3. **Rerun full script**: Don’t run partial commands; always use the complete workflow.
