# Stacking Workflow Reference

## Purpose

Map `do-plan` tasks to a Graphite stacked PR workflow with deterministic command objects.

## Mapping model

1. Flatten all `phases[].tasks[]` into an ordered list.
2. Assign `pr_index` from that flattened order starting at 1.
3. Convert each task dependency ID into `depends_on_prs` by looking up the dependent task's `pr_index`.
4. Do not emit `phase_id`; `task_id` carries the phase context.
5. Build branch names as `stack/<plan-slug>/<task-id-slug>`.
6. Emit deterministic commit message placeholders as `__COMMIT_MESSAGE_PR_<index>__`.
7. Emit submission metadata:

- top-level `graphite_submission` for global Graphite submit policy.
- per-task `pr_submission` for per-PR submit policy.
- default reviewer includes `scalar0`.
- AI metadata enrichment is enabled.

8. Emit per-task command sequence (exactly two commands):

- `gt create <branch_name> --all --message __COMMIT_MESSAGE_PR_<index>__ --no-interactive`
- `gt submit -r scalar0 --ai --no-interactive`

9. Emit stack-level command groups:

- `preflight`: inspect stack and branch context.
- `recovery`: sync/restack/continue/abort for conflict handling.

## Command object format

Use command objects compatible with Graphite MCP:

```json
{
    "tool": "mcp__graphite__run_gt_cmd",
    "args": [
        "create",
        "stack/implementation-plan/1-1",
        "--all",
        "--message",
        "__COMMIT_MESSAGE_PR_1__",
        "--no-interactive"
    ],
    "why": "Create stack branch for task 1.1 Task with executor-provided commit message"
}
```

Runtime context:

- Resolve repo root at execution with `git rev-parse --show-top-level`.
- Do not include `cwd` in stack-plan command objects.

## Ordering guarantees

- Preserve original `do-plan` phase/task order.
- Keep `depends_on_prs` sorted ascending.
- Use deterministic slugging for branch names.
- Keep `gt_commands` fixed to `[create, submit]` for each stack item.

## Source notes

- Stacked PR flow and command semantics align with Graphite docs:
    - https://graphite.dev/docs/quick-start
    - https://graphite.dev/docs/create-a-stack
    - https://graphite.dev/docs/command-reference
- The requirement to stack against a PR-stacking workflow is from MOM-18:
    - https://linear.app/momentum-eu/issue/MOM-18/implement-dollarstack-plan
