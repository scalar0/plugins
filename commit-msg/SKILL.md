---
name: commit-msg
description: Generate conventional commit messages from staged changes using the local commit template and validation hook. Use when asked to draft, fix, or polish a commit message.
---

# Commit Message

## Workflow

1. Collect staged context with `git diff --cached`.
2. Locate template commit message by running `git config get commit.template`. Read it for required format and constraints, rules are also described below.
3. Draft message in `.gitcommit`.
4. Validate with `git hook run commit-msg -- .gitcommit`.
5. Revise and update `.gitcommit` until validation passes.

## Message Rules

- Format: `type[(scope)][!]: subject`
- Types: `feat|fix|refactor|fmt|test|docs|build|chore`
- Subject: 1-50 chars, start lower-case, no trailing period.
- Scope: optional; use crate/feature for clarity, alphanum plus `/` or `-`.
- Breaking: add `!` after type or scope and a `BREAKING CHANGE:` footer.
- Body: optional; explain what/why in short bullets, ~72 cols; reference key files.
- Footers: one per line; common `Closes: #id`, `Refs: #id`.
