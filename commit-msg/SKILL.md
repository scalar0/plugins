---
name: commit-msg
description: Generate conventional commit messages from staged changes using the local commit template and validation hook. Use when asked to draft, fix, or polish a commit message.
---

# Commit Message

## Overview

Create concise, valid commit messages that match `.config/hooks/.gitcommit` and pass the local commit-message validator.

## Workflow

1. Collect staged context with `scripts/commit_context.sh "<extra context>"`.
2. Read `.config/hooks/.gitcommit` for required format and constraints.
3. Draft message in `./.gitcommit` using `type(scope): subject`.
4. Validate with `uv run --script .config/hooks/commit_msg/commit_msg.py .gitcommit`.
5. Revise until validation passes.

## Message Rules

- Allowed types: `feat`, `fix`, `refactor`, `fmt`, `test`, `docs`, `build`, `chore`.
- Keep subject concise and without trailing period.
- Use `!` plus a `BREAKING CHANGE:` footer when behavior breaks compatibility.
- Add body text only when it adds context beyond the subject.

## Resources

- Commit template: `.config/hooks/.gitcommit`
- Commit validator: `.config/hooks/commit_msg/commit_msg.py`
- Context collector: `scripts/commit_context.sh`
- Hook wiring reference: `.config/hooks/lefthook.toml`
