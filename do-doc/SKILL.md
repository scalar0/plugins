---
name: do-doc
description: Comment code for clarity and maintainability, and add or update README documentation when needed. Use for requests that ask to add inline comments, add docstrings, explain complex logic in-code, or produce/update a README (setup, usage, architecture, or contribution notes) as part of a code change.
---

# Do Doc

Use this skill to produce high-quality code comments and README updates alongside code changes.

## Workflow

1. Identify the target scope.

- Determine the files or modules that need comments or documentation updates.
- Confirm whether a README exists and where (root or package-level).
- In case of a tree-like repo structure (for example a multi-crate Rust codebase), you must spawn subagents to update the documentation of each sub-package using the `do-doc` skill, then aggregate their findings to update the documentation at your level if needed. Recursively documenting the code is the most effective way to ensure comprehensive documentation coverage.

2. Comment code only where it adds value.

- Prefer concise docstrings or block comments for non-obvious intent, invariants, and edge cases.
- Avoid redundant comments that restate obvious code.
- Follow existing style conventions (docstring format, comment style, language conventions).
- Keep comments accurate and durable; avoid references to line numbers or fragile wording.

3. Update or add README content when necessary.

- Add sections only when the change introduces new setup, usage, configuration, or operational details.
- Keep README concise and task-focused.
- Include command examples in fenced code blocks with appropriate info strings.
- If no README exists and documentation is required, create a minimal README with: Overview, Setup, Usage, and Notes.

4. Validate documentation coverage.

- Ensure new comments match the final code behavior.
- Ensure README instructions are correct for the current repo structure.

## Output expectations

- Provide code comments that explain intent, constraints, and non-obvious tradeoffs.
- Provide README changes only when they are justified by the change.
- If comments or README are not needed, say so and explain why briefly.
