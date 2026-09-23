---
name: ace
description: Author formal Constrained Natural Language in Attempto Controlled English (ACE 6.7). Use when the user needs ACE-compliant prose, reformulation help, rule enforcement, or ACE validation.
---

# ACE Authoring

## Workflow

1. Clarify scope, audience, and required level of formality.
2. Rewrite source prose into short ACE sentences, one idea per sentence.
3. Apply [construction rules](references/ace-construction-rules.md) and consult [interpretation rules](references/ace-interpretation-rules.md) when scope or reference resolution matters.
4. Validate and compare paraphrases to the intended meaning.
5. Diagnose rejected or misinterpreted text with [troubleshooting guidance](references/ace-troubleshooting.md) and iterate until syntax and meaning pass.

Read the [ACE guidelines](references/ace-guidelines.md) when broader authoring guidance is needed.

## Core Rules

- Use simple present tense and a determiner for every noun.
- End declarations with `.`, questions with `?`, and imperatives with `!`.
- Make agents and references explicit, using variables, reflexives, or relative clauses when needed.
- Split ambiguous coordination into separate sentences.

## Validate with APE

Run [ape.py](scripts/ape.py) as `uv run scripts/ape.py [ARGS]` to invoke APE through Docker, whose image is defined by [Dockerfile](scripts/Dockerfile) and [docker-bake.hcl](scripts/docker-bake.hcl).
Use `APE_DOCKER_IMAGE`, `APE_DOCKER_ARGS`, `APE_DOCKER_WORKDIR`, `APE_DOCKER_MOUNT`, or `APE_DOCKER_USER` only when the default container runtime needs an override.
