---
name: gh-cli
description: Use the GitHub CLI (`gh`) to inspect repositories, pull requests, issues, workflows, and API data from the terminal. Trigger when the user asks to check PR status/checks, list or view issues/PRs, run `gh api`, reason about `gh` exit codes/env vars, or produce structured output via `--json` with `--jq`/`--template`.
---

# GitHub CLI Skill

Follow this workflow when you need GitHub data or automation through `gh`. When asked to read a specific issue, use this [script](./scripts/get_issue.sh) with the issue id in argument to fetch it.

## 1) Confirm context

Run these early when repo or auth context may be unclear:

```bash
gh auth status
git remote -v
```

Prefer repo-scoped commands from the target repository directory. If you must operate outside a repo, set `GH_REPO`.

## 2) Prefer structured output

When results will be parsed, filtered, or reused, prefer JSON:

```bash
gh <cmd> --json <fields>
```

Then shape the result:

```bash
gh <cmd> --json <fields> --jq '<expression>'
gh <cmd> --json <fields> --template '<go-template>'
```

If you do not know the available JSON fields, omit the field list once to discover them:

```bash
gh <cmd> --json
```

See `references/output.md` for formatting rules, helper functions, and examples.

## 3) Use the API for gaps

When a CLI subcommand cannot express what you need, use the API:

```bash
gh api <endpoint>
```

Common patterns:

```bash
gh api /repos/{owner}/{repo}/pulls
gh api /repos/{owner}/{repo}/actions/runs --paginate
```

Add `--method`, `--field`/`--raw-field`, and `--paginate` as needed.

## 4) Handle non-interactive execution

For automation or CI-like contexts:

- Set `GH_TOKEN` (or enterprise equivalents) instead of interactive login.
- Set `GH_PROMPT_DISABLED=1` to avoid prompts.
- Use `--json` plus `--jq`/`--template` to keep output stable.
- Check exit codes for control flow.

See:

- `references/env.md` for environment variables.
- `references/exit-codes.md` for exit-code semantics.

## 5) Load only the references you need

Use progressive disclosure to keep context lean:

- Command discovery or flags: open `references/cli.md` and search with `rg`.
- Output shaping: open `references/output.md`.
- Auth, hosts, repos, and non-interactive behavior: open `references/env.md`.
- Control flow and failure handling: open `references/exit-codes.md`.

For `references/cli.md` (large), prefer targeted search:

```bash
rg "^## gh (pr|issue|workflow|run|api)" references/cli.md
rg "^### gh pr checks" references/cli.md
```

## 6) Common high-value commands

Use these as fast defaults, then refine with `--json`:

```bash
gh repo view
gh pr list
gh pr view <number>
gh pr checks <number>
gh issue list
gh workflow list
gh run list
```

When the user asks for “latest” or “current” status, run the command now rather than relying on memory.
