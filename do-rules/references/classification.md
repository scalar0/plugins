# Classification Heuristics

## Read-only commands

Treat as `allow` when the command only:

- Prints help, version, config metadata, rule docs, or capability info
- Lists objects, dependencies, refs, issues, releases, tools, or installed versions
- Shows diffs, logs, traces, reports, checksums, or dependency graphs
- Verifies, validates, or inspects without rewriting files

## Mutating commands

Treat as `prompt` when the command:

- Creates, edits, removes, renames, or moves files or directories
- Rewrites manifests, lockfiles, caches, environments, or build trees
- Installs, upgrades, uninstalls, syncs, builds, publishes, or uploads
- Changes auth state, tokens, keys, config, branches, refs, tags, or remotes
- Executes arbitrary code, scripts, package entrypoints, or subprocesses
- Launches servers, browsers, GUIs, or interactive editors

## Mixed families

Some families mix read-only and mutating behavior under the same prefix.

Examples from this session:

- `cargo owner`: `--list` reads, but `--add` and `--remove` mutate registry state
- `cargo install`: `--list` reads, but normal use installs binaries
- `cargo nextest`: `show-config` reads, but most other subcommands build or run tests
- `git branch`, `git stash`, `git remote`, `git tag`: list and show paths exist alongside mutating operations
- `ruff check`: plain linting can be read-only, but `--fix` rewrites files
- `uv version`: read-only without an argument, mutating with a new version value
- `date`, `env`, `sort`, `shuf`, `tee`: harmless in some forms, mutating or process-executing in others

When the matcher cannot express the safe subset cleanly, classify the family as `prompt`.

## Precedence gotcha

Do not assume that a more specific rule always overrides a broader rule the way you want.

Always test overlap cases with `codex execpolicy check`.

If overlap causes the wrong decision:

1. Narrow the broad rule.
2. Split the family into separate non-overlapping rules.
3. Fall back to conservative `prompt` coverage if needed.
