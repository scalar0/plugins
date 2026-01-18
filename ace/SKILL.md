---
name: ace
description: Author and revise requirements, specifications, and architecture descriptions in Attempto Controlled English (ACE 6.7). Triggers when the user needs ACE-compliant text, help reformulating prose into ACE, enforcing ACE construction/interpretation rules, or validating ACE outputs.
compatibility: Requires docker
---

# ACE Authoring

## Purpose

Produce clear, unambiguous ACE 6.7 requirements/specifications that are parsable and formally verifiable.

## Workflow

1. Clarify intent and target audience for the requirements/specification.
2. Convert prose into short ACE sentences; keep one idea per sentence.
3. Apply ACE construction rules and interpretation rules.
4. Prefer explicit agents, determiners, and relative clauses to avoid ambiguity.
5. If provided, run the validator and compare the paraphrase to intent.
6. Iterate until ACE is valid and the paraphrase matches intent.

## Writing Guidance (ACE 6.7)

- Use simple present tense only.
- Every noun requires a determiner.
- End declaratives with `.`, interrogatives with `?`, imperatives with `!`.
- Avoid commas except before coordinators or in lists.
- Prefer multiple short sentences over complex coordination.
- Use relative clauses to modify nouns; prepositional phrases modify verbs by default.
- Hyphenate compound content words (e.g., `check-code`).
- Use explicit variables for cross-references when needed.

## Common Reformulations

- Use universal determiners for generic statements: `Every cat is an animal.`
- Avoid noun phrase disjunction; repeat the verb: `John enters a card or enters a code.`
- For noun modifiers, use relative clauses: `A card that is in a slot is invalid.`
- For reflexives, use explicit reflexive forms: `John sees his own wife.`

## Resources

- Full guidelines: `references/ace-guidelines.md`
- Construction rules: `references/ace-construction-rules.md`
- Interpretation rules: `references/ace-interpretation-rules.md`
- Troubleshooting: `references/ace-troubleshooting.md`

## Scripts and Assets

- Use `uv run ape.py [ARGS]` to run the APE CLI via Docker. It mirrors the container entrypoint and forwards all arguments. Configure with:
    - `APE_DOCKER_IMAGE` (default `grace:latest`)
    - `APE_DOCKER_ARGS` (extra `docker run` flags)
    - `APE_DOCKER_WORKDIR` (default `/work`)
    - `APE_DOCKER_MOUNT` (`0`/`false` disables mounting $PWD)
    - `APE_DOCKER_USER` (override `--user`)
- Use `scripts/Dockerfile` with `scripts/docker-bake.hcl` to build the APE image.
