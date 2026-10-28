---
name: doc-rs
description: Create, review, and reorganize Rust crate and workspace documentation, including READMEs, architecture, source documentation, and rustdoc integration.
---

# Rust Documentation

Keep focused requests at the requested crate or API boundary.
For workspace reviews, establish the included products, crates, tooling, and generated documentation before editing.

## Ownership and scope

For scope reviews or content relocation, first read [doc-scope](../doc-scope/SKILL.md).
Use its process for authority, exhaustive coverage, relocation, navigation, and reporting.
Apply the Rust-specific placement and validation rules below.

| Rust documentation                              | Content                                                                                                         |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Workspace or product architecture               | Application boundaries, shared contracts, and interactions between immediate subsystems                         |
| Crate architecture, when the repository uses it | Parent context, module responsibilities, crate-wide invariants, ownership seams, failures, and extension points |
| Crate README                                    | Stable purpose, rationale, integration points, public usage, feature limits, and a useful example               |
| Crate or module documentation with `//!`        | Crate overview or module design, responsibilities, and internal interfaces                                      |
| Item documentation with `///`                   | API intent, required caller conditions, errors, panics, safety, threading, and ownership constraints            |
| Ordinary source comments                        | Non-obvious local invariants, algorithm choices, and implementation rationale                                   |
| Nearby design pages                             | Longer module explanations and diagrams that need a separate presentation                                       |

A crate does not automatically define a C4 component or runtime container.
Public visibility alone does not establish a system boundary.
Keep parent assumptions brief and link to their authoritative owner.

## Discover the Rust owners

Use workspace manifests and Cargo metadata to identify package membership and actual target roots.
Handle custom library paths, binary-only crates, procedural macros, and build scripts according to their actual roles.
Resolve each change from the owning package manifest rather than assuming `src/lib.rs` exists.

Read the relevant declarations, callers, re-exports, and tests before describing a contract.
Distinguish the public facade from the module that implements a rule.
Check package edition, features, conditional compilation, and supported target configurations where they affect the documented API.
Use the repository's existing feature matrix instead of assuming all features can run together.

Identify README generators, included Markdown, generated Rust, schemas, and build inputs.
Keep generated files under their existing source authority.
Repository-specific Cargo or Bazel metadata remains repository policy.

## Author or revise the documentation

Write a concise summary before the first blank line.
Explain the crate's purpose and integration boundary before its public example.
Document an API's observable contract without repeating its signature or obvious control flow.
Describe errors, panics, unsafe caller obligations, and ownership or threading requirements where they apply.
Use module documentation or local comments for private mechanics.

For README integration, links, included examples, or documentation attributes, read [Rustdoc integration](references/rustdoc.md).
Preserve existing crate documentation, inner attributes, lint settings, and documentation inclusion conventions.
Add README inclusion when the request or repository convention requires it.
Keep README content useful both in the repository and in rustdoc when it serves both readers.

For code views, also read [diagram scope](../doc-scope/references/diagrams.md).
Show real structs, enums, traits, functions, and relevant relationships.
Distinguish owned values, borrowed references, shared handles, trait implementation, and supertrait requirements.
An `Arc<T>` handle does not imply exclusive ownership of `T`.
Keep private helper state beside its module unless it explains a crate-wide contract.

Place future design in an explicitly labeled design owner.
Existing source documentation describes implemented behavior unless it clearly identifies a future design.
Keep runtime changes outside a documentation-only task.
Treat doctest bodies, `cfg` attributes, macro directives, and generated-code annotations as executable or build-sensitive content.

## Validate the affected documentation

Use repository wrappers when they provide the required checks.
Otherwise, select package and feature flags from the supported configuration.

| Change                                                  | Validation                                                                                   |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Crate or source documentation, inclusion, or item links | `cargo doc --no-deps -p <package>` with relevant feature flags                               |
| New, moved, or changed runnable examples                | `cargo test --doc -p <package>` for library targets that support doctests                    |
| Workspace-wide review                                   | Documentation checks for every affected package, following the repository's supported matrix |
| Generated README inputs or metadata                     | Existing generation freshness checks                                                         |
| Included files under another build system               | Its declared compiler inputs and relevant documentation or build check                       |
| Diagrams and supporting pages                           | Syntax, source references, local paths, anchors, and scope checks                            |

A documentation build does not execute doctests or validate every ordinary Markdown URL.
Check repository links separately and inspect warnings from item-link resolution.
Inspect both rendering contexts when README relocation affects repository and rustdoc links.
For targets without doctests, use the applicable documentation and example checks and report that limit.
Follow existing documentation lint policy rather than changing lint levels to make checks pass.
Verify that source edits preserve runtime syntax and unrelated attributes.
