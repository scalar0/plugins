---
name: ci-gh-actions
description: Compose, review, and update GitHub Actions workflows with a focus on correctness, security (least privilege), and maintainability. Trigger when adding or modifying workflows, reusable workflows, caching, permissions, or expressions.
compatibility: Requires `gh` to validate workflows locally.
---

# GitHub Actions (CI) — authoring & maintenance

## What this skill covers

Use this skill when you need to:

- add or edit workflows under `.github/workflows/*.yml`
- adjust triggers (`on:`), matrices, concurrency, caching, environments
- implement reusable workflows (`workflow_call`) and share logic across repos
- tighten permissions for `GITHUB_TOKEN` (least privilege)
- use contexts/expressions safely (`if:`, `${{ }}`) and avoid common footguns

This workspace vendors upstream docs as markdown in `references/` for quick lookup.

## [Bundled References](references)

These files mirror the GitHub Docs “workflows and actions” reference. Open the smallest one that answers your question:

- [Syntax & structure](references/workflow-syntax.md)
- [Triggers/events](references/events-that-trigger-workflows.md)
- [Expressions](references/expressions.md)
- [Contexts](references/contexts.md)
- [Variables](references/variables.md)
- [Caching](references/dependency-caching.md)
- [Reuse](references/reusing-workflow-configurations.md)
- [Commands](references/workflow-commands.md)
- [Environments/deployments](references/deployments-and-environments.md)
- [Cancellation/concurrency patterns](references/workflow-cancellation.md)

## Authoring checklist (practical)

### 1) Triggers are correct and safe

- Prefer `pull_request` for PR validation.
- Be very careful with `pull_request_target`: it runs in the context of the base repo and can expose secrets if misused.
- Use `paths` / `paths-ignore` for noisy repos to reduce CI load.

### 2) Permissions are least-privilege

- Set workflow-level `permissions:` explicitly.
- Grant write scopes only to the job(s) that truly need them.

### 3) Actions are pinned

- Prefer pinning `uses:` to a full commit SHA for supply-chain safety.
- At minimum, pin to a major version and review upstream security posture.

### 4) Determinism & debuggability

- Set `timeout-minutes` for long-running jobs.
- Use `--locked` / lockfiles for package managers where applicable.
- Ensure logs contain enough context (print tool versions, relevant config).

### 5) Performance

- Use caching thoughtfully (dependency caches, tool caches).
- Avoid caching build artifacts that are invalidated frequently.
- Use matrices for supported versions, but keep them minimal.

## Common patterns

### Minimal “CI” skeleton

When creating a workflow from scratch, start with:

- `on: [push, pull_request]` (or a narrower set)
- `permissions: read-all` (or more specific)
- `actions/checkout`
- a setup step for your language/toolchain
- `run:` steps for lint/test/build

### [Reusable workflows](references/reusing-workflow-configurations.md)

When multiple workflows share logic:

- Extract shared logic into a reusable workflow using `on: workflow_call`.
- Define typed inputs and explicitly mapped secrets.

### [Dependency caching](references/dependency-caching.md)

- Prefer official caching patterns for ecosystems.
- Cache keys should incorporate lockfile hashes.
- Use restore keys carefully to avoid “stale but passing” builds.

See: `references/dependency-caching.md`

## Troubleshooting

- YAML errors / unexpected behavior: re-check indentation and quoting rules; then verify against `workflow-syntax.md`.
- Expression surprises: confirm which context is available at that location and event type; see `contexts.md` + `expressions.md`.
- Permission errors: inspect effective `GITHUB_TOKEN` permissions; make `permissions:` explicit at workflow/job level.
- “It works on main but not on PRs”: check fork behavior, `pull_request` vs `pull_request_target`, and secret availability.

## Updating the bundled reference docs

This repo includes `scripts/update.py`, which can download the latest markdown reference set.

Typical usage is to write into `references/` (from repo root):

- `python scripts/update.py -o references`

Note: The script fetches from GitHub’s docs repository; the bundled files may contain GitHub Docs templating tags (e.g. `{% data ... %}`), but the sections and headings are still useful for lookup.
