# Determinism Classification

Classify a step by whether it needs semantic judgment, not by whether it currently appears as prose or code.

## Decision Table

| Extract into an executable                                | Keep with the agent                                      |
| --------------------------------------------------------- | -------------------------------------------------------- |
| Parse a known format or schema                            | Infer intent from ambiguous input                        |
| Validate explicit invariants                              | Decide which invariants fit the user's goal              |
| Apply a specified transformation                          | Choose among materially different transformations        |
| Run a fixed command sequence                              | Select tools from contextual trade-offs                  |
| Generate boilerplate from explicit parameters             | Design novel content or architecture                     |
| Sort, filter, normalize, hash, copy, or package artifacts | Interpret quality, relevance, tone, or risk              |
| Check links, file modes, naming, or repository state      | Resolve unexpected failures without an enumerated policy |
| Render a stable report from structured data               | Explain implications or recommend action                 |

## Boundary Test

Consider extraction when all of these statements are true.

1. Define every required input without asking the model to interpret free-form meaning.
2. Specify observable outputs, side effects, and exit conditions.
3. Produce the same behavior from the same explicit inputs and controlled dependencies.
4. Encode failure handling as finite checks or documented exit statuses.
5. Test the operation independently of the agent.

Keep the step with the agent when any statement is false.
Script deterministic preparation or validation around that decision when useful.

Extract a qualifying step when repeated use, failure risk, or reliability benefits justify the executable's maintenance cost.
Keep a simple command in prose when a wrapper adds no useful behavior.

External tools and APIs may remain inside an executable when invocation mechanics are fixed, inputs and side effects are explicit, and unpredictable responses are returned to the agent instead of silently interpreted.

## Extraction Shape

Extract complete mechanical chains instead of wrapping isolated commands that still require the agent to reproduce ordering, temporary-file handling, or validation.

Keep executable interfaces narrow enough that arguments represent decisions already made by the agent.

Return structured facts and diagnostics from scripts, then let the agent interpret those facts.

Replace the extracted prose with the executable invocation, required inputs, promised outputs, and the condition that returns control to the agent.

## Contract Preservation

Treat the original trigger description, objectives, scope, deliverables, output forms, acceptance criteria, and side-effect limits as immutable.

Use exact baseline protection for explicit contract sections and unique line ranges for contract text embedded in mixed sections.

Reject an extraction that changes what users ask for, what artifacts they receive, or how success is evaluated.

## Anti-Patterns

- Do not move a free-form prompt into a script that calls another model.
- Do not accept arbitrary shell strings merely to label a wrapper deterministic.
- Do not duplicate the same workflow in prose and code.
- Do not hide policy choices behind defaults that the original agent made contextually.
- Do not build one monolithic executable that owns unrelated decisions.
- Do not convert explanations, domain knowledge, or quality judgment into brittle keyword rules.
