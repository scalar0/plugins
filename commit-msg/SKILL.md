---
name: commit-msg
description: Draft or revise a conventional commit message from a diff, with the repository template and hook when available.
---

# Commit Message

## Workflow

1. Inspect the supplied diff, or collect staged changes with `git diff --cached`.
2. If a commit template is configured, read it with the repository's message rules.
3. Inspect an existing `.gitcommit` before choosing the message file.
4. If the request includes revising that file, update it.
5. Otherwise, use a temporary message file when `.gitcommit` already contains unrelated text.
6. Draft the message in the selected file.
7. Validate with `git hook run --ignore-missing commit-msg -- <message-file>`.
8. Correct message errors until the hook passes, or report a hook failure unrelated to the message.

Use the rules below when the repository provides no template or message rules.
If the hook is absent, check those rules directly and report that hook validation was unavailable.
Return the final message and its file path when a file was used.

## Message Rules

- Format: `type[(scope)][!]: subject`
- Types: `feat|fix|refactor|fmt|test|docs|build|chore`
- Subject: 1-50 chars, start lower-case, no trailing period.
- Scope: optional crate or feature name using alphanumerics, `/`, or `-`.
- Breaking: add `!` after type or scope and a `BREAKING CHANGE:` footer.
- Body: optional short bullets explaining what and why at approximately 72 columns with key file references.
- Footers: one per line; common `Closes: #id`, `Refs: #id`.
