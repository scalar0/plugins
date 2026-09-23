---
name: doc-crate
description: Create or update a Rust crate README and its rustdoc integration.
---

# Doc Crate

Document one library crate at a time, using an explicit crate name or the only unambiguous library crate.
Resolve every edit relative to that crate's `Cargo.toml`.

## Workflow

1. Locate the package from workspace manifests or `cargo metadata` and confirm `src/lib.rs` exists.
2. Read the manifest, crate root, and source sections needed to verify the requested documentation.
3. Write or revise the adjacent `README.md` using the placement rules below.
4. For README integration, use [rustdoc.md](references/rustdoc.md) to add `#![doc = include_str!("../README.md")]` to `src/lib.rs`.
5. Preserve inner attributes and lint settings, merging existing crate docs instead of duplicating front-page content.
6. Add source documentation when the requested crate documentation needs it.

| Location            | Content                                                                                                                                  |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `README.md`         | Stable purpose, responsibilities, integration points, public entry points, feature flags or limitations, and one useful minimal example. |
| Public doc comments | Concise first-line summary, API intent, externally relevant behavior, errors, panics, safety, threading, and ownership constraints.      |
| Regular comments    | Non-obvious implementation invariants, tradeoffs, and design details beside the code that enforces them.                                 |

Keep the README useful on GitHub and in rustdoc without turning it into generated API reference or embedding low-level algorithms.
Do not restate signatures, obvious control flow, or trivial fields.

## Validate

- Run `cargo doc --no-deps -p <crate-name>` when rustdoc content or README integration changes.
- Run `cargo test --doc -p <crate-name>` when examples or doctests changed.
- Follow existing doc lint policy unless the user explicitly requests a change.
