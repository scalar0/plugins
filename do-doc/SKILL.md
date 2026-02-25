---
name: do-doc
description: Add or refine code comments and README documentation when changes require clearer intent, usage, or operational guidance. Use when asked for docstrings, inline comments, or README updates.
---

# Do Doc

## Overview

Improve maintainability by documenting non-obvious behavior in code and updating README content when user-facing behavior changes.

## Workflow

1. Identify which modules and docs are affected by the change.
2. Add comments only where intent, invariants, or tradeoffs are not obvious.
3. Keep comments accurate, durable, and consistent with local style.
4. Update README sections only when setup, usage, configuration, or architecture changed.
5. Recheck docs against the final code.

## Guidelines

- Prefer concise, high-signal comments over restating code.
- Avoid fragile references to line numbers or temporary implementation details.
- Use fenced command examples when README instructions include commands.
- If no documentation change is needed, state that explicitly with a brief reason.
