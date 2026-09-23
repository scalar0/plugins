---
name: cargo-clippy-index
description: Create reproducible workspace Clippy inventories and review or apply their fixes.
---

# Cargo Clippy Index

Use [workflow.md](references/workflow.md) for scan configuration, run artifacts, failure handling, and patch safety.
Read the sections needed for the requested phase.
Use the skill's [Justfile](scripts/Justfile) for every phase.

| Phase            | Command or gate                                                                                                       |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| Scan             | `just -f <skill-dir>/scripts/Justfile scan <workspace>`                                                               |
| Review patch     | `just -f <skill-dir>/scripts/Justfile report <workspace> current patch`                                               |
| Review residuals | `just -f <skill-dir>/scripts/Justfile report <workspace> current residuals`                                           |
| Apply            | Run `just -f <skill-dir>/scripts/Justfile apply <workspace> current` only after explicit source-change authorization. |

For authorized cleanup, fix manual residuals in coherent batches.
Rescan after each batch or applied patch, before another patch application or the final report.
Use existing source-change authorization when it covers the patch.
Report the latest run ID and remaining residuals.
Never edit run artifacts, apply suggestions during `scan`, or treat raw Cargo logs as canonical output.
