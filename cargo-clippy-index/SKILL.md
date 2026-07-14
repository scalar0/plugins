---
name: cargo-clippy-index
description: Run deterministic package-by-package Cargo Clippy scans, publish immutable content-addressed diagnostic indexes, review safe aggregate patches, verify stored runs, and apply explicitly authorized mechanical fixes. Use for workspace-wide Clippy remediation, reproducible lint inventories, machine-applicable suggestion review, residual diagnostic reporting, or resuming a lint cleanup.
---

# Cargo Clippy Index

1. Read project instructions and inspect the workspace recipes and Clippy configuration.
2. Read [references/workflow.md](references/workflow.md) before choosing strict or relaxed mode, configuring packages, diagnosing a failure, or applying a patch.
3. Run `just -f <skill-dir>/scripts/Justfile scan <workspace>` for a strict deterministic scan.
4. Run `just -f <skill-dir>/scripts/Justfile report <workspace> current patch` and `report <workspace> current residuals` to review the immutable run.
5. Run `just -f <skill-dir>/scripts/Justfile apply <workspace> current` only after the user explicitly authorizes source changes.
6. Fix manual residual diagnostics directly, and reserve subagents only for separately assigned independent residual work.
7. Rescan after every applied patch or manual edit, then report the new run ID and remaining residuals.

Never edit run artifacts, apply suggestions during `scan`, or treat raw Cargo logs as canonical output.
