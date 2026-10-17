# Task details

## Affected tests

1. Inspect `aspect describe 'cache diff'` for the installed contract.
2. Check for a populated remote-cache baseline and matching Bazel flags.
3. Run `aspect cache diff <target-pattern> --output=json` within the required scope.
4. Select `.affected[].label` with `jq`.
5. If the set is nonempty, run the selected tests.

An empty result is not a test run.
The `precise` mode can build missing actions.
Actions that bypass the remote cache can execute locally.
If prerequisites fail, use the repository test procedure.

Source: [aspect cache diff](https://aspect.build/docs/cli/tasks/cache_diff).

## AXL composition

1. Inspect `.aspect/config.axl`, its local modules, `.aspect/*.axl`, and `MODULE.aspect` where present.
2. Get the required AXL API and task configuration guidance through `aspect-docs` or the documentation index.
3. Keep `.aspect/config.axl` as a composition root that loads modules and calls their `configure(ctx)` functions.
4. Place aliases, defaults, features, and shared policies in small modules with explicit owners.
5. Check task discovery and effective defaults with `aspect describe '<task>'`.
6. Run the affected task within the authorized scope.

Reuse current module names and create modules only where needed.
Keep each configuration field under one module's control.
Import shared flags from their policy module instead of copying them into task modules.
Keep scopes and mutable data in their authoritative data files.
Preserve module call order when it affects configuration.

For example, `.aspect/config.axl` can compose the modules as follows:

```axl
# Shared Bazel flags and policies for build, test, run, or other tasks.
load("./bazel.axl", configure_bazel = "configure")
# Feature enablement and feature configuration.
load("./features.axl", configure_features = "configure")
# Format aliases, formatter targets, scope, and check defaults.
load("./format.axl", configure_format = "configure")
# Gazelle aliases, generation targets, scope inputs, and update or check modes.
load("./gazelle.axl", configure_gazelle = "configure")
# Lint aliases, aspects, strategies, and required or advisory checks.
load("./lint.axl", configure_lint = "configure")

def config(ctx):
    configure_bazel(ctx)
    configure_features(ctx)
    configure_format(ctx)
    configure_gazelle(ctx)
    configure_lint(ctx)
```

Keep task logic separate from configuration and mutable data.
Preserve deployment and CI behavior unless requested otherwise.

Source: [AXL tasks](https://aspect.build/docs/cli/guides/basic).
