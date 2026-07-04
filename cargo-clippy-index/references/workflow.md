# Cargo Clippy Index Workflow

## Package Sweep

Use a package-by-package sweep when workspace-level `cargo clippy --workspace` is noisy, slow, or fails before reaching later crates.
Use `--fix --allow-dirty` only when the user asked to fix diagnostics or the task clearly requires mechanical remediation.
Use `--no-default-features` by default when the request names that mode, and add package-scoped features with the `feature_map` recipe argument.

Feature map examples:

```bash
just -f scripts/Justfile sweep-fix . \
  cli=git2,runtime-controller=git2,runtime-core=git2,server=git2,server-app=git2,vcs=git2
```

The sweep writes these files:

| Path                                       | Purpose                                      |
| ------------------------------------------ | -------------------------------------------- |
| `.codex-clippy-index/raw/<package>.jsonl`  | Raw Cargo JSON messages for one package      |
| `.codex-clippy-index/raw/<package>.stderr` | Non-JSON Cargo stderr for one package        |
| `.codex-clippy-index/status.tsv`           | Package exit codes and exact commands        |
| `.codex-clippy-index/index.json`           | Aggregated diagnostics and patch manifest    |
| `.codex-clippy-index/todo.tsv`             | Stable unique todo rows for agent planning   |
| `.codex-clippy-index/patches/<id>.patch`   | Derived `git apply` patch for one suggestion |

Use `scripts/Justfile` as the main command surface:
It uses `set no-cd`, so run it from the Cargo workspace or pass an explicit workspace path as the `root` argument.

| Recipe                   | Purpose                                                         |
| ------------------------ | --------------------------------------------------------------- |
| `sweep`                  | Run a package-by-package Clippy sweep                           |
| `sweep-fix`              | Run the sweep with `cargo clippy --fix --allow-dirty`           |
| `index-json`             | Rebuild only `index.json` from raw logs                         |
| `index`                  | Rebuild `index.json` and `todo.tsv` from raw logs               |
| `patches`                | Rebuild `index.json`, `todo.tsv`, and derived patch files       |
| `patches-json`           | Show patch manifest rows after `jq`                             |
| `patches-csv`            | Show patch manifest rows after `jq` and `xan from`              |
| `patches-md`             | Render patch manifest rows as markdown                          |
| `table`                  | Render unresolved diagnostics as markdown                       |
| `todo-md`                | Render `todo.tsv` as markdown                                   |
| `todo-json`              | Show todo rows as JSON                                          |
| `todo-csv`               | Show todo rows after `xan from -f json`                         |
| `packages`               | Print sorted workspace package names                            |
| `multiple-versions-json` | Show dependency-version residual rows after `jq`                |
| `multiple-versions-csv`  | Show dependency-version residual rows after `jq` and `xan from` |
| `multiple-versions-md`   | Render dependency-version residual rows as markdown             |
| `residual-summary-json`  | Show non-dependency residual rows after `jq`                    |
| `residual-summary-csv`   | Show non-dependency residual rows after `jq` and `xan from`     |
| `residual-summary-md`    | Render non-dependency residual rows as markdown                 |
| `todo-tsv`               | Show todo rows after `jq`, `xan from`, and `xan fmt --tabs`     |

Use `jq` filters for structured JSON work:

| Filter                              | Purpose                                                                      |
| ----------------------------------- | ---------------------------------------------------------------------------- |
| `scripts/workspace-packages.jq`     | Select workspace package names from `cargo metadata`                         |
| `scripts/extract-diagnostics.jq`    | Extract diagnostics and suggestion metadata from Cargo JSONL                 |
| `scripts/patch-inputs-tsv.jq`       | Shape suggestion replacement rows for the shell patch tool                   |
| `scripts/patch-results-json.jq`     | Convert patch result TSV into JSON                                           |
| `scripts/index-json.jq`             | Assemble final `index.json` from diagnostics and patch results               |
| `scripts/todo-json.jq`              | Shape unique todo rows before `xan from -f json` and `xan fmt --tabs`        |
| `scripts/patches-json.jq`           | Shape patch manifest rows before `xan from -f json` and `xan to md`          |
| `scripts/multiple-versions-json.jq` | Shape dependency-version rows before `xan from -f json` and `xan to md`      |
| `scripts/residual-summary-json.jq`  | Shape non-dependency residual rows before `xan from -f json` and `xan to md` |

Use `scripts/derive-patches.sh` only for patch file derivation:
It reads rows normalized by `xan fmt`, applies byte replacements with shell and coreutils, writes `.codex-clippy-index/patches/*.patch`, computes ids with `git patch-id --stable`, and emits normalized patch results that `xan fmt` converts back to TSV for jq to merge into `index.json`.

The `index.json` file contains these top-level keys:

| Key              | Purpose                                                    |
| ---------------- | ---------------------------------------------------------- |
| `generated_at`   | UTC generation timestamp                                   |
| `workspace_root` | Absolute workspace root used for file reads                |
| `diagnostics`    | Extracted diagnostics with suggestion and patch id details |
| `patches`        | Manifest rows for written or skipped patch suggestions     |

## Patch Derivation

Use `patches` after a sweep when you want reviewable edits without mutating the workspace.
Use `patches-md` before applying suggestions so skipped cases are visible.
Apply an individual patch only after inspecting it:

```bash
git apply --check .codex-clippy-index/patches/<id>.patch
git apply .codex-clippy-index/patches/<id>.patch
```

The patch tool writes patches only for `MachineApplicable` suggestions.
It skips suggestions with missing files, non-UTF-8 files, missing span data, invalid byte spans, overlapping spans, empty patches, and replacements that would produce non-UTF-8 output.
Skipped suggestions remain in `index.json` and `patches-md` with a reason.

## Fix Loop

Start with packages that fail to compile because they block later lint data.
Then fix ordinary Clippy diagnostics by package.
Prefer derived patch files for simple machine-applicable suggestions when you want reviewable, selective edits.
Use `sweep-fix` when the user wants Cargo to apply fixable suggestions directly across packages.
Use subagents for independent crates when the index identifies clear ownership boundaries.
Do not ask subagents to change shared dependency versions unless that is the explicit task.
Run `cargo fmt --all` after mechanical fixes.
Run the sweep again after formatting so raw logs reflect the final tree.

## Residual Diagnostics

Use `just -f scripts/Justfile table` for `clippy::multiple_crate_versions` and any other residual diagnostics.
The Just recipes should keep data shaping in `jq` and delegate table conversion or rendering to `xan fmt`, `xan from -f json`, and `xan to md`.
This diagnostic often reflects upstream transitive dependencies, generated code, platform crates, or semver-major upgrade choices.
Classify it as unresolved when fixing it would require dependency-policy changes, public API changes, generated-code strategy changes, or broad lockfile churn outside the requested scope.

For other residual diagnostics, group by `code`, `message`, and affected packages in the final answer.
Mention whether tests or focused package Clippy runs were executed.
