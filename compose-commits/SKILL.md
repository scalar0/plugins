---
name: compose-commits
description: Create logically grouped commits by staging cohesive file sets, then compose validated conventional commit messages using the $commit-msg skill. Use when a repo has many changes that should be split into multiple commits, when a user asks to stage files and draft commit messages, or when pre-commit hooks enforce conventional format.
---

# Compose Commits

## Overview

Stage changes into small, cohesive commits and draft conventional commit messages by delegating to the `$commit-msg` skill once each group is staged.

## Workflow

1. **Inspect working tree**
    - Run `git status --short` to see all modifications.
    - If files are unrelated, prefer multiple commits; avoid mixing code, docs, and generated artifacts unless requested.

2. **Choose the next commit slice**
    - Pick a cohesive group (single crate, subsystem, or doc-only set).
    - Avoid staging `docs/` if the user requests they be ignored.
    - If uncertain, ask for confirmation before staging.

3. **Stage the slice**
    - Use `git add <paths...>` for the chosen group.
    - Re-check `git status --short` to confirm staging only intended files.

4. **Compose message via `$commit-msg`**
    - Invoke `$commit-msg` to generate `.gitcommit` for the staged slice.
    - Use a scope when it disambiguates (`agent`, `config`, `cli`, `server`, `vcs`).
    - Keep subject 1-50 chars, lower-case, no trailing period.

5. **Hand off to user**
    - Provide the staged file list and the commit message.
    - Ask the user to run `git commit -F .gitcommit` (or `--no-verify` if they explicitly want to bypass hooks).

6. **Repeat**
    - Iterate until the working tree is clean or only ignored files remain.

## Grouping heuristics

- Prefer crate- or layer-based slices (e.g., `core-*`, `cli`, `server`, `vcs`).
- Keep generated specs or snapshots in their own commit if they do not share code changes.
- Keep schema/config/doc updates with the code they describe when possible.
- If pre-commit hooks fail due to unrelated crates, warn the user and offer to fix or proceed with `--no-verify`.

## Notes

- Always rely on `$commit-msg` for drafting messages.
- Do not commit unless the user runs the `git commit` command.
