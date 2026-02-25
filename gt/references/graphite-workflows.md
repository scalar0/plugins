# Graphite Workflow Notes (Docs-Derived)

This file condenses the official Graphite docs into a task-first command map.

## Source pages

- https://graphite.dev/docs/command-reference
- https://graphite.dev/docs/quick-start
- https://graphite.dev/docs/create-a-stack
- https://graphite.dev/docs/cli-tutorials
- https://graphite.dev/docs/cli-cheatsheet

## Task to command map

- Start a branch and commit staged work:
    - `gt create --all --message "<message>"`
- Update the current PR branch:
    - `gt modify --all`
- Add a new commit instead of amend:
    - `gt modify --commit --all --message "<message>"`
- Submit current branch and downstack:
    - `gt submit`
- Submit entire stack:
    - `gt submit --stack`
- Sync latest trunk and restack automatically where possible:
    - `gt sync`
- Explicit restack:
    - `gt restack`
- Resolve paused restack/rebase:
    - `gt continue`
- Abort paused restack/rebase:
    - `gt abort`
- Reorder stack:
    - `gt reorder`
- Move branch onto new parent:
    - `gt move --onto <branch>`
- Insert a new branch between current branch and child:
    - `gt create --insert`
- Navigate stack:
    - `gt up`
    - `gt down`
    - `gt top`
    - `gt bottom`
    - `gt checkout <branch>`
- Inspect stack:
    - `gt log`
    - `gt log short`

## Workflow templates

### Create and publish a new 2-PR stack

1. Implement first change slice.
2. `gt create --all --message "feat: base slice"`
3. Implement second change slice.
4. `gt create --all --message "feat: follow-up slice"`
5. `gt submit --stack --no-interactive`

### Address feedback on the lower PR in a stack

1. `gt checkout <lower-branch>`
2. Apply fixes.
3. `gt modify --all`
4. `gt submit --stack --no-interactive`

### Rebase stack after trunk moves

1. `gt sync`
2. If conflicts remain:

- `gt restack`
- Resolve conflicts and run `gt continue`

3. `gt submit --stack --no-interactive`

## Practical guardrails

- Keep each PR focused on one logical unit of change.
- Prefer stack length that stays reviewable (small diffs, clear PR intent).
- Re-run `gt sync` before submitting if trunk may have moved.
- Avoid mixing unrelated refactors into the same stack.
