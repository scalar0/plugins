---
name: commit-msg
description: Generate concise, validated git commit messages for this repo using the staged diff, optional user context, and the .config/hooks/.gitcommit template. Trigger when asked to write or polish a commit message from staged changes.
---

# Commit Message

## Overview

Produce a high-quality commit message that matches the local template, is linted by `.config/hooks/commit-msg`, and stays brief while covering the staged changes. Uses the same flow as `.github/prompts/commit.prompt.md` with an embedded helper script for portability.

## Quick Start

1. Get context and diff preview: `skills/commit-msg/scripts/commit_context.sh "<extra context>"`.
2. Read `.config/hooks/.gitcommit` for format expectations.
3. Draft message in `./.gitcommit` respecting template and scope rules.
4. Validate: `.config/hooks/commit-msg .gitcommit`. Fix and rerun if needed.

## Workflow

1. **Collect inputs**
    - Optional user context passed as the script argument.
    - Script gathers staged name-status, minimal diff (ignoring IGNORE sections), and cargo-mutants markers.
2. **Understand template**
    - Format: `$type[($scope)][!]: $subject`, body optional, footers optional.
    - Types: feat, fix, refactor, fmt, test, docs, build, chore.
    - Subject: 1-50 chars, lower-case start, no trailing period.
3. **Draft**
    - Summarize main change in subject; use scope when it disambiguates (crate, module, feature flag).
    - Body (optional): what/why bullets, ~72 chars wrap, reference key files.
    - Breaking changes: add `!` and `BREAKING CHANGE:` footer.
4. **Validate & adjust**
    - Run `.config/hooks/commit-msg .gitcommit`.
    - Fix lint issues (length, type, scope, punctuation) and rerun until passing.

## Prompts & Scripts

| Resource                           | Purpose                               | When to use                           |
| ---------------------------------- | ------------------------------------- | ------------------------------------- |
| `.github/prompts/commit.prompt.md` | Upstream prompt flow                  | Follow when invoked via prompt runner |
| `scripts/commit_context.sh`        | Collect sanitized staged context/diff | Run locally before drafting           |
| `.config/hooks/.gitcommit`         | Commit template + lint rules          | Read first; validator enforces        |
| `.config/hooks/commit-msg`         | Lint/validate message                 | Final gate, rerun until clean         |

## Tips

- Prefer the smallest accurate subject; avoid restating file paths.
- Use scope for crate or feature (e.g., `(wgr-cli)`).
- If no staged changes, abort and prompt to stage or skip.
- Keep body minimal; omit if subject suffices.

## References

- Commit prompt: `.github/prompts/commit.prompt.md`
- Template: `.config/hooks/.gitcommit`
- Validator: `.config/hooks/commit-msg`
