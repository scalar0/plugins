---
name: xan
description: Work with CSV data using the xan CLI for filtering, aggregation, joins, transformation, and export. Use when converting user data tasks into reproducible xan commands.
---

# Xan

## Overview

Translate CSV wrangling requests into concrete `xan` commands using local reference docs for command and DSL accuracy.

## Workflow

1. Classify the task: inspect, filter, aggregate, join, transform, or convert.
2. Confirm command syntax in `references/help.md`.
3. Resolve DSL details with `references/cheatsheet.md` and `references/functions.md`.
4. Produce the smallest reproducible command pipeline for the request.

## References

- General help: `references/help.md`
- DSL cheatsheet: `references/cheatsheet.md`
- DSL functions: `references/functions.md`

## Maintenance

- Refresh generated references with `scripts/update-references.sh` when command docs drift.
