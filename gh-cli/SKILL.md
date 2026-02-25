---
name: gh-cli
description: Use the GitHub CLI (`gh`) to inspect and automate repository, issue, pull request, workflow, and API tasks. Use when the request requires current GitHub state or structured GitHub output.
---

# GitHub CLI

## Overview

Use `gh` as the default command-line interface for GitHub data access, status checks, and automation.

## Workflow

1. Confirm auth and repo context (`gh auth status`, `git remote -v`).
2. Prefer structured output with `--json` plus `--jq` or `--template`.
3. Use `gh api` when high-level commands cannot express the query.
4. Keep commands non-interactive for automation (`GH_PROMPT_DISABLED=1` when needed).
5. Return concise, current results rather than relying on stale context.

## High-Value Commands

- `gh repo view`
- `gh pr list`
- `gh pr view <number>`
- `gh pr checks <number>`
- `gh issue list`
- `gh workflow list`
- `gh run list`

## References

- CLI reference: `references/cli.md`
- Output formatting: `references/output.md`
- Environment variables: `references/env.md`
- Exit codes: `references/exit-codes.md`
- Issue helper script: `scripts/get_issue.sh`
