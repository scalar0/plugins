---
name: bazel
description: Set up, edit, query, or troubleshoot Bazel builds and BUILD files.
---

# Bazel

Read only the task-specific reference: [bootstrap](references/bootstrap.md) for setup, [style](references/style-guide.md) for BUILD review, or [tooling](references/tooling.md) for Bazelisk, buildifier, and buildozer.
Use current official documentation before version-sensitive ruleset or dependency setup, and report missing tools instead of adding unrequested installation steps.

## Default Workflow

1. Inspect the target packages and the Bazel configuration that affects the requested operation.
2. Prefer Bazelisk as `bazel`; pin the version in `.bazelversion`.
3. Prefer Bzlmod via `MODULE.bazel` for new projects; use `WORKSPACE` only when required.
4. Add one `BUILD.bazel` per meaningful package; model libraries, binaries, and tests explicitly.
5. Format/lint with buildifier; use buildozer for bulk mechanical edits.
6. Validate the affected targets with the relevant query, build, or test.

Expand validation when a failure, shared configuration change, or repository requirement calls for it.

Use readable explicit BUILD rules, literal labels and names, narrow visibility, direct dependencies, and buildifier-authoritative formatting.

| Task                   | Example                                |
| ---------------------- | -------------------------------------- |
| Check the version      | `bazel version`                        |
| Update module metadata | `bazel mod tidy`                       |
| Format a changed file  | `buildifier path/to/BUILD.bazel`       |
| Query a package        | `bazel query //path/to/package:all`    |
| Build a target         | `bazel build //path/to/package:target` |
| Test a target          | `bazel test //path/to/package:test`    |

Use `//...` or `buildifier -r .` only for a workspace-wide task or required validation.

## Safety

- Reuse existing authorization for local builds and tests.
- Ask before an unapproved large network fetch or destructive cleanup such as `bazel clean --expunge`.
- Run buildifier after buildozer.
- Summarize changed Bazel files and validation results.
