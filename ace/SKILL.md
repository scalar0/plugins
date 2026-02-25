---
name: ace
description: Author and revise requirements, specifications, and architecture text in Attempto Controlled English (ACE 6.7). Use when the user needs ACE-compliant prose, reformulation help, rule enforcement, or ACE validation.
---

# ACE Authoring

## Overview

Produce clear, unambiguous ACE 6.7 statements that are parsable and semantically faithful to the source intent.

## Workflow

1. Clarify scope, audience, and required level of formality.
2. Rewrite source prose into short ACE sentences, one idea per sentence.
3. Apply ACE construction and interpretation rules before validating.
4. Validate and compare paraphrases to the intended meaning.
5. Iterate until syntax is valid and meaning is preserved.

## ACE Rules (High Priority)

- Use simple present tense.
- Use a determiner for every noun.
- End declaratives with `.`, questions with `?`, and imperatives with `!`.
- Prefer explicit agents, explicit references, and relative clauses over implicit wording.
- Avoid ambiguous coordination; split into separate sentences when needed.
- Use explicit variables or reflexive forms when cross-reference could be unclear.

## Resources

- Full guidance: `references/ace-guidelines.md`
- Construction rules: `references/ace-construction-rules.md`
- Interpretation rules: `references/ace-interpretation-rules.md`
- Troubleshooting: `references/ace-troubleshooting.md`

## Scripts

- Run `uv run scripts/ape.py [ARGS]` to invoke APE through Docker.
- Build/update the Docker image with `scripts/Dockerfile` and `scripts/docker-bake.hcl`.
- Optional runtime configuration is exposed via:
    - `APE_DOCKER_IMAGE`
    - `APE_DOCKER_ARGS`
    - `APE_DOCKER_WORKDIR`
    - `APE_DOCKER_MOUNT`
    - `APE_DOCKER_USER`
