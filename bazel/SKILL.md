---
name: bazel
description: Use Bazel, Bazelisk, buildifier, and buildozer to bootstrap and maintain Bazel build systems. Use when setting up MODULE.bazel/BUILD.bazel files, choosing Bazel workflows, formatting or mechanically editing BUILD files, querying targets, or applying official Bazel style-guide recommendations.
---

# Bazel

Use this skill for Bazel setup, maintenance, review, migration, and tool workflows.

## Token Discipline

- Load only the reference needed for the task: [bootstrap](references/bootstrap.md), [style](references/style-guide.md), or [tooling](references/tooling.md).
- Prefer checklist answers and exact commands over long explanations.
- In prose, reference files and web pages with Markdown links, never bare paths or bare URLs.
- Fetch current official ruleset docs before giving version-sensitive setup details.
- Do not provide tool installation instructions; if a required tool is missing, report it and ask the user how to proceed.

## Sources

- [Bazel BUILD style guide](https://bazel.build/build/style-guide)
- [Bazelisk README](https://github.com/bazelbuild/bazelisk/blob/master/README.md)
- [Bazel external dependencies / Bzlmod](https://bazel.build/external/overview)
- [buildifier README](https://github.com/bazelbuild/buildtools/blob/main/buildifier/README.md)
- [buildozer README](https://github.com/bazelbuild/buildtools/blob/main/buildozer/README.md)

## Default Workflow

1. Inspect existing Bazel state: `MODULE.bazel`, `WORKSPACE*`, `BUILD*`, `.bzl`, `.bazelversion`, `.bazelrc`, `.bazelignore`, and `tools/bazel*`.
2. Prefer Bazelisk as `bazel`; pin the version in `.bazelversion`.
3. Prefer Bzlmod via `MODULE.bazel` for new projects; use `WORKSPACE` only when required.
4. Add one `BUILD.bazel` per meaningful package; model libraries, binaries, and tests explicitly.
5. Format/lint with buildifier; use buildozer for bulk mechanical edits.
6. Validate with targeted queries/builds/tests first, then broaden.

## Core Recommendations

- DAMP over DRY: readable, explicit BUILD files beat clever deduplication.
- File order: package comment, `load()`, `package()`, rules/macros.
- Use buildifier formatting as authoritative.
- Use literal labels and literal `name` strings.
- Use local labels for same-package rules/generated files; source files have no leading `:`.
- Keep visibility tight; make only public API targets public.
- List direct deps per target; avoid common deps variables and broad `exports` aggregators.
- Avoid recursive source globs and top-level list comprehensions.
- Use `True`/`False`, double quotes, and descriptive target names.

## Setup Checklist

For new Bazel setup, follow [bootstrap](references/bootstrap.md). Minimal flow:

```bash
bazel version
bazel mod tidy
buildifier -r .
bazel query //...
bazel build //...
bazel test //...
```

## Tool Shortcuts

See [tooling](references/tooling.md) for details.

```bash
buildifier -r .
buildifier --lint=warn -r .
buildifier --lint=fix -r .
buildozer 'add deps //base' //pkg:target
bazel query --output=build //pkg:target
```

## Safety

- Ask before large network fetches or destructive cleanup such as `bazel clean --expunge`.
- Run buildifier after buildozer.
- Summarize changed Bazel files and validation results.
