# Bazel Tooling

Sources: [Bazelisk README](https://github.com/bazelbuild/bazelisk/blob/master/README.md), [buildifier README](https://github.com/bazelbuild/buildtools/blob/main/buildifier/README.md), [buildozer README](https://github.com/bazelbuild/buildtools/blob/main/buildozer/README.md).

User owns tool installation. If `bazel`, `bazelisk`, `buildifier`, or `buildozer` is missing, report the missing tool and ask how to proceed.

## Bazelisk

Recommended Bazel launcher. It chooses/downloads Bazel and forwards args.

Version precedence:

1. `USE_BAZEL_VERSION` env.
2. Workspace `.bazeliskrc`.
3. Nearest `.bazelversion`.
4. `USE_BAZEL_FALLBACK_VERSION`.
5. Latest release.

Project rule: commit `.bazelversion`; avoid floating `latest` unless requested.

Useful commands:

```bash
bazel version
bazel build //...
bazel test //...
bazelisk --strict build //...
bazelisk --migrate build //...
bazelisk --bisect=6.0.0..HEAD test //pkg:target_test
```

Inspect `tools/bazel*` wrappers before changing invocation behavior; Bazelisk sets `BAZEL_REAL` for wrappers.

## buildifier

Formatter/linter for BUILD, `MODULE.bazel`, `WORKSPACE`, `.bzl`, and related Starlark files.

```bash
buildifier path/to/BUILD.bazel
buildifier -r .
buildifier -mode=check -r .
buildifier --lint=warn -r .
buildifier --lint=fix -r .
buildifier -mode=check --format=json -r .
```

Use `--type` for ambiguous stdin/generated files:

```bash
cat generated.star | buildifier --type=build
cat generated.module.bzl | buildifier --type=module
```

## buildozer

Source-level BUILD rewriter. Use for bulk mechanical edits; direct edits are clearer for small changes.

Syntax:

```bash
buildozer [OPTIONS] 'command arg...' [label]...
```

Selectors:

- `//pkg:rule`: one rule.
- `//pkg:__pkg__`: package/file-level edits.
- `//pkg:*`: all package rules.
- `//pkg/...:*`: descendant packages.
- `//pkg:%java_library`: rules of kind.
- `//pkg:%123`: rule at line.
- `//MODULE.bazel:all`: module edits.

Common commands:

```bash
buildozer 'add deps //base' //pkg:target
buildozer 'remove deps //old:dep' //pkg:%cc_library
buildozer 'new_load //tools/build_rules:defs.bzl my_rule' //pkg:__pkg__
buildozer 'replace_load @rules_build//build:defs.bzl my_rule' //pkg:__pkg__
buildozer 'new cc_library helper' //pkg:__pkg__
buildozer 'rename old_attr new_attr' //pkg:target
buildozer 'fix unusedLoads' //pkg:__pkg__
```

Batch edits:

```bash
cat >/tmp/buildozer.cmds <<'EOF'
add deps //base //strings|add srcs foo.cc|//pkg:foo
remove deps //old:dep|//pkg:%cc_library
EOF
buildozer -f /tmp/buildozer.cmds
buildifier -r .
```

Important: buildozer edits source syntax and does not evaluate macros. For expanded BUILD output first:

```bash
bazel query --output=build //pkg:target
```

## Common Sequences

```bash
# Bootstrap validation
bazel version
bazel mod tidy
buildifier -r .
bazel query //...
bazel build //...
bazel test //...

# Formatting check
buildifier -mode=check -r .

# Mechanical dependency rewrite
bazel query 'rdeps(//..., //old:dep)' --output=label
buildozer 'replace deps //old:dep //new:dep' //pkg:target
buildifier -r .
bazel test //...
```
