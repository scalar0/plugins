---
name: do-plan
description: Generate structured implementation plans from a feature request, prompt, or issue with phases, tasks, risks, and quality gates. Use when asked to create or refine a plan document from requirements text, GitHub issues, or Linear issues.
---

# Do Plan

## Overview

Generate a detailed, actionable implementation plan that breaks high-level goals into concrete implementation tasks.

## Inputs

1. Read user-provided context from `$ARGUMENTS`.
2. When asked to plan from an issue, fetch issue context by triggering either:
    - [linear skill](../linear/SKILL.md) for Linear issues (default).
    - [gh-cli skill](../gh-cli/SKILL.md) for GitHub issues when the user explicitly requests GitHub.
3. Use [template file](assets/PLAN-TEMPLATE.md) for the markdown output structure.
4. Use [schema](assets/schema.json) and [example](assets/example.json) when generating or checking JSON plan representations.

## Workflow

1. Analyze inputs to extract scope, constraints, assumptions, and objectives.
2. Break features into phases with clear deliverables and dependencies.
3. Break phases into tasks with explicit IDs, dependencies, sequential steps, and quality gates.
4. Identify technical risks, set impact and likelihood, and provide mitigation strategies.
5. Identify parallelization opportunities without breaking dependency ordering.
6. Define measurable success criteria and testing requirements.
7. Produce the final artifact in the requested format.

## Constraints

### Clarity

- All tasks have actionable steps
- Technical decisions are justified
- Code examples are complete and correct
- Dependencies are unambiguous
- Success criteria are measurable

### Feasibility

- Phases are appropriately sized
- Dependencies allow parallel work
- Dependencies allow asynchronous work
- Testing strategy is realistic
- Integration points are identified
- Technical risks are addressable

### Consistency

- Uses consistent terminology throughout
- Follows existing project patterns
- Matches Rust ecosystem best practices
- Maintains quality gate requirements

### Traceability

- Tasks map back to feature objectives
- Success criteria align with goals
- Dependencies are logical and complete
- Testing covers all functionality
- Integration strategy is coherent

## Deliverable

- Unless specified otherwise, output artifact: `.github/features/PLAN-{feature}.md`.
- If the user requests JSON output, ensure it conforms to `assets/schema.json`.
- Ensure tasks map back to objectives and have measurable success criteria.
