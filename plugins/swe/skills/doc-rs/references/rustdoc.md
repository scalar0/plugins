# Rustdoc integration

Read this reference for README integration, documentation attributes, item links, and examples included from Markdown.

## Crate overview and README inclusion

Use the crate's actual target root and preserve its current documentation assembly.
A standard library layout can include its README with:

```rust
#![doc = include_str!("../README.md")]
```

Resolve that path from the containing Rust source file.
Derive the path for custom layouts instead of copying the example unchanged.
Keep one useful introduction, rationale, and example when merging existing crate docs.

A README can have several consumers: Cargo packaging, a repository viewer, a generator, rustdoc, and another build system.
Inspect the manifest's README declaration and generation inputs before changing the file.
If new documentation includes another file, keep that file available to each compiler or documentation action that needs it.
A Markdown hyperlink alone does not create a compiler input.

The [doc attribute reference](https://doc.rust-lang.org/rustdoc/write-documentation/the-doc-attribute.html) explains included documentation and re-export presentation.

## Item links and re-exports

Prefer rustdoc item links for API references, such as `crate::module::Type` or `Self::method`.
Check the scope where documentation is defined, including facade re-exports and macro-generated items.
Links in re-export documentation can resolve in a different scope from links on the original definition.
Use a namespace disambiguator when a type, function, or macro shares a name.

Keep repository paths for supporting source and design pages when those paths serve the intended reader.
An ordinary Markdown file path is not an item link.
Rustdoc can leave such paths unchecked, so a clean documentation build is insufficient link validation.

The [item-link guide](https://doc.rust-lang.org/rustdoc/write-documentation/linking-to-items-by-name.html) defines scope and disambiguation rules.

## Runnable examples

Preserve hidden setup lines and meaningful assertions when moving a doctest.
Choose imports from the public API that the example teaches.
Keep example feature requirements consistent with supported configurations.
Use `no_run`, `compile_fail`, or ignored examples only when their meaning fits the example and repository policy.
Do not hide a regression by marking a previously runnable example ignored.

Rustdoc assumes Rust for code fences without a language tag.
Label non-Rust examples explicitly when documentation can enter rustdoc.

For Markdown included through `include_str!`, nested `include!`, `include_str!`, and `include_bytes!` paths depend on the package edition.
Rust 2024 and later resolve those doctest paths from the Markdown file.
Earlier editions resolve them from the including Rust source file.
Check these paths after moving examples or changing inclusion.

The [doctest guide](https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html) explains runnable blocks and hidden lines.
The [edition guide](https://doc.rust-lang.org/edition-guide/rust-2024/rustdoc-nested-includes.html) explains nested include paths.

## Conditional documentation and lint policy

Check `cfg`, feature gates, documentation attributes, and re-exports before describing an item as universally available.
Keep prose-only edits separate from changes to these attributes.
Use supported feature combinations to validate the documented variants.

Preserve existing `missing_docs` and rustdoc lint settings.
Address warnings at their documented owner instead of weakening the policy.
The [rustdoc lint reference](https://doc.rust-lang.org/rustdoc/lints.html) defines documentation-specific checks.
