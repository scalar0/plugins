---
name: uv
description: Manage Python dependencies and run Python tooling using the uv CLI (sync/lock/run/pip/tool/python). Trigger when you need to deal with installing deps, updating lockfiles, running Python commands in a managed env, or troubleshooting uv.
compatibility: Requires uv
---

# uv

## Overview

`uv` is a Python package manager and project runner.

In this repository, `uv` is the expected way to:

- create/update the project environment from `pyproject.toml`
- lock dependencies (`uv.lock`) for reproducible installs
- run tools like `ruff` and `pytest` via `uv run ...`

The repo’s dependency groups live in `pyproject.toml` (see `[project.optional-dependencies]` and `[tool.uv]`).

## Commands

- [`uv auth`](references/cli.md#uv-auth) : Manage authentication
- [`uv run`](references/cli.md#uv-run) : Run a command or script
- [`uv init`](references/cli.md#uv-init) : Create a new project
- [`uv add`](references/cli.md#uv-add) : Add dependencies to the project
- [`uv remove`](references/cli.md#uv-remove) : Remove dependencies from the project
- [`uv version`](references/cli.md#uv-version) : Read or update the project's version
- [`uv sync`](references/cli.md#uv-sync) : Update the project's environment
- [`uv lock`](references/cli.md#uv-lock) : Update the project's lockfile
- [`uv export`](references/cli.md#uv-export) : Export the project's lockfile to an alternate format
- [`uv tree`](references/cli.md#uv-tree) : Display the project's dependency tree
- [`uv format`](references/cli.md#uv-format) : Format Python code in the project
- [`uv tool`](references/cli.md#uv-tool) : Run and install commands provided by Python packages
- [`uv python`](references/cli.md#uv-python) : Manage Python versions and installations
- [`uv pip`](references/cli.md#uv-pip) : Manage Python packages with a pip-compatible interface
- [`uv venv`](references/cli.md#uv-venv) : Create a virtual environment
- [`uv build`](references/cli.md#uv-build) : Build Python packages into source distributions and wheels
- [`uv publish`](references/cli.md#uv-publish) : Upload distributions to an index
- [`uv cache`](references/cli.md#uv-cache) : Manage uv's cache
- [`uv self`](references/cli.md#uv-self) : Manage the uv executable
- [`uv help`](references/cli.md#uv-help) : Display documentation for a command

Full reference for all `uv` commands [here](references/cli.md).

## Best Practices

- Prefer `uv sync --locked` in CI to ensure reproducibility.
- Keep `uv.lock` checked in for apps/CLIs where reproducibility matters (see `.gitignore` notes in this repo).
- Use `uv run ...` instead of activating a venv manually—fewer “works on my machine” surprises.
- If you’re behind a proxy / custom index, configure via env vars or settings (see references below).

## Failure Handling

- Resolver errors: try `uv lock` to regenerate `uv.lock`, or use `--upgrade` when constraints changed.
- Network/index/auth issues: check configured indexes and credentials; see `uv auth` and env vars like `UV_INDEX`, `UV_DEFAULT_INDEX`, `UV_HTTP_TIMEOUT`.
- “Lockfile out of date” in CI: run `uv lock` locally and commit the updated `uv.lock`.

## References (bundled)

- To get details about one command, follow the link to the corresponding section in [CLI reference](references/cli.md).
- Configuration options for `uv` behavior [here](references/settings.md).
- Environment variables affecting `uv` are listed [here](references/environment-variables.md).
