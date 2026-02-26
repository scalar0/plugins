---
name: stack-plan
description: Convert `$do-plan` JSON plans into deterministic stacked pull request execution JSON for Graphite `gt`, including explicit `mcp__graphite__run_gt_cmd` command objects. Use when asked to turn a plan into a stack, define stack execution schema, map task dependencies to PR order, or mechanize plan execution through Graphite MCP.
---

# Stack Plan

## Overview

Transform structured implementation plans into machine-readable Graphite stack plans. Prefer the bundled `jq` transformer script for deterministic behavior instead of ad hoc manual rewrites.

## Inputs

- Required input: a JSON plan that follows `../do-plan/assets/schema.json`.
- Primary source format: `do-plan` JSON with `phases[].tasks[]`.
- Unsupported input: Markdown-only plans. Convert with `$do-plan` first.
- Execution context rule: resolve repo root at runtime with `git rev-parse --show-top-level`.

## Deterministic Workflow

1. Run the transformer script.

- Command:

```bash
./scripts/plan_to_stack.sh \
  --input /abs/path/plan.json \
  --output /abs/path/stack-plan.json
```

- Script behavior is deterministic for the same input.

2. Validate output shape.

- Confirm the output conforms to `assets/schema.json`.
- Confirm every `stack[].gt_commands[]` entry contains `tool`, `args`, and `why`.

3. Execute commands through Graphite MCP when requested.

- Use `execution.preflight[]` first.
- Implement task code slice-by-slice in `stack[].pr_index` order.
- Run each item's `gt_commands[]` through `mcp__graphite__run_gt_cmd`.
- Submit each PR immediately using the per-item `gt_commands[]` sequence.

## Transformation Rules

Use these rules exactly:

1. Emit one stack item per `do-plan` task.
2. Preserve input phase/task order for `pr_index`.
3. Map `task_dependencies` to `depends_on_prs` using task IDs.
4. Do not emit `phase_id` because `task_id` already encodes phase context.
5. Build branch names as deterministic slugs: `stack/<plan-slug>/<task-id-slug>`.
6. Do not emit concrete commit messages in stack metadata.
7. Emit deterministic placeholders as `commit_message_placeholder`: `__COMMIT_MESSAGE_PR_<index>__`.
8. Emit submission metadata:

- Top-level `graphite_submission` metadata describing stack submission policy.
- Per-task `pr_submission` metadata describing per-PR submission policy.
- Default reviewer must include `scalar0`.
- Submit policy must include AI metadata generation.

9. Attach exactly two command objects per stack item in order:

- `gt create <branch_name> --all --message __COMMIT_MESSAGE_PR_<index>__ --no-interactive`
- `gt submit -r scalar0 --ai --no-interactive`

10. Emit fixed `execution` command groups:

- `preflight`: `gt log short --no-interactive`, `gt state --no-interactive`
- `recovery`: `gt sync --no-interactive`, `gt restack --no-interactive`, `gt continue --no-interactive`, `gt abort --no-interactive`

## Output Contract

- Output must validate against `assets/schema.json`.
- Canonical example output is `assets/example-output.json`.
- Output must remain stable across repeated runs with unchanged inputs.
- `summary` must be collapsed into `source_plan`.
- `commit_message` must not appear in output metadata.
- `phase_id` must not appear in stack items.
- `cwd` must not appear in command objects.
- Every generated `gt` command args list must include `--no-interactive`.
- `stack[].gt_commands` must always contain exactly create then submit.
- `branch_name` must match `stack/<plan-slug>/<task-id-slug>`.
- Top-level `graphite_submission` metadata must be present and deterministic.
- Each `stack[]` item must include `pr_submission` metadata.
- Every `submit` command must include reviewer `scalar0` and `--ai`.

## Resources

- `scripts/plan_to_stack.sh`: entrypoint wrapper with argument parsing and input checks.
- `scripts/transform_do_plan_to_stack.jq`: deterministic transformation logic.
- `scripts/build_schema.jq`: schema source generator.
- `assets/schema.json`: JSON Schema for stack-plan output.
- `assets/example-input.json`: sample `do-plan` input.
- `assets/example-output.json`: generated stack-plan output from sample input.
- `references/stacking-workflow.md`: mapping to Graphite stacking semantics and MCP usage.

## Notes

- Keep this skill focused on transformation and execution planning, not code generation.
- If users ask to execute the resulting stack plan, run commands in the JSON order through Graphite MCP and report failures with the failing `pr_index`.
- Regenerate schema after schema-rule edits:

```bash
jq --indent 4 -n -f scripts/build_schema.jq > assets/schema.json
```
