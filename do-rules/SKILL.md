---
name: do-rules
description: Create or review Codex execpolicy rules and test command decisions, overlaps, and authorization boundaries.
---

# Do Rules

Use the user-supplied rules repository or `~/.codex/rules` as `<rules-dir>`.

## Artifacts

| Path                                        | Purpose                                                        |
| ------------------------------------------- | -------------------------------------------------------------- |
| `<rules-dir>/<tool>.rules`                  | Root-level execpolicy rules for a tool or related tool family. |
| `<rules-dir>/execpolicy/cases.csv`          | Decision fixtures shared by all rule files.                    |
| `<rules-dir>/execpolicy/test_execpolicy.py` | Fixture validation and execpolicy checks.                      |

## Discover and Classify

1. Inspect repository status and the existing target without disturbing unrelated changes.
2. Map the installed CLI from local help, including nested subcommands and flag- or positional-dependent behavior.
3. Use primary vendor documentation only when local discovery is unavailable, and disclose that fallback.
4. Apply the narrowest safe decision.

| Decision    | Boundary                                                                                                    |
| ----------- | ----------------------------------------------------------------------------------------------------------- |
| `allow`     | Only reads, inspects, validates, or prints information.                                                     |
| `prompt`    | Writes state, executes code, launches processes, or mixes safe and mutating forms that cannot be separated. |
| `forbidden` | Must never run through execpolicy in the target environment; provide a safer alternative when one exists.   |

Read [classification.md](references/classification.md) for mixed families, ambiguous arguments, or overlapping prefixes.

Apply explicit user-approved exceptions for bounded local workflows when the rule matcher can enforce the approved scope.
Test both approved commands and nearby unapproved forms.
Keep `prompt` when the matcher cannot enforce the boundary.

## Write Rules

Create or update `<rules-dir>/<tool>.rules` with explicit, preferably non-overlapping prefixes.
Order read-only rules before mutating rules for reviewability, but never rely on order or specificity for precedence.
Give every rule a decision, a risk-specific justification, and realistic parsing-valid `match` examples.
Group pattern alternatives only when every alternative has the same decision and risk.

```python
prefix_rule(
    pattern=["tool", "subcommand"],
    decision="allow",
    justification="Why this command is safe.",
    match=[
        "tool subcommand --example",
    ],
)
```

## Add Cases

Update `execpolicy/cases.csv` for every changed rule file with a CSV-aware writer.
Preserve the `command,expected,name,rules` header, encode `command` as a non-empty JSON string array, use the root-relative rule filename, and assign a unique non-empty name.
Keep each rule file's cases together and cover every decision used, mutating boundaries, and risky overlaps.

## Validate

Check representative commands for every decision and any overlap:

```bash
codex execpolicy check --rules <rules-dir>/<tool>.rules <command...>
```

Run the shared suite from `<rules-dir>`:

```bash
uv run --no-project python -B -m unittest execpolicy/test_execpolicy.py
```

Resolve parse errors, unmatched commands, and decision mismatches before finishing.
