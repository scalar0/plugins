---
name: ast-grep
description: Search code with ast-grep when a query needs syntax structure or relationships that text search cannot express.
---

# ast-grep Code Search

## Workflow

1. Identify the target language, required matches, and exclusions.
2. Select the smallest rule that expresses the query.
3. For complex or uncertain rules, test a sample with expected matches and exclusions.
4. Search the requested paths.
5. Return the relevant matches and any unresolved query limits.

| Task                    | Command                                                              |
| ----------------------- | -------------------------------------------------------------------- |
| Inspect syntax          | `ast-grep run --pattern '<pattern>' --lang <lang> --debug-query=cst` |
| Search a pattern        | `ast-grep run --pattern '<pattern>' --lang <lang> <path>`            |
| Scan a rule             | `ast-grep scan --rule <rule.yml> <path>`                             |
| Test inline YAML        | `echo '<code>' \| ast-grep scan --inline-rules '<yaml>' --stdin`     |
| Emit structured results | Add `--json` to `run` or `scan`.                                     |

## Rule Guidelines

- Prefer `pattern` for simple one-node matches.
- Use `kind` with `has` or `inside` for structural requirements.
- For relational rules (`has`, `inside`, `precedes`, `follows`), default to `stopBy: end`.
- Combine rules with `all`, `any`, and `not`.
- Escape metavariables in shell inline rules (`\$VAR`) when needed.

## Debugging

If matching fails, simplify the rule, inspect node kinds with `--debug-query=cst`, and verify the language parser and pattern shape.
Move non-trivial inline rules to files and consult the [rule reference](references/rule_reference.md) for atomic, relational, composite, or metavariable semantics.
