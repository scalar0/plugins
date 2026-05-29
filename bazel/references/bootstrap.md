# Bazel Bootstrap

Sources: [Bazel intro](https://bazel.build/start/bazel-intro), [Bzlmod overview](https://bazel.build/external/overview), [BUILD style guide](https://bazel.build/build/style-guide).

## Inspect

```bash
find . -maxdepth 3 \( -name MODULE.bazel -o -name WORKSPACE -o -name WORKSPACE.bazel -o -name BUILD -o -name BUILD.bazel -o -name '*.bzl' -o -name .bazelversion -o -name .bazelrc -o -name .bazelignore \) -print
find . -maxdepth 3 -type f \( -name package.json -o -name pnpm-lock.yaml -o -name pyproject.toml -o -name uv.lock -o -name requirements.txt -o -name go.mod -o -name Cargo.toml -o -name pom.xml -o -name build.gradle -o -name CMakeLists.txt \) -print
```

Identify languages, source/test roots, generated code, package-manager lockfiles, toolchains, CI OSes, and existing Bazel conventions.

## Pin Bazel

- Prefer Bazelisk.
- Commit `.bazelversion` with a stable project-required release.
- Avoid `latest` for reproducible projects.

## Prefer Bzlmod

For new projects, create `MODULE.bazel`:

```bzl
module(
    name = "my_project",
    version = "0.1.0",
)
```

Then add direct ruleset deps:

```bzl
bazel_dep(name = "rules_cc", version = "...")
bazel_dep(name = "rules_python", version = "...")
```

Rules:

- Use [Bazel Central Registry](https://registry.bazel.build/) when available.
- Keep only direct Bazel module deps in `MODULE.bazel`.
- Use ruleset module extensions for language package managers.
- Run `bazel mod tidy` after dependency edits.
- Commit `MODULE.bazel.lock` when the project expects lockfiles.
- Use legacy `WORKSPACE` only for documented compatibility needs.

## Add Shared Config Sparingly

Common files: `.bazelrc`, `.bazelignore`, and optional `tools/bazel` wrapper.

Conservative `.bazelrc`:

```text
common --announce_rc
test --test_output=errors
```

Avoid hiding required behavior in user-local config.

## Create BUILD Files

- Prefer `BUILD.bazel` for new files unless the repo uses `BUILD`.
- Start at leaf packages.
- Add reusable libraries before binaries/tests.
- List direct deps explicitly.
- Use one BUILD file per meaningful package directory.
- Format after each batch.

Skeleton:

```bzl
# Targets for this package.

package(default_visibility = ["//visibility:private"])
```

## Validate

```bash
bazel version
bazel mod tidy
buildifier -r .
bazel query //...
bazel build //...
bazel test //...
```

For large repos, validate agreed target patterns and document remaining gaps.

## CI

Prefer CI that uses user-provisioned Bazelisk/Bazel, honors `.bazelversion`, checks buildifier formatting, then builds/tests selected targets.

```bash
bazel version
buildifier -mode=check -r .
bazel build //...
bazel test //...
```

Add Bazel caches only with clear cache keys and known CI behavior.

## Final Review

- `.bazelversion` is intentional.
- New setup uses Bzlmod unless a reason is documented.
- BUILD files are buildifier-formatted.
- No recursive source globs.
- No package-wide public default visibility.
- Deps are direct and explicit.
- Names and labels are descriptive/literal.
- Validation ran, or skips are explained.
