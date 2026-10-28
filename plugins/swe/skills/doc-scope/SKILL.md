---
name: doc-scope
description: Review and fix architecture documentation scope, ownership, and duplication across system guides, subsystem guides, and source documentation in any language.
---

# Documentation Scope

Give each explanation one authoritative owner at the smallest logical boundary that controls its meaning.
Preserve enough local context for an implementer to find responsibilities, contracts, constraints, extension points, and evidence without reading unrelated design.

## Establish the review boundary

Infer whether the user requests a review, a plan, or implementation.
Apply corrections only within the authorized mode and scope.
Resolve repository facts through inspection before asking questions.
Ask only about material choices that the request and repository cannot resolve.

Identify the maintained guides, supporting sources, tooling, and excluded areas.
Record existing changes and protected content before editing.
When version control provides staging, compare staged entries rather than index timestamps or raw index bytes.
Index metadata can change without changing staged content.

Map logical systems, applications, libraries, modules, and external contracts from source and configuration.
Folder depth and package names do not establish architecture levels.
Reuse the repository's document roles and filenames.
A scope review does not require new architecture files for every directory.

## Assign information to its owner

For a subject S, explain its parent context, its own purpose and constraints, and its immediate subsystems.
Put a child's internal design with that child.
Use the following roles as a placement model, adapted to the codebase.

| Information                                                                         | Owner                                                                       |
| ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Actors, system boundaries, external interfaces, and system-wide constraints         | System architecture                                                         |
| Responsibilities, interactions, and invariants between immediate subsystems         | Architecture at their shared boundary                                       |
| Module responsibilities, interface seams, and local extension points                | Subsystem architecture                                                      |
| Public usage and API behavior                                                       | Usage guides and native item documentation                                  |
| Module algorithms, private state, synchronization, and implementation rationale     | Native source comments or nearby module design pages                        |
| Structured fields, configuration, normative requirements, and workflow instructions | Their existing authoritative contracts, configuration, and workflow sources |

Retain a brief interface assumption in a parent guide when its interactions depend on that assumption.
Link to the owner for the complete rule.
Repeated summaries need an architectural purpose, not merely a nearby link.
Judge a detail by its architectural consequence rather than symbol visibility, length, or programming language.
An identifier shared across workers can express an architectural contract even when its type is private.

Separate target decisions from implemented behavior and evidence.
Use the repository's authority order to resolve conflicts.
Missing implementation does not invalidate a binding target decision.
Correct factual documentation errors only when existing authority resolves them.
Report unresolved conflicts without inventing requirements or changing runtime behavior.

## Review systematically

For an exhaustive request, inspect every included guide, section, table, and diagram.
Sampling can guide discovery but cannot establish complete coverage.
Include supporting sources and tooling units that have no architecture file.

Use temporary working notes to track current location, subject boundary, authority, correct owner, action, and disposition.
Choose among keep, move, summarize and link, merge, and correct.
Match the review record to the requested deliverable.
Use temporary notes when no durable artifact is needed.

Trace a claim through its callers to the declaration, producer, validator, or contract that actually owns it.
A neighboring file with a related name is not sufficient evidence.
Check both excessive detail and missing context at each level.

For diagram changes, read [Diagram scope](references/diagrams.md).

## Relocate without losing meaning

Create or improve the destination before shortening the original explanation.
Use native module documentation for module design and item documentation for public contracts.
Put a local implementation invariant beside the code that enforces it.
Use nearby Markdown or the repository's equivalent for longer explanations and diagrams that source documentation cannot present well.
Keep a short pointer in source when a supporting page owns the full explanation.
Avoid implementation restructuring merely to accommodate prose or a file-size limit.

Preserve normative meaning, examples, evidence, and current-support qualifications.
Put future design in an explicitly labeled design owner rather than comments that imply existing behavior.
Remove duplicate text only after its authoritative explanation remains available.
Keep that owner reachable from the original guide or its normal navigation.

For generated documents, edit authoritative inputs or use an appropriate authored destination.
Change generator behavior only when the requested scope includes it.
Respect protected upstream material and excluded historical sources.
Preserve provenance when historical documents are in scope.
Rebase relocated links and retain useful incoming anchors or concise relocation links.
Do not treat directives, doctests, build tags, or generation annotations as ordinary comments.

## Validate and report

Use existing repository checks for documentation, formatting, links, and affected languages.
Check diagram syntax and abstraction separately.
Build documentation when native source documentation changes.
Check runnable examples when they change.
Select further tests from the actual changes rather than automatically running every suite.

Verify that source edits preserve executable content.
Use language-aware comparison when comments, strings, docstrings, or directives make text comparison unreliable.
Check generated output ownership, local source references, incoming anchors, and preserved user changes.
Report parsing and rendering as distinct validation results.

Finish when every included unit has a disposition and every relocation has an authoritative destination.
Report coverage, important moves and corrections, unresolved conflicts, validation results, and any coverage or validation limits.
