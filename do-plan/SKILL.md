---
name: do-plan
description: Generate detailed implementation plans from a feature request prompt that specifies phases, tasks, risks, quality gates. Use when asked to create or refine a PLAN-{issue_id}.md file, interpret a plan-feature prompt, or turn a GitHub issue and plan template into a structured implementation plan.
requires: gh CLI installed and authenticated.
---

# SKILL: Plan Implementation

## Overview

Analyze the provided <input> materials and generate a detailed, actionable implementation plan that breaks down high-level goals into concrete implementation tasks.

## Input Materials <input>

1. Issue body: Detailed feature request fetched using this [script](scripts/get_issue.sh) by running the command: `scripts/get_issue.sh <issue_id>`
2. [Template file](assets/PLAN-TEMPLATE.md): Defines the structure and required sections of the implementation plan.
3. User context: `$ARGUMENTS` that will contain <issue_id> and additional context.

## Workflow

1. Analyze <input> to understand the vision and objectives
2. Break down features into phases with clear dependencies
3. Break down phases into tasks with sequential steps and quality gates
4. Think about parallelization opportunities and resource allocation
5. Identify technical risks and provide mitigation strategies
6. Ensure alignment with best practices and patterns
7. Provide clear success criteria and testing requirements

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

- Aligns with AGENTS.md conventions
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

## Required content rules

- Follow [Template file](assets/PLAN-TEMPLATE.md) without altering elements not enclosed in placeholders `{}`.
- Prefer bullets or numbered lists over paragraphs outside of tables.
- Use markdown code blocks with language hints for commands and code snippets.
- ASCII only; no emojis.

## Deliverable

- Primary output artifact: `.github/features/PLAN-{issue_id}.md`.
- Ensure tasks map back to objectives and have measurable success criteria.
