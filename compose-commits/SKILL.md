---
name: compose-commits
description: Split a dirty working tree into cohesive staged slices and compose validated conventional commit messages by delegating to the commit-msg skill. Use when changes should be grouped into multiple logical commits.
---

# Compose Commits

## Overview

Create clean, reviewable commit slices by staging related changes together, then draft a message for each slice via `commit-msg`.

## Workflow

1. Inspect the tree with `git status --short`.
2. Pick one cohesive slice (single subsystem, feature, or docs-only group).
3. Stage only that slice with `git add <paths...>`.
4. Confirm staged content with `git status --short` and `git diff --staged`.
5. Run the `commit-msg` skill to draft `.gitcommit`.
6. Repeat until all intended changes are grouped.

## Grouping Heuristics

- Keep unrelated concerns in separate commits.
- Keep generated artifacts separate unless they are inseparable from source edits.
- Keep docs/config changes with the code they describe when practical.
- Ask for confirmation when file ownership or slice boundaries are unclear.

## Constraints

- Do not run `git commit` automatically unless explicitly requested.
- Always rely on `commit-msg` for final message drafting and validation.
