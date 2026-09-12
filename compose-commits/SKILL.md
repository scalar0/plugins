---
name: compose-commits
description: Plan commit groups, stage one group, or create requested commits from a dirty working tree.
---

# Compose Commits

## Workflow

Inspect `git status --short`, the staged diff, and the unstaged diff before selecting groups.
Group each feature or subsystem with its required documentation, configuration, and generated files.

| Request        | Completion condition                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------- |
| Plan groups    | Return an ordered group list with paths or hunks and draft messages. Keep the index unchanged.                |
| Stage a group  | Stage only the selected group. Return its checked diff and validated message. Leave later groups unstaged.    |
| Create commits | Stage, validate, and commit one group before starting the next. Stop after all requested groups have commits. |

Choose the mode from the request and existing authorization.
Preserve unrelated staged content.
Use path staging only when every change in the file belongs to the selected group.
Use hunk staging for mixed files.
Use `commit-msg` with each group's diff to prepare its message.
For authorized commits, use a separate message file per group.
After each commit, confirm its contents and the remaining changes before starting the next group.

When group boundaries are uncertain, inspect hunk correlations with [commit_slices.py](scripts/commit_slices.py):

```bash
uv run --no-project python -B <skill-dir>/scripts/commit_slices.py --output <temporary-dir> [--staged] [--paths <path>...]
```

The script writes `hunks.csv` and `corr.csv`; use correlations as evidence, not as ownership or semantic truth.

- Keep unrelated concerns separate and colocate documentation or configuration with the code it describes when practical.
- Ask when an unresolved ownership or group choice prevents the requested staging or commit.
- Run `git commit` only when the request authorizes commits.
- Use `commit-msg` for every final message.
