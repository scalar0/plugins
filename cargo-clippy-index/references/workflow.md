# Cargo Clippy Index Workflow

## Command API

Run every command from the workspace or pass an explicit root.

| Recipe | Contract |
| --- | --- |
| `scan root="." config="" mode="strict"` | Scan packages transactionally and publish an immutable run. |
| `report root="." run="current" view="residuals"` | Render `residuals`, `patch`, `todo`, or `status` without mutation. |
| `apply root="." run="current"` | Check package and source preconditions, then apply the aggregate patch. |
| `verify root="." run="current"` | Recompute controlled values and reject corruption. |
| `test` | Run syntax, fixture, golden, and integration tests. |

These recipes are justified because scan, report, apply, verification, and testing are repeated workflow boundaries that belong in the discoverable command API.
Keep parsing, hashing, staging, and patch construction private to `clippy-index.sh` and its three jq filters.

## Configuration

Pass a configuration path explicitly, or allow `scan` to load `<root>/clippy-index.json`, or use defaults when neither exists.
Reject unknown fields, unknown packages or features, invalid types, duplicate features, and strings containing NUL.

| Field | Default |
| --- | --- |
| `version` | `1` |
| `target` | The active `rustc -vV` host triple. |
| `default_features` | `false` |
| `all_targets` | `true` |
| `packages` | Every workspace package enabled with global defaults. |
| `extra_clippy_args` | An empty array appended after fixed lint arguments. |

Use an object keyed by package name for `packages`.
Override `enabled`, `default_features`, `all_targets`, and sorted unique `features` per package.

```json
{
  "version": 1,
  "target": "x86_64-unknown-linux-gnu",
  "packages": {
    "example": {
      "enabled": true,
      "default_features": false,
      "all_targets": true,
      "features": ["serde"]
    }
  },
  "extra_clippy_args": ["-W", "clippy::restriction"]
}
```

## Run Artifacts

Store immutable runs below `.codex-clippy-index/runs/<run-id>/` and resolve `current` through a relative symlink.
Ignore legacy top-level index files.

| Artifact | Contract |
| --- | --- |
| `plan.json` | Canonical normalized configuration, package plan, hashes, versions, environment inputs, mode, and relaxation reasons. |
| `status.json` | Package-sorted exit codes, argument arrays, and relative stderr references. |
| `raw/` | Non-canonical Cargo JSONL and stderr evidence. |
| `sources/` | Content-addressed snapshots used by suggestions. |
| `index.json` | Canonical diagnostics, suggestions, statuses, and patch summary. |
| `todo.tsv` | Stable rows sorted by diagnostic ID. |
| `patch.json` | Included suggestion IDs, skip reasons, file hashes, and exact patch hash. |
| `machine-applicable.patch` | One timestamp-free aggregate patch, or an empty file. |

Canonical artifacts exclude timestamps and absolute workspace paths.
Diagnostic and suggestion IDs are SHA-256 hashes of canonical content, exact duplicates collapse, and `occurrences` records multiplicity.
Package and Cargo target identity remain part of each diagnostic.

## Publication and Failure

Stage below `.codex-clippy-index/.staging` and publish only after validation and artifact generation.
Update `current` atomically only after every package command succeeds.
Publish failed-package runs for diagnosis, print their run ID, return nonzero, and leave `current` unchanged.
Reuse an existing run when controlled artifacts match.
Quarantine differing output below `conflicts/<run-id>/<output-digest>` and leave `current` unchanged.
Reject a scan when the workspace fingerprint changes while Cargo runs.

## Strict and Relaxed Modes

Use strict mode by default.
Require Git, `Cargo.lock`, a pinned numeric or dated Rust toolchain, required tools, and successful `cargo metadata --frozen`.
Reject semantic Cargo or Rust environment overrides.
Run Cargo with a fixed locale, UTC, no color, no incremental compilation, one job, `--frozen`, an explicit target, and an isolated target directory.

Use `mode="relaxed"` only when strict inputs are unavailable.
Expect `reproducible: false`, explicit relaxation reasons, and a safe allowlist of recorded semantic environment names without credentials.
Apply a relaxed run only when every package succeeded and every source precondition matches, and surface the non-reproducibility warning.

## Patch Safety

Treat every multi-span suggestion atomically.
Reject absolute, escaping, missing, stale, non-UTF-8, and out-of-range paths or spans.
Deduplicate exact suggestions and exact replacement spans.
Skip every member of an overlapping or disagreeing conflict component as `conflicting-suggestion`.
Apply accepted edits by descending byte offset in path-sorted files.
Review the aggregate patch before requesting authorization.
Make `apply` reject failed, stale, corrupted, or already-applied runs before invoking `git apply`.

Treat `clippy::multiple_crate_versions` and changes requiring dependency policy, public API, or broad semantic decisions as manual residual work.
