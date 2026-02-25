---
name: gh-fix-ci
description: Investigate failing GitHub PR checks, extract actionable GitHub Actions failures, and guide plan-then-fix execution. Use when users ask to diagnose or fix failing GitHub Actions checks for a PR.
---

# GitHub PR CI Fix

## Overview

Inspect failing PR checks with `gh`, collect relevant GitHub Actions logs, summarize root causes, and then implement fixes after plan approval.

## Workflow

1. Confirm GitHub auth and resolve target PR.
2. Inspect check status using the bundled inspector script.
3. Extract failure snippets and categorize failures by source.
4. Treat non-GitHub providers as out of scope and report their URLs.
5. Draft a concise fix plan (use `do-plan` when a formal plan is requested).
6. Implement approved changes and rerun targeted checks/tests.

## Primary Tooling

- Inspector script:
    - `python scripts/inspect_pr_checks.py --repo . --pr <number-or-url>`
- Structured output mode:
    - add `--json` to the same command.

## Manual Fallback Commands

- `gh pr checks <pr> --json name,state,bucket,link,startedAt,completedAt,workflow`
- `gh run view <run_id> --json name,workflowName,conclusion,status,url,event,headBranch,headSha`
- `gh run view <run_id> --log`

## Output Requirements

- List each failing check with status and details URL.
- Include short, relevant failure excerpts.
- Clearly separate actionable GitHub Actions failures from external checks.
