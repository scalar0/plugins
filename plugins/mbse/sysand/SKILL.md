---
name: sysand
description: Use when the task involves Sysand, SysML v2 or KerML interchange projects, Sysand CLI commands, project metadata, usages/dependencies, lockfiles, environments, packaging to .kpar, workspaces, indexes, or Sysand authentication. Helps the agent explain how to install Sysand, initialize projects, add source files and usages, sync environments, inspect metadata, build packages, and troubleshoot common Sysand workflow issues from the official docs.
---

# Sysand

## Overview

Use this skill when a user asks how to work with Sysand or when a task touches SysML v2 / KerML interchange projects managed by the Sysand CLI.

This skill is for:

- explaining the standard Sysand workflow end to end;
- choosing the right Sysand command for a project-management task;
- answering questions about project metadata, usages, lockfiles, environments, indexes, workspaces, and package publishing;
- avoiding invented commands or assumptions that conflict with the official documentation.

## Core Concepts

A Sysand project is a model interchange project built from SysML v2 (`.sysml`) or KerML (`.kerml`) files plus project metadata.

Important files and directories:

- `.project.json` — project information such as name, version, license, usages, and metamodel;
- `.meta.json` — metadata such as indexed files and checksums;
- `sysand-lock.toml` — resolved dependency versions and sources for reproducible installs;
- `.sysand/` — local environment that stores installed projects and their dependencies;
- `sysand.toml` — optional configuration file for indexes and dependency source overrides;
- `.workspace.json` — optional workspace definition for multiple related projects.

## Default Workflow

1. Confirm whether the user needs installation help, project bootstrapping, dependency management, metadata editing, packaging, workspace setup, or publishing.
2. If Sysand is not installed, recommend the official installation route that best matches the user’s goal:
    - CLI only: `pipx install sysand` or `uv tool install sysand`;
    - CLI + Python library: `pip install sysand` or `uv pip install sysand` in a virtual environment.
3. For a new project, use `sysand init [PATH]`.
4. Inspect project state with `sysand info`, `sysand sources`, and `sysand print-root`.
5. Add model files with `sysand include <PATHS...>`.
6. Add dependencies (“usages”) with `sysand add <IRI> [VERSION_CONSTRAINT]`.
7. Explain that adding usages usually creates or updates `sysand-lock.toml` and synchronizes `.sysand/` unless the user disables that with `--no-lock` or `--no-sync`.
8. Recreate or repair the environment with `sysand sync`.
9. Build a distributable archive with `sysand build`.
10. For advanced scenarios, use `sysand.toml`, `.workspace.json`, authentication environment variables, or publishing commands as documented.

## Essential Guidance

### Installation

- Prefer isolated installs from PyPI for normal CLI usage, using `uv`.
- Verify installation with `sysand --version`.
- If the user wants the Python library, prefer `pip` or `uv pip` inside a virtual environment rather than `pipx` / `uv tool`.

### Creating and Inspecting a Project

- `sysand init my_project` creates a minimal project with `.project.json` and `.meta.json`.
- `sysand info` shows current project information.
- `sysand sources` lists source files from the current project and, by default, relevant dependencies.
- `sysand print-root` finds the current project root by walking upward from the current directory.

### Including Source Files

- Use `sysand include <file>` to add `.sysml` or `.kerml` files to the project metadata.
- `sysand exclude <file>` removes them from the metadata.
- Mention `--compute-checksum` if the user needs recorded SHA256 checksums.

### Managing Usages and Environments

- Sysand calls dependencies “usages”.
- A usage is identified by an IRI and can optionally include a version constraint.
- `sysand add sensmetry/detect` (or `sysand add pkg:sysand/sensmetry/detect`) adds a usage and usually updates the lockfile and environment.
- `sysand remove <IRI>` removes a usage.
- `sysand env list` shows installed packages in `.sysand/`.
- `sysand env sources <IRI>` lists installed source files for a package.
- `sysand sync` recreates the environment from `sysand-lock.toml`.
- Recommend committing `sysand-lock.toml` to version control and ignoring `.sysand/`.

### Standard Library Behavior

- SysML v2 / KerML standard libraries are omitted by default in several outputs and dependency operations.
- If the user needs them included, mention the `--include-std` flag.

### Metadata and Project Information

Use `sysand info` subcommands for local metadata edits, such as:

- `sysand info name --set ...`
- `sysand info description --set ...`
- `sysand info version --set ...`
- `sysand info license --set ...`
- `sysand info maintainer --add ...`
- `sysand info topic --add ...`
- `sysand info website --set ...`
- `sysand info metamodel --set sysml --release 20250201`

When discussing metadata rules, remember:

- version strings are expected to follow SemVer unless `--no-semver` is used;
- licenses are expected to be valid SPDX expressions unless `--no-spdx` is used;
- usage version constraints follow Cargo-style version requirement syntax.

### Packaging and Publishing

- `sysand build` creates a `.kpar` archive, typically in `output/`.
- Built packages can be added as usages via `file://...` URLs or published to an index.
- `sysand publish --index <URL>` publishes a built `.kpar` to a Sysand-compatible index.
- Publishing requires authentication, and project metadata must satisfy the documented naming, version, and license rules.

### Configuration, Indexes, and Overrides

- Sysand defaults to the package index at `https://sysand.com`.
- Additional or replacement indexes can be provided by CLI flags or in `sysand.toml`.
- Use `--index` for extra indexes and `--default-index` to replace the default index.
- Use `sysand.toml` `[[project]]` entries to define local, editable, local-kpar, remote-src, remote-kpar, or remote-git dependency sources.
- For index-hosted projects, prefer `pkg:sysand/<publisher>/<name>` (or `<publisher>/<name>` shorthand when using `sysand add`).

### Hosting a private index

- For a local private index, use `sysand index init`, then `sysand index add --kpar-path <FILE.kpar> [IRI]`.
- Serve the index directory via any static HTTP server (for example, `python3 -m http.server 8080` for local testing).
- Consumers install from it with `sysand add pkg:sysand/<publisher>/<name> --index <URL>`.
- Mention `sysand index yank` / `sysand index remove` for lifecycle management of indexed versions.
- Note that index and `.sysand` on-disk structure may change between 0.x versions; avoid prescribing undocumented internals.

### Authentication

- Authentication is configured through environment variables.
- Basic auth pattern:
    - `SYSAND_CRED_<X>=<PATTERN>`
    - `SYSAND_CRED_<X>_BASIC_USER=<USER>`
    - `SYSAND_CRED_<X>_BASIC_PASS=<PASSWORD>`
- Bearer token pattern:
    - `SYSAND_CRED_<X>=<PATTERN>`
    - `SYSAND_CRED_<X>_BEARER_TOKEN=<TOKEN>`
- Only describe credentials patterns from the docs; do not invent unsupported auth mechanisms.

### Workspaces

- A workspace is defined by `.workspace.json`.
- Use it when several related projects are developed together.
- Explain that workspace support is documented as experimental.

## Response Style

When using this skill:

- map the user’s question to the smallest relevant Sysand workflow slice instead of dumping the whole manual;
- provide concrete commands only when they fit the user’s scenario;
- mention side effects such as lockfile generation, `.sysand/` creation, or default omission of standard libraries;
- distinguish between local project metadata, environment state, and published package/index behavior;
- if a detail is uncertain, prefer saying it is not documented in this skill and consult the official docs instead of guessing.

## Quick Reference

See `./references/essentials.md` for a concise command and concept cheat sheet distilled from the official documentation.

For deeper scenarios, load the focused references that match the task:

- `./references/private-indexes.md` — local, GitHub, and GitLab private index workflows;
- `./references/publishing.md` — package build, publish prerequisites, index targets, and auth guidance;
- `./references/authentication.md` — bearer/basic auth patterns, URL matching, and enterprise-safe credential guidance;
- `./references/troubleshooting.md` — common failure modes, inspection steps, and default-behavior gotchas.

## Official Documentation

Primary documentation: `https://docs.sysand.com/client/`
Useful starting points:

- Installation: `https://docs.sysand.com/client/getting-started/installation/`
- First steps: `https://docs.sysand.com/client/getting-started/first-steps/`
- Creating your first project: `https://docs.sysand.com/client/tutorials/creating-your-first-project/`
- Hosting an index: `https://docs.sysand.com/client/tutorials/hosting-index/`
- Command reference: `https://docs.sysand.com/client/reference/commands/`
