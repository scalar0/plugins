# Bazel Style Checklist

Source: [Bazel BUILD style guide](https://bazel.build/build/style-guide).

## Prime Directive

Prefer DAMP over DRY: BUILD files are configuration for humans and tools. Keep targets, labels, and deps explicit.

## Structure + Format

- Format with buildifier; treat its output as canonical.
- Order: package comment, `load()`, `package()`, rules/macros.
- One blank line between top-level definitions.
- Blank line after standalone section comments; attach element comments directly above the element.
- Prefer double-quoted strings; no strict line-length limit for labels.

## Labels

- Source files: relative path, no `:`: `srcs = ["x.cc"]`.
- Same-package rules/generated files: `:target`.
- No `..` up-references.
- Eponymous target: prefer `//x` over `//x:x`; inside package, prefer `:x`.
- Prefer literal, unsplit labels; avoid concatenation or formatting in label-valued attrs.

## Names

- Use descriptive names; default to `snake_case` unless language convention differs.
- Java binaries/tests may use `UpperCamelCase` when matching classes.
- Tests end with `_test`, `_unittest`, `Test`, or `Tests`.
- Proto naming: `*_proto`, `*_cc_proto`, `*_java_proto`, `*_java_proto_lite`.
- Avoid reserved names: `all`, `__pkg__`, `__subpackages__`.
- Avoid meaningless suffixes like `_lib` unless needed to avoid conflicts.

## Visibility

- Scope visibility as tightly as possible.
- Avoid package-wide `//visibility:public` defaults.
- Mark only public API targets public.
- Use `__pkg__` and `__subpackages__` intentionally.

## Dependencies

- List direct deps only.
- Put package-local deps first and use local labels.
- Prefer one explicit deps list per target.
- Avoid `COMMON_DEPS`-style variables.
- Avoid broad `exports` aggregators used only to hide deps.
- Let tools such as Gazelle help, but review generated files.

## Globs

- Use `[]` for none; do not use empty-matching globs.
- Non-recursive globs may be OK.
- Avoid recursive source globs such as `glob(["**/*.java"])`.
- Prefer BUILD files per meaningful directory for clearer caching/parallelism.

## BUILD/Starlark Patterns

- Avoid top-level list comprehensions generating rules.
- Prefer explicit rule/macro calls with literal `name` values.
- Limit symbols exported by each public `.bzl` file.
- Constants: `UPPERCASE_WITH_UNDERSCORES`; variables: `lowercase_with_underscores`.
- Boolean attrs: `True`/`False`, not `1`/`0`.

## Minimal Example

```bzl
# Library and tests for the foo package.

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")

package(default_visibility = ["//visibility:private"])

cc_library(
    name = "foo",
    srcs = ["foo.cc"],
    hdrs = ["foo.h"],
    deps = [
        ":config",
        "//base/logging",
    ],
)
```
