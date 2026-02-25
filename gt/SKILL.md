---
name: gt
description: Operate Graphite CLI (`gt`) for stacked pull request workflows via the Graphite MCP tools. Use when a user asks to create, modify, restack, reorder, sync, submit, or troubleshoot stacked PRs, or to run `gt` commands for branch-stack navigation and PR lifecycle management.
---

# GT

## Overview

Use this skill to execute Graphite CLI workflows safely and consistently through MCP. Prefer small, reviewable stacked branches and non-interactive command variants when automating.

## Required Tools

- Use `mcp__graphite__learn_gt` to refresh command patterns and stack workflows.
- Use `mcp__graphite__run_gt_cmd` for every `gt` command execution.

## Execution Contract

1. Read repository state before mutating it.

- Prefer `gt log short` or `gt state` first.
- Confirm current branch and stack shape before writing or restacking.

2. Present the planned PR stack before writing code.

- Describe each planned PR in order from trunk upward.
- Request confirmation before implementing code for the stack.

3. Build each PR slice in strict sequence.

- Write code for PR1 first.
- Stage changes with `git add`.
- Create the first stack branch with `gt create --message "<commit title>"`.
- Repeat for each upstack PR.

4. Submit stacks non-interactively.

- Use `gt submit --no-interactive` when ready to publish.
- Include downstack branches as required by the current branch.

5. Summarize outcomes with traceable artifacts.

- Report branch names and key commands run.
- Provide the `/github/pr/...` link for the first PR after submit.

## MCP Command Pattern

Always call `mcp__graphite__run_gt_cmd` with:

- `args`: tokenized `gt` command arguments (never a shell string)
- `cwd`: absolute repository root path
- `why`: one-line intent

Example shape:

```json
{
    "args": ["submit", "--stack", "--no-interactive"],
    "cwd": "/abs/path/to/repo",
    "why": "Publish all branches in the current stack after local validation"
}
```

## Core Workflow

1. Inspect and orient.

- Run `gt log short` (or `gt log`) to inspect stack order.
- Run `gt checkout <branch>` only if the requested target branch is not current.

2. Create or extend a stack.

- Implement code changes for one logical slice.
- Run `gt create --all --message "<message>"`.
- Repeat for each additional slice.

3. Submit stack branches.

- Use `gt submit` for current branch plus downstack.
- Use `gt submit --stack` to include descendants in the current stack.
- Use `gt submit --stack --reviewers <user1,user2>` when reviewer assignment is requested.

4. Address review feedback anywhere in the stack.

- Checkout the affected branch.
- Apply edits, then run `gt modify --all` to amend and restack descendants.
- Use `gt modify --commit --all --message "<message>"` to preserve an explicit follow-up commit.
- Re-submit updated branches with `gt submit --stack`.

5. Sync trunk updates.

- Run `gt sync` to pull trunk, restack conflict-free branches, and clean merged/closed local branches.
- If `gt sync` reports conflicts, run `gt restack` on the flagged branch and resolve conflicts, then run `gt continue` or `gt abort`.

6. Reorganize a stack when requested.

- Run `gt reorder` to reorder branches between trunk and the current branch.
- Run `gt move --onto <branch>` to re-parent a branch.
- Use `gt create --insert` to add a branch between current branch and child.

## Decision Shortcuts

- User asks to "start a stack": use `gt create --all --message`.
- User asks to "open PRs for this stack": use `gt submit --stack`.
- User asks to "fix feedback on lower PR": use `gt checkout` + `gt modify --all` + `gt submit --stack`.
- User asks to "rebase on latest main": use `gt sync`; if conflicts, use `gt restack`.
- User asks to "change PR order": use `gt reorder` or `gt move --onto`.
- User asks to "navigate stack quickly": use `gt up`, `gt down`, `gt top`, `gt bottom`, and `gt checkout`.

## References

- Read `references/mcp-capabilities.md` for MCP-specific behavior and constraints.
- Read `references/graphite-workflows.md` for command-to-task mapping derived from official docs.
- Search `references/llms-full.txt` for a specific topic pertaining to the graphite documentation. This is the raw text of the Graphite documentation, optimized for LLM retrieval. Use it to find specific command flags, workflow patterns, or troubleshooting tips that may not be covered in the more concise `graphite-workflows.md`.
