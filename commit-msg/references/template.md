# Conventional Commit Format

- Format: `type[(scope)][!]: subject`
- Types: `feat|fix|refactor|fmt|test|docs|build|chore`
- Subject: 1-50 chars, start lower-case, no trailing period.
- Scope: optional; use crate/feature for clarity, alphanum plus `/` or `-`.
- Breaking: add `!` after type or scope and a `BREAKING CHANGE:` footer.
- Body: optional; explain what/why in short bullets, ~72 cols; reference key files.
- Footers: one per line; common `Closes: #id`, `Refs: #id`.
