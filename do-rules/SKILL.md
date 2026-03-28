---
name: do-rules
description: Derive Codex execpolicy rule files for command-line tools. Use when asked to create or update `*.rules` files for a CLI, classify subcommands into `allow`, `prompt`, or `forbidden`, add `justification` and `match` examples to every `prefix_rule`, or validate rule behavior with `codex execpolicy check`.
---

# Do Rules

## Overview

Turn a CLI command surface into a Codex execpolicy rules file with explicit `prefix_rule(...)` entries, concrete examples, and validation against representative commands.

Read [references/classification.md](references/classification.md) when the CLI has mixed read/write command families, ambiguous subcommands, or rule precedence problems.

## Workflow

1. Inspect the local CLI first.

- Read the current `*.rules` file if one exists.
- Enumerate the installed command surface with local help before using external docs.
- Prefer concrete command trees such as `<tool> --help`, `<tool> --list`, `help -a`, or subcommand help for mixed families.
- If the tool is not installed, fall back to primary vendor documentation and say that you did so.

2. Map the command tree before writing rules.

- Separate clearly read-only commands from state-changing commands.
- Inspect nested subcommands for mixed families instead of classifying an entire top-level group by name alone.
- Spot-check ambiguous commands whose behavior changes by flags or positionals.

3. Classify conservatively.

- Use `allow` for commands that only print help, inspect state, validate data, or emit read-only reports.
- Use `prompt` for commands that write files, mutate local config, alter caches, install packages, change auth state, run scripts, execute arbitrary code, launch servers or GUIs, or change remote state.
- Use `prompt` for mixed command families when the rule engine cannot cleanly separate read-only variants from mutating variants.
- Use `forbidden` only for commands that should categorically never run through execpolicy in the target environment, and include a safer alternative when one exists.

4. Write the rules file explicitly.

- Include `decision`, `justification`, and `match` on every `prefix_rule`.
- Group read-only rules first and mutating rules after them, but do not rely on that ordering alone to save overlapping patterns.
- Keep `match` examples representative and realistic.
- When there is no existing target file, create `<tool>.rules`.

5. Add or update deterministic execpolicy cases.

- If the repository has `tests/execpolicy/cases.toml`, add representative fixtures for the rule file you created or changed.
- Keep cases in the shared `[[case]]` array format with `name`, `rules`, `expected`, and `command`.
- Cover at least one `allow` and one mutating decision for each rule file you touch; include `forbidden` when the policy uses it.
- Add overlap or nested-prefix cases when precedence is part of the risk.

6. Avoid precedence traps.

- Validate overlapping prefixes with `codex execpolicy check`.
- If a broad prompt rule overrides a specific allow rule, do not assume the more specific rule will win.
- Prefer non-overlapping patterns over broad families plus exceptions.
- If the grammar or matcher cannot express a safe exception cleanly, classify the family conservatively as `prompt`.

7. Validate before finishing.

- Run `codex execpolicy check --rules <file> <command...>` for representative `allow`, `prompt`, and `forbidden` cases.
- Include overlap tests for nested commands and mixed families.
- If `tests/execpolicy/test_execpolicy.py` exists, run that suite after updating `cases.toml`.
- Fix parse failures caused by invalid `match` or `not_match` examples before reporting completion.

## Output Shape

Use this structure:

```python
prefix_rule(
    pattern = ["tool", "subcommand"],
    decision = "allow",
    justification = "Why this command is safe.",
    match = [
        "tool subcommand --example",
    ],
)
```

Use grouped patterns only when every variant in the group has the same risk profile.

## Notes

- Prefer local command discovery over memory.
- Prefer primary documentation over secondary summaries when local discovery is unavailable.
- Keep the skill output concise, but make the rules file explicit enough that future edits do not require rediscovering the command surface from scratch.
