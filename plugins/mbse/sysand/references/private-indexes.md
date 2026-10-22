# Sysand private indexes

## When to use this reference

Use this reference when the task involves:

- hosting a private or team-local Sysand package index;
- consuming packages from a non-default index;
- configuring index URLs in commands, config files, CI, GitHub, or GitLab;
- yanking/removing versions from a local index.

## Key concepts

- Sysand defaults to `https://sysand.com` as its package index.
- Additional indexes can be provided with `--index`.
- Replacement default indexes can be provided with `--default-index`.
- Indexes can also be configured in `sysand.toml`.
- A private index is a directory tree that Sysand understands, served over HTTP.
- Sysand docs explicitly warn that index and `.sysand` on-disk layouts may change across 0.x versions.

## CLI and config patterns

### Add an extra index for resolution

Use `--index <URL>` when the user wants to keep the public default index and add another source.

### Replace the default index

Use `--default-index <URL>` when the user wants to override the default `https://sysand.com`.

### Define indexes in `sysand.toml`

Use configuration when the same index setup should apply repeatedly across machines or commands.

Examples:

```toml
[[index]]
url = "https://index.example.org"
```

```toml
[[index]]
url = "https://index.example.org"
default = true
```

Notes:

- regular indexes are prioritized ahead of default indexes;
- command-line options and environment variables take priority over configuration files.

## Local machine index workflow (current docs)

1. Create a local index directory:
   - `sysand index init`
2. Add a package archive:
   - `sysand index add --kpar-path MyProject.kpar`
3. If `.project.json` in the KPAR has no `publisher`, provide an IRI explicitly:
   - `sysand index add my:iri/my-project --kpar-path MyProject.kpar`
4. Optionally manage published versions:
   - yank: `sysand index yank --version <VERSION> <IRI>`
   - remove: `sysand index remove --version <VERSION> <IRI>` or `sysand index remove --project <IRI>`
5. Serve the index directory over HTTP (testing example):
   - `python3 -m http.server 8080`
6. Consume it from clients:
   - `sysand add pkg:sysand/<publisher>/<name> --index http://localhost:8080`
   - or replace the public default index with `--default-index http://localhost:8080`

Important guidance from docs:

- for `sysand index add`, default IRI shape is `pkg:sysand/<publisher>/<name>` when `publisher` is present;
- if supplying your own IRI, avoid schemes that point to other resources (`http(s)`, `file`, `ssh`);
- Python’s built-in HTTP server is fine for local testing, not production.

## GitHub-hosted private index workflow

Current docs point to a ready-made example repository:

- `https://github.com/sensmetry/sysand-private-index`

Use this when teams want private-index hosting with GitHub-managed access control and without running a dedicated server. Follow that repository README for the exact branch layout, CI flow, and URL/auth patterns.

## GitLab-hosted private index workflow

Current docs point to a ready-made example repository:

- `https://gitlab.com/sensmetry/public/sysand-private-index`

Use this when teams want private-index hosting through GitLab Pages and GitLab access control. Follow that repository README for exact pipeline, URL, and credential details.

## Authentication reminders

- Private indexes typically require `SYSAND_CRED_*` environment variables (basic or bearer).
- Match credential patterns narrowly to the exact index host/path.
- Keep token scopes minimal and separate read-only consume tokens from publish tokens.

## How to answer index questions well

When helping with private indexes:

- ask whether the user needs a one-off test index, a team-hosted index, or a CI-published index;
- separate index hosting from package building (`sysand build`) and dependency usage (`sysand add`);
- mention auth requirements when the index is private;
- mention `sysand.toml` when the user needs repeatable configuration rather than ad hoc flags.
