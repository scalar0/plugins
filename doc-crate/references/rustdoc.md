# Rustdoc Guidance

Use this reference when writing crate-level docs, deciding what belongs in `README.md`, or validating how README content is rendered by rustdoc.

## Crate Front Page

- Rustdoc's front page for a library crate starts from crate-level documentation in `src/lib.rs`.
- The rustdoc book recommends starting crate docs with an introduction, why the crate exists, and a real-world example.
- The first line before the first blank line should be a concise summary because rustdoc reuses it in search and overview surfaces.

Official docs:

- https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html

## Including README.md

- The official `#[doc]` attribute supports including external Markdown with `include_str!`.
- For a standard library crate layout with `Cargo.toml` and `README.md` at the crate root and `src/lib.rs` below it, use:

```rust
#![doc = include_str!("../README.md")]
```

Official docs:

- https://doc.rust-lang.org/nightly/rustdoc/write-documentation/the-doc-attribute.html
- https://doc.rust-lang.org/std/macro.include_str.html

## Documentation Coverage

- `rustdoc::missing_crate_level_docs` warns when the crate root lacks documentation.
- `missing_docs` can help push broader API coverage, but whether to warn or deny should follow repository conventions.

Official docs:

- https://doc.rust-lang.org/rustdoc/lints.html
- https://doc.rust-lang.org/stable/rustdoc/write-documentation/what-to-include.html

## README Doctest Path Semantics

- If `README.md` contains doctests that use `include!`, `include_str!`, or `include_bytes!`, path resolution changed in Rust 2024.
- In Rust 2024 and later, nested include paths inside the README resolve relative to the README file itself.
- In earlier editions, those nested paths resolve relative to the Rust source file that includes the README.

Official docs:

- https://doc.rust-lang.org/edition-guide/rust-2024/rustdoc-nested-includes.html
