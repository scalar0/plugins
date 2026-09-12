---
name: skill-opt
description: Shorten or reorganize skills, or revise their policies when the user requests a behavior change.
---

# Skill Opt

Optimize for useful decisions and actions per token, not minimum word count.

## Establish the Contract

1. Read the complete `SKILL.md`, relevant directly linked resources, repository instructions, and current diff.
2. Record baseline line, word, and byte counts with `wc -l -w -c`.
3. Identify the behavior to preserve and any policy changes authorized by the request.

## Select the Mode

| Request                | Contract                                                                  |
| ---------------------- | ------------------------------------------------------------------------- |
| Compress or reorganize | Preserve trigger boundaries, behavior, interfaces, and permission limits. |
| Revise policy or scope | Change only the requested behavior and preserve unrelated requirements.   |

Use the request and existing authorization to select the mode.
Preserve the current invocation policy unless the user requests a change.

## Assign Each Instruction One Home

| Action   | Content                                                                                                                                      |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Keep     | Non-obvious decisions, constraints, failure boundaries, exact interfaces, and validation requirements.                                       |
| Compress | Repeated outcomes, adjacent steps with the same purpose, long enumerations, and prose that a table or example expresses better.              |
| Move     | Rare variants and detailed domain knowledge to directly linked references, and repeatable deterministic mechanics to scripts.                |
| Delete   | Restated headings, generic model knowledge, motivational prose, process history, redundant summaries, and examples that add no new decision. |

Keep the default workflow and resource routing in `SKILL.md`; move only conditional detail that saves context, and never create resources merely to shrink it.

## Rewrite

1. Put capability and concrete trigger contexts in the frontmatter description, remove body invocation sections, and preserve the skill name unless requested.
2. Use imperative, outcome-oriented instructions in execution order.
3. Use tables for mappings, prose for judgment, one example for genuine ambiguity, and code blocks only for exact reusable syntax.
4. Merge steps only when their prerequisites and outcomes remain explicit.
5. Match specificity to risk by using strict commands or scripts for fragile mechanics and concise heuristics for contextual judgment.
6. Preserve interfaces and permission limits except where the user authorized a change.
7. Link references directly from `SKILL.md` and state when to read each one.

Prefer deletion over synonym swapping, and never trade correctness for a smaller count.

## Validate

1. Reconcile the rewrite against the contract inventory and restore any lost requirement.
2. Re-read `SKILL.md` with its linked resources to find contradictions, duplicated guidance, stale terms, TODOs, and broken local links.
3. Update stale fields in `agents/openai.yaml` in place while preserving unrelated metadata, dependencies, and invocation policy.
4. Run the skill validator, checks for changed resources, and `git diff --check`.
5. Review the diff for accidental scope changes, preserved user edits, and unexplained growth or weak reduction.
6. Treat size reduction as evidence rather than proof, and forward-test behavioral changes that structural checks cannot verify.
