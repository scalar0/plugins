---
name: xan
description: Work with the xan CLI (CSV data toolkit). Use when asked to explore, filter, transform, aggregate, join, or convert CSV data into other formats (e.g., JSON, Markdown) with xan commands, or when you need to reference xan subcommands/options from `xan help`.
compatibility: Requires xan
---

# Xan

## Overview

Use this skill to map user requests about CSV wrangling to xan CLI commands. Keep `SKILL.md` lean and load the generated help reference for the definitive command list.

## Quick start

- Run the help updater [script](scripts/update-references.sh).

## Workflow

1. Identify the user’s CSV task (e.g., preview, filter, aggregate, join, convert).
2. Open the [general help](references/help.md) to confirm the exact command name and any aliases and narrow down the relevant subcommands.
3. If necessary, prefer `ripgrep` to search relevant commands or options in the [cheatsheet](references/cheatsheet.md) and [functions reference](references/functions.md).

## References

- General help is available [here](references/help.md)
- xan's DSL cheatsheet is available [here](references/cheatsheet.md)
- xan's DSL functions reference is available [here](references/functions.md)
