---
name: uv
description: Manage Python environments and dependencies with the uv CLI. Use when syncing environments, updating lockfiles, running Python tooling, or troubleshooting uv resolution and index issues.
---

# uv

## Overview

Use `uv` as the default interface for Python dependency management, lockfile maintenance, and command execution in this repository.

## Workflow

1. Sync environment state with `uv sync` (or `uv sync --locked` in CI-like flows).
2. Add or update dependencies with `uv add`, `uv remove`, or `uv lock`.
3. Run tools and scripts via `uv run <command>`.
4. Validate lockfile and dependency graph before finishing.

## High-Value Commands

- Environment and lockfile: `uv sync`, `uv lock`, `uv export`, `uv tree`
- Dependency changes: `uv add`, `uv remove`
- Execution: `uv run`, `uv tool`, `uv python`, `uv pip`
- Discovery and help: `uv help`

## References

- Full CLI reference: `references/cli.md`
- Settings: `references/settings.md`
- Environment variables: `references/environment-variables.md`

## Troubleshooting

- Resolver conflicts: run `uv lock` and re-check constraints.
- Lockfile drift in CI: regenerate and commit `uv.lock`.
- Index/auth issues: validate configured indexes and credentials.
