---
name: ci-gh-actions
description: Author and review GitHub Actions workflows with strong defaults for correctness, security, and maintainability. Use when adding or modifying workflow triggers, permissions, caching, expressions, or reusable workflows.
---

# GitHub Actions CI

## Overview

Design and maintain workflow files under `.github/workflows` with least privilege, deterministic behavior, and maintainable structure.

## Workflow

1. Confirm desired triggers, repositories, and event safety.
2. Define explicit `permissions` at workflow/job scope.
3. Implement jobs with pinned actions and clear timeouts.
4. Add caching and matrix strategy only where it materially helps.
5. Validate expressions/contexts and failure behavior.
6. Re-check for security and maintenance risks before finalizing.

## Practical Checklist

- Trigger safety: validate `pull_request` vs `pull_request_target` behavior.
- Least privilege: avoid unnecessary write permissions.
- Supply chain: pin `uses:` versions (prefer SHA pinning).
- Determinism: use lockfiles, stable tool versions, and explicit timeouts.
- Performance: use targeted caches keyed from lockfiles.

## References

- Workflow syntax: `references/workflow-syntax.md`
- Events and triggers: `references/events-that-trigger-workflows.md`
- Expressions and contexts: `references/expressions.md`, `references/contexts.md`
- Reusable workflows: `references/reusing-workflow-configurations.md`
- Caching: `references/dependency-caching.md`
- Commands and variables: `references/workflow-commands.md`, `references/variables.md`
- Deployments and environments: `references/deployments-and-environments.md`
- Cancellation/concurrency: `references/workflow-cancellation.md`

## Maintenance

- Update bundled docs with `python scripts/update.py -o references` when needed.
