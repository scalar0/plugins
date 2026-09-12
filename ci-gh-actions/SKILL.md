---
name: ci-gh-actions
description: Create, edit, or review GitHub Actions workflows, including triggers, permissions, caching, and reusable workflows.
---

# GitHub Actions CI

## Workflow

1. Confirm desired triggers, repositories, and event safety.
2. Validate `pull_request` versus `pull_request_target` trust boundaries.
3. Grant explicit least-privilege `permissions` at workflow or job scope.
4. Pin actions, preferably by SHA, and use lockfiles, stable tool versions, and explicit timeouts.
5. Add matrices or lockfile-keyed caches only when they materially improve coverage or runtime.
6. Validate expressions, contexts, cancellation, concurrency, and failure behavior before finalizing.

Use the [reference index](references/index.md) to select the relevant workflow documentation.
