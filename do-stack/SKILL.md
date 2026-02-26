---
name: do-stack
description: 'Execute deterministic stacked PR workflows from `$stack-plan` JSON using an overseer/subagent model: the overseer orchestrates and runs Graphite commands, while subagents perform task implementation and commit-message generation. Use when asked to execute stack plans end-to-end with delegated implementation.'
---

# Do Stack

## Overview

Use this skill to run a prepared stack plan in strict deterministic order. Compile the plan into an execution manifest first, then execute every command in order through Graphite MCP.

## Roles

- Overseer agent:
    - Compile execution manifest.
    - Dispatch subagents.
    - Execute Graphite workflow commands.
    - Must not implement task code or author commit messages directly.
- Implementation subagent:
    - Implement task changes from task context.
    - Return staged code changes and verification summary.
- Commit-message subagent:
    - Generate commit message via `$commit-msg` after implementation is staged.
    - Return one validated commit message string.

## Inputs

- Required plan input: `$stack-plan` JSON (see `../stack-plan/assets/schema.json`).
- Required execution context: git repository root resolved via `git rev-parse --show-toplevel`.

## Required Tools

- Execute Graphite commands with `mcp__graphite__run_gt_cmd` only.
- Use `$commit-msg` through a commit-message subagent immediately before each `gt create`.

## Deterministic Workflow

1. Compile execution manifest.

- Run:

```bash
./scripts/prepare_stack_execution.sh --plan /abs/path/stack-plan.json --output /abs/path/execution.json
```

- Validate output against `assets/execution-schema.json`.

2. Execute preflight commands.

- Read `.commands[]` where `phase == "preflight"` in `step_index` order.
- For each command, call `mcp__graphite__run_gt_cmd`:
    - `args`: from manifest command
    - `cwd`: `repo_root` from manifest
    - `why`: from manifest command

3. Delegate implementation per task.

- Process `.tasks[]` in `pr_index` order.
- For each task, overseer must dispatch the implementation subagent using:
    - `task_id`, `task_name`, `implementation_steps`, `quality_gates`.
- Do not execute stack commands for a task until the implementation subagent returns staged changes.
- Commit-message generation for that task must also be delegated to the commit-message subagent at each JIT `create` step.

4. Execute stack commands.

- Process `.commands[]` where `phase == "stack"` in `step_index` order.
- For each step:
    - Report `step_index`, `pr_index`, `task_id`, and command args.
    - If `jit_commit_msg == true`:
        - Dispatch commit-message subagent (role `commit-message`, skill `$commit-msg`) from current staged context.
        - Do not continue until commit-message subagent returns a single validated message.
        - Resolve args by replacing `commit_message_placeholder` using: `./scripts/resolve_jit_create_args.sh --execution /abs/path/execution.json --step-index <step_index> --commit-message "<commit-msg output>"`

    - Execute with resolved args.

- Otherwise, execute args as-is.
- Run through `mcp__graphite__run_gt_cmd` with manifest `repo_root` as `cwd`.
- Do not reorder commands.

## Guarantees

- Deterministic command order for identical inputs.
- No hidden command insertion outside plan commands.
- Immediate submit behavior preserved because stack commands keep the `create` then `submit` sequence from `gt_commands[]`.
- Stack `create` command args preserve `stack/<plan-slug>/<task-id-slug>` branch naming from `$stack-plan`.
- Commit placeholders stay unresolved in the manifest until just-in-time replacement.
- Every task requires both subagent roles before completion.

## Resources

- Compiler script: `scripts/prepare_stack_execution.sh`
- Compiler jq: `scripts/compile_execution.jq`
- Execution schema generator jq: `scripts/build_execution_schema.jq`
- JIT resolver script: `scripts/resolve_jit_create_args.sh`
- Execution schema: `assets/execution-schema.json`
- Example stack plan input: `assets/example-stack-plan.json`
- Example compiled execution: `assets/example-execution.json`
- Workflow reference: `references/execution-workflow.md`

## Notes

- Keep this skill focused on orchestration, not planning.
- If input plan is invalid, fail before executing any Graphite command.
- Regenerate execution schema after schema-rule edits:

```bash
jq --indent 4 -n -f scripts/build_execution_schema.jq > assets/execution-schema.json
```
