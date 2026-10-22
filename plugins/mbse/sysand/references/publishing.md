# Publishing with Sysand

## When to use this reference

Use this reference when the task involves:

- building a `.kpar` archive for distribution;
- publishing to a Sysand-compatible package index;
- preparing project metadata for public consumption;
- troubleshooting publish-time validation/auth errors.

## Build before publish

For normal packaging:

1. Ensure project metadata and source files are ready.
2. Ensure relevant `.sysml` / `.kerml` files are included in project metadata.
3. Run `sysand build`.
4. Expect a `.kpar` file under `output/` unless a custom path is used.

Important behavior:

- if a `README.md` exists at the project root, `sysand build` includes it in the `.kpar` archive;
- `sysand build` can operate on a project or, from a workspace root, build all workspace projects;
- using `file://` usages may reduce portability unless the user explicitly accepts that tradeoff.

## Direct publish command

Use:

- `sysand publish --index <URL>`
- or `sysand publish --index <URL> [PATH]`

Important rules from current docs:

- the package must already be built;
- `--index` is required;
- publish authentication requires bearer-token credentials (`SYSAND_CRED_<X>_BEARER_TOKEN`);
- `--index` may point to an index root (for example `https://sysand.com`) or directly to an API root (for example `https://my-index.example.com/api`).

## Metadata checklist for publishing

Before recommending publish, check or mention these fields in `.project.json`:

- `publisher`
- `name`
- `version`
- `license`
- optional but recommended: `description`, `maintainer`, `website`, `topic`, `metamodel`

Documented validation rules include:

- `publisher`: 3-50 chars; ASCII letters/digits, optional single spaces/hyphens between words; starts/ends alphanumeric;
- `name`: 3-50 chars; ASCII letters/digits, optional single spaces/hyphens/dots between words; starts/ends alphanumeric;
- `version`: valid SemVer 2.0 version;
- `license`: valid SPDX license expression.

Useful metadata commands:

- `sysand info name --set <NAME>`
- `sysand info description --set <DESCRIPTION>`
- `sysand info version --set <VERSION>`
- `sysand info license --set <SPDX LICENSE EXPRESSION>`
- `sysand info maintainer --add <MAINTAINER>`
- `sysand info website --set <WEBSITE>`
- `sysand info topic --add <TOPIC>`
- `sysand info metamodel --set <kerml|sysml> --release <YYYYMMDD>`

## Authentication for publishing

For `sysand publish`, docs explicitly call out bearer-token credentials.

Pattern:

- `SYSAND_CRED_<X>=<PATTERN>`
- `SYSAND_CRED_<X>_BEARER_TOKEN=<TOKEN>`

Guidance:

- if no matching bearer token is configured for the publish URL, the command fails before upload;
- start with least-privilege token scopes;
- keep read/install tokens separate from publish tokens.

## Sysand Index targets

For a first release, recommend trial publishing to test index first:

- test: `https://test.sysand.com`
- production: `https://sysand.com`

Key behavior to mention:

- versions are immutable once published;
- if a bad version is published, recovery is to publish a fixed new version.

## How to answer publishing questions well

When helping with publishing:

- distinguish between building a package and publishing it;
- verify metadata readiness before suggesting upload;
- mention auth prerequisites early, especially for CI or private indexes;
- clarify whether the user targets test index, production index, or a private company index.
