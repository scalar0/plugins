# Sysand essentials

## What Sysand manages

- SysML v2 / KerML interchange projects
- project information in `.project.json`
- source metadata in `.meta.json`
- resolved dependencies in `sysand-lock.toml`
- installed environments in `.sysand/`
- optional configuration in `sysand.toml`
- optional multi-project workspaces in `.workspace.json`

## Common commands

### Install

- CLI only: `pipx install sysand`
- CLI only: `uv tool install sysand`
- CLI + library: `pip install sysand`
- CLI + library in venv: `uv pip install sysand`
- Verify: `sysand --version`

### Project lifecycle

- Initialize: `sysand init [PATH]`
- Inspect: `sysand info`
- Find root: `sysand print-root`
- List sources: `sysand sources`
- Include model file: `sysand include <PATHS...>`
- Exclude model file: `sysand exclude <PATHS...>`

### Dependencies and env

- Add usage: `sysand add <IRI|PUBLISHER/NAME> [VERSION_CONSTRAINT]`
- Remove usage: `sysand remove <IRI>`
- Create env: `sysand env`
- List installed packages: `sysand env list`
- List installed sources: `sysand env sources <IRI> [VERSION]`
- Re-sync env from lockfile: `sysand sync`
- Lock without syncing: `sysand lock`

### Packaging and publishing

- Build package: `sysand build`
- Publish package: `sysand publish --index <URL> [PATH]`

## Key behavior to remember

- Dependencies are called "usages".
- Standard libraries are often omitted by default; use `--include-std` when needed.
- `sysand add` usually resolves dependencies and syncs the environment unless disabled.
- `sysand-lock.toml` should usually be committed; `.sysand/` should usually be ignored.
- Version constraints use Cargo-style semantics.
- Metadata edits are done through `sysand info` subcommands.
- Authentication is configured through `SYSAND_CRED_*` environment variables.
- Sysand defaults to `https://sysand.com` as the package index.

## Useful `sysand info` subcommands

- `name`
- `description`
- `version`
- `license`
- `website`
- `maintainer`
- `topic`
- `metamodel`
- `usage` (read-only)
- `index` (read-only)
- `checksum` (read-only)
- `created` (read-only)

## When to mention config files

Mention `sysand.toml` when the user needs:

- custom or default indexes;
- local editable dependencies;
- local or remote source overrides;
- repeatable resolution behavior across machines.

Mention `.workspace.json` when the user has multiple related projects under one workspace root.

## Deep-dive references in this skill

- `private-indexes.md` — team/private index setup and consumption patterns
- `publishing.md` — build, publish, and package-readiness guidance
- `authentication.md` — credential patterns, token scoping, and private index access
- `troubleshooting.md` — diagnosis workflow and common Sysand gotchas
