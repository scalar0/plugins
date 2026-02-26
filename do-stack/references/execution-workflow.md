# Do Stack Execution Workflow

## Purpose

Execute `$stack-plan` output deterministically while preserving review concurrency.

## Roles

- Overseer:
    - Compile and read execution manifest.
    - Dispatch task subagents.
    - Execute Graphite commands only.
    - Must not implement task code or author commit messages directly.
- Implementation subagent:
    - Implement each task and stage code.
- Commit-message subagent:
    - Generate commit message using `$commit-msg` for each `create` step.

## Input Contracts

- Stack plan input:
    - Produced by `$stack-plan`
    - Contains deterministic ordered `gt_commands` per `pr_index`
- Commit messages:
    - Generated just-in-time via `$commit-msg` for each `create` step.
    - Replaced into command args at execution time.

## Compile Phase

Run:

```bash
./scripts/prepare_stack_execution.sh \
  --plan /abs/path/stack-plan.json \
  --output /abs/path/execution.json
```

Compile behavior:

- Resolve repo root via `git rev-parse --show-toplevel`.
- Keep command order deterministic.
- Keep `commit_message_placeholder` unresolved in compiled output.
- Emit required `delegation` metadata per task (implementation + commit-message subagents).
- Preserve per-PR command sequence exactly as `[create, submit]`.
- Preserve stack create branch naming from `$stack-plan`: `stack/<plan-slug>/<task-id-slug>`.
- Emit `.commands[]` with explicit `step_index` for auditable execution.
- Emit command ownership fields:
    - `execution_owner: "overseer"`
    - `requires_subagent: "commit-message"` for JIT create steps.

## Execute Phase

For each task in `.tasks[]` order:

1. Overseer dispatches implementation subagent using task context.
2. Wait for staged changes and verification summary.

For each command in `.commands[]` order:

1. Read `args`, `why`, `pr_index`, `task_id`, `step_index`.
2. If `jit_commit_msg == true`:
    - Overseer dispatches commit-message subagent using `$commit-msg`.
    - Continue only after the subagent returns one validated commit message.
    - Resolve create args:

```bash
./scripts/resolve_jit_create_args.sh \
  --execution /abs/path/execution.json \
  --step-index <step_index> \
  --commit-message "<generated commit message>"
```

- Use `resolved_args` for execution.

3. Call `mcp__graphite__run_gt_cmd` with:
    - `args`: resolved args for JIT steps, otherwise command args
    - `cwd`: `repo_root` from manifest
    - `why`: from command
4. Stop on first command failure.

## Constraints

- Do not add extra mutating Graphite commands outside compiled plan commands.
- Keep outputs deterministic for identical inputs.
