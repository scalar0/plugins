---
name: do-plan
description: Generate structured implementation plans with phases, tasks, dependencies, risks, and quality gates. Use when asked to plan work from prompts, requirements, GitHub issues, or Linear issues.
---

# Do Plan

## Overview

Produce an actionable implementation plan that maps objectives to executable tasks with clear sequencing and validation.

## Inputs

- Use user-provided requirements as the primary source.
- If planning from Linear, use `../linear/SKILL.md` workflow.
- If planning from GitHub, use `../gh-cli/SKILL.md` workflow.
- Follow the [Markdown template](assets/PLAN-TEMPLATE.md) when asked for Markdown output.
- Follow the [JSON schema](assets/schema.json) for JSON plan output.

## Workflow

1. Extract goals, constraints, assumptions, and non-goals.
2. Break the initiative into phases with explicit deliverables.
3. Define tasks with IDs, dependencies, and acceptance checks.
4. Identify parallelizable work while preserving dependency order.
5. Record risks with likelihood, impact, and mitigation.
6. Define measurable success criteria and test strategy.
7. Emit the final plan in the requested format.

## Quality Gates

- Every task is actionable and testable.
- Dependencies are explicit and internally consistent.
- Risks and mitigations are concrete.
- Success criteria are measurable.
- Plan terminology is consistent end-to-end.

## Deliverable

- Default artifact path: `.github/features/PLAN-{feature}.md`.
- If JSON is requested, ensure strict conformance to `assets/schema.json`.
