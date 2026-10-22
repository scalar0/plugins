# Sysand troubleshooting patterns

## When to use this reference

Use this reference when the user is stuck with:

- install or PATH problems;
- missing project detection;
- dependencies not resolving as expected;
- confusion about `.sysand`, `sysand-lock.toml`, or standard libraries;
- publishing or private-index failures;
- metadata validation errors.

## Troubleshooting workflow

1. Identify which layer is failing:
    - installation;
    - current project detection;
    - source inclusion;
    - usage resolution;
    - environment synchronization;
    - metadata validation;
    - packaging/publishing;
    - private index/authentication.
2. Confirm the expected files and directories for that layer.
3. Re-run the smallest relevant inspection command.
4. Explain default Sysand behavior that may look surprising.
5. Only then suggest corrective commands or config changes.

## Common problem patterns

### `sysand` command not found

Checks:

- verify installation path and installation method;
- run `sysand --version` after installation;
- if installed from a standalone binary, ensure the binary is executable and on `PATH`;
- if `PATH` was changed, restart the shell or terminal session.

### Wrong project root or command run in the wrong directory

Checks:

- use `sysand print-root` to confirm which project root Sysand detects;
- remember that Sysand searches upward for `.project.json` or `.meta.json`;
- if none is found, current-directory behavior may apply for some commands.

### Source files do not appear in project output

Checks:

- confirm the `.sysml` / `.kerml` file was added with `sysand include`;
- inspect with `sysand sources`;
- if checksums or symbol indexing matter, mention `--compute-checksum` and `--no-index-symbols` behavior.

### Added dependency but source files are missing

Checks:

- explain that standard libraries are omitted by default in several commands;
- use `--include-std` if the user expects standard library files to appear;
- inspect installed packages with `sysand env list`;
- re-sync with `sysand sync` if the environment is stale.

### Environment differs across machines

Checks:

- confirm `sysand-lock.toml` is present and committed;
- explain that `.sysand/` should usually be recreated rather than committed;
- use `sysand sync` to reproduce the environment from the lockfile.

### Local path dependency hurts portability

Checks:

- explain that `file://` usages encode absolute paths and are machine-specific;
- recommend workspace IRIs or configured sources in `sysand.toml` when portability matters;
- mention editable/local source overrides when collaborating on related local projects.

### Version resolution confusion

Checks:

- explain that version constraints follow Cargo-style syntax;
- confirm whether the user intended exact, caret, tilde, wildcard, or comparator semantics;
- mention that non-SemVer versions reduce Sysand’s ability to select versions correctly.

### Publishing fails

Checks:

- confirm `sysand build` ran first;
- confirm `--index` points to the intended publish target (index root or API root, depending on index implementation);
- confirm required metadata fields are valid;
- confirm a matching bearer token is configured for the publish URL.

### Private index access fails

Checks:

- verify the configured index URL;
- verify the credential pattern actually matches the request URL;
- check whether the token or credentials are scoped correctly;
- if using GitHub/GitLab hosted indexes, verify the platform-specific URL shape from the docs.

## High-value reminders

- `sysand add` normally changes both dependency state and environment state unless disabled.
- `sysand lock` focuses on lockfile generation, while `sysand sync` focuses on reproducing the environment.
- `.sysand/` may contain more than the current project’s direct dependencies and is not automatically pruned to the minimal set.
- workspace support is documented as experimental.

## How to answer troubleshooting questions well

- prefer inspection commands before mutation commands;
- explain the default behavior causing confusion, not just the fix;
- keep project metadata, lockfile state, and environment state conceptually separate;
- if authentication is involved, load `authentication.md` alongside this reference.
