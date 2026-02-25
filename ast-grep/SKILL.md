---
name: ast-grep
description: Build and run ast-grep structural search rules for codebases. Use when a request requires AST-aware matching, relational code queries, or pattern search beyond text grep.
---

# ast-grep Code Search

## Overview

Use `ast-grep` to convert natural-language code search requests into structural rules that match syntax trees instead of raw text.

## Workflow

1. Confirm target language, required matches, and exclusions.
2. Create a minimal representative code sample.
3. Start with a simple rule, then add relational/composite logic.
4. Test against sample code before scanning the real codebase.
5. Run repository search and return structured, relevant results.

## Command Patterns

- Inspect syntax tree:
    - `ast-grep run --pattern '<pattern>' --lang <lang> --debug-query=cst`
- Quick pattern search:
    - `ast-grep run --pattern '<pattern>' --lang <lang> <path>`
- Rule-based search:
    - `ast-grep scan --rule <rule.yml> <path>`
- Inline rule test on stdin:
    - `echo '<code>' | ast-grep scan --inline-rules '<yaml>' --stdin`
- Structured output:
    - add `--json` to `run` or `scan`.

## Rule Guidelines

- Prefer `pattern` for simple one-node matches.
- Use `kind` with `has` or `inside` for structural requirements.
- For relational rules (`has`, `inside`, `precedes`, `follows`), default to `stopBy: end`.
- Build complex logic with `all`, `any`, and `not` incrementally.
- Escape metavariables in shell inline rules (`\$VAR`) when needed.

## Debugging

- If no matches, simplify the rule first.
- Check actual node kinds using `--debug-query=cst`.
- Verify the language parser and pattern shape align.
- Move from inline rules to rule files for non-trivial queries.

## References

- Rule reference: `references/rule_reference.md`
