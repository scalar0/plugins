---
name: doc-crate
description: Document a Rust library crate by writing or revising its crate-root README, including that README in `src/lib.rs` for rustdoc, and adding focused source documentation comments. Use when a user asks to document a library crate, explain a crate's purpose within a Rust project, add `README.md` beside a crate's `Cargo.toml`, wire crate-level docs through `#![doc = include_str!(...)]`, or improve Rust API documentation without moving low-level implementation details into the README.
---

# Doc Crate

## Overview

Document one Rust library crate at a time. Keep the crate README high-level and project-oriented, keep detailed behavior close to the code, and make rustdoc render the README as the crate front page.

## Inputs

- Prefer an explicit crate name in the user request or suggested argument.
- If the crate name is omitted, infer it only when one library crate is clearly unambiguous.
- Resolve edits relative to the crate's own `Cargo.toml`, not the workspace root.

## Workflow

1. Locate the target crate.
    - Find the package by crate name from workspace manifests or `cargo metadata`.
    - Confirm it is a library crate with `src/lib.rs`.
    - Edit files next to that manifest: `README.md`, `src/lib.rs`, and relevant source modules.
2. Understand the crate's role in the project.
    - Read `Cargo.toml`, `src/lib.rs`, public modules, tests, and nearby call sites.
    - Describe what the crate does for the project, not just what symbols it exports.
3. Write or revise `README.md` beside `Cargo.toml`.
    - Keep it high-level and stable.
    - Focus on purpose, responsibilities, main integration points, public entry points, and a minimal example when useful.
    - Avoid low-level algorithms, invariants, unsafe details, or line-by-line behavior there; keep those in code comments.
4. Include the README in crate-level rustdoc.
    - Add `#![doc = include_str!("../README.md")]` near the top of `src/lib.rs`.
    - Preserve existing inner attributes and lint settings.
    - If crate-level docs already exist, merge intentionally instead of duplicating front-page content.
5. Add source documentation comments.
    - Prioritize public modules, structs, enums, traits, functions, type aliases, errors, and feature-gated APIs.
    - Use doc comments for API intent and externally relevant behavior.
    - Use regular comments only for non-obvious implementation constraints, invariants, safety notes, or tradeoffs.
    - Keep the first line of each public doc comment as a concise summary before the first blank line.
6. Validate.
    - Run `cargo doc --no-deps -p <crate-name>` after wiring the README.
    - Run `cargo test --doc -p <crate-name>` when README examples or doctests changed.
    - Respect the repository's current lint policy. Do not add or tighten doc lints unless it matches local conventions or the user asks.

## README Shape

- Suggested sections: `Overview`, `Responsibilities`, `Integration`, `Feature flags` or `Limitations` when relevant.
- Keep the README readable on GitHub and in rustdoc.
- Do not turn the README into generated API reference material.

## Source Comment Rules

- Explain why, not what.
- Do not restate signatures, obvious control flow, or trivial field names.
- Document panics, errors, safety preconditions, threading assumptions, and ownership constraints when relevant.
- Keep internal design details close to the code that enforces them.

## Rustdoc Notes

- Read [references/rustdoc.md](references/rustdoc.md) before changing crate-level doc wiring or doctest-heavy README content.
- Prefer official rustdoc guidance over ad hoc style rules when there is a conflict.
