---
name: destochastic
description: Extract skill procedures into scripts when repeated work or fragile command sequences need deterministic execution.
---

# Destochastic

## Contract

Preserve the target identity, triggers, objectives, scope, deliverables, output formats, acceptance criteria, side-effect boundaries, and user-visible behavior during extraction.
Extract deterministic work when reuse, failure risk, or reliability benefits justify an executable.
Keep contextual judgment, semantic interpretation, policy choices, and exception resolution with the agent.
Do not add executables without deterministic work or commit baselines, extraction maps, audit plans, or migration notes unless the target runtime needs them.

## Workflow

1. Read the target `SKILL.md`, relevant linked resources, applicable `AGENTS.md` files, and repository status.
2. Resolve [scripts/destochastic.py](scripts/destochastic.py) from this skill directory and run `inspect <target-skill>` to inventory headings, executable code blocks, fixed workflows, scripts, and local links.
3. Run `baseline <target-skill> --output <temporary-baseline.json>` before editing.
4. Rerun `baseline` with `--protect-heading <title>` or `--protect-lines <start>:<end>` for contract text missed by automatic protection.
5. Use [classification.md](references/classification.md) to classify each procedural span and record its source, deterministic contract, executable path, and retained agent decision in temporary notes.
6. Implement and test each selected chain before replacing its duplicated prose with an invocation and decision boundary.
7. Run validation that covers the changed resources and preserved contract.
8. Run `verify <target-skill> --baseline <temporary-baseline.json>`.
9. Run `inspect` again to account for remaining candidates and explain any deliberate deferral.

Keep the baseline outside the target skill.
Add `--require-new-executable` when the requested outcome requires a new executable.
A candidate can remain in prose when extraction adds maintenance cost without a useful reliability or reuse benefit.

## Executable Requirements

- Accept explicit inputs through arguments, files, stdin, or documented environment variables, and reject missing domain decisions instead of guessing.
- Provide `--help`, stable exit codes, actionable stderr, and machine-readable output for tool consumers.
- Make mutations idempotent or dry-runnable and validate exact targets before writing.
- Avoid model calls, free-form shell evaluation, hidden mutable state, and duplicated implementations.
- Link user-facing executables from the target `SKILL.md` and give each a shebang and executable bit.

## Validation

Exercise each executable on success, invalid input, and a safe repeated mutation.
Treat `verify` as a structural guard rather than classification proof, and restore the contract if it reports changed triggers, protected sections or text, broken links, or invalid executables.

## Deliverables

- Return the refactored skill and any added or changed executables.
- Report extracted mechanics, retained agent decisions, validation results, and reasons for deferred candidates.
