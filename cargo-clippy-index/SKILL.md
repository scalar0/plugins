---
name: cargo-clippy-index
description: Standardize Rust workspace Clippy remediation by running Cargo Clippy package-by-package, capturing JSON diagnostics, deriving git patches from machine-applicable Clippy suggestions, maintaining a .codex-clippy-index todo index, and reporting unresolved diagnostics. Use when Codex is asked to fix Clippy across a Cargo workspace, derive or review Clippy suggestion patches, run clippy --fix safely crate by crate, aggregate json-diagnostic-short output, resume a lint sweep, or produce a markdown table of diagnostics that need dependency or breaking-change decisions.
---

# Cargo Clippy Index

## Overview

Use this skill to turn large Cargo Clippy cleanup work into an indexed, resumable workflow.
Prefer scripts over handwritten shell loops so every package leaves raw logs, exit status, regenerated todo files, and patch manifests.
Prefer `jq` filters for JSON selection and grouping, then use `xan from -f json` and `xan to ...` for format conversion.
Use the bundled `scripts/Justfile` as the only executable orchestration layer.

## Workflow

1. Read local project instructions first, especially `AGENTS.md`, `just --list`, workspace features, and any existing Clippy configuration.
2. Inspect `Cargo.toml` and `cargo metadata` to identify workspace packages and package-scoped features such as `pkg/feature`.
3. Use `scripts/Justfile` as the main entrypoint for indexing, patch derivation, sweeps, and rendered reports.
4. Review `.codex-clippy-index/patches/*.patch` before applying machine-applicable suggestions.
5. Fix diagnostics by package, using subagents when the workspace is large and the edits are independent.
6. Re-run the package sweep until only intentional residual diagnostics remain.
7. Render unresolved diagnostics with `just -f .../scripts/Justfile table` and include the table in the final answer.

## Scripts

Run a full no-default-feature sweep and apply fixable suggestions:

```bash
just -f /home/me/.codex/skills/cargo-clippy-index/scripts/Justfile sweep-fix . \
  crate1=feature1,crate2=feature2
```

Regenerate the index from existing raw JSONL logs without invoking Cargo:

```bash
just -f /home/me/.codex/skills/cargo-clippy-index/scripts/Justfile index .
```

Regenerate the index and derived patch files from existing raw JSONL logs:

```bash
just -f /home/me/.codex/skills/cargo-clippy-index/scripts/Justfile patches .
```

Render the patch manifest for review:

```bash
just -f /home/me/.codex/skills/cargo-clippy-index/scripts/Justfile patches-md .
```

Render the unresolved dependency-version table:

```bash
just -f /home/me/.codex/skills/cargo-clippy-index/scripts/Justfile table .
```

The Just recipes use `jq` filters to extract diagnostics, shape patch inputs, assemble `index.json`, and render report rows.
The Just recipes use `xan` for TSV and CSV delimiter conversion, JSON-to-CSV conversion, and markdown table rendering.
The Just recipes call `scripts/derive-patches.sh` only for patch file derivation from xan-normalized rows.
Read `references/workflow.md` when deciding package-feature maps, subagent boundaries, or final-report contents.

## Operating Rules

- Keep `.codex-clippy-index/raw/<package>.jsonl` as the source of truth and regenerate derived files instead of editing them by hand.
- Keep `.codex-clippy-index/patches/*.patch` derived from raw logs and `scripts/derive-patches.sh`; do not hand-edit patch files.
- Keep JSON extraction, filtering, grouping, and index assembly in `.jq` files rather than shell or ad hoc parsing.
- Use `xan fmt`, `xan from`, and `xan to` for table delimiter conversion, structured format conversion, and markdown rendering whenever practical.
- Use `scripts/Justfile` as the discoverable orchestration entrypoint and keep recipes as thin wrappers over scripts and pipelines.
- The Justfile uses `set no-cd` so recipe paths such as `root="."` resolve from the directory where `just` was invoked.
- Pass package-scoped features to `sweep` and `sweep-fix` as comma-separated `package=feature` values.
- Re-run `index` after any manual package-level Clippy run so `index.json` and `todo.tsv` match the latest raw logs.
- Use `patches-md` to review which machine-applicable suggestions produced `git apply` patch files and which suggestions were skipped.
- Treat `clippy::multiple_crate_versions` as a dependency-policy finding unless the workspace already has an obvious compatible upgrade path.
- Report diagnostics that cannot be fixed without semantic, public API, dependency graph, or breaking changes in a markdown table rendered through `xan from -f json | xan to md`.
