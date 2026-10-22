# Sysand authentication

## When to use this reference

Use this reference when the task involves:

- private indexes;
- authenticated downloads of project sources or KPAR files;
- publishing to an index;
- GitHub or GitLab private index access;
- enterprise environments where credentials must be scoped carefully.

## Supported auth modes in the docs

At the time documented, Sysand supports:

- HTTP(S) basic authentication;
- HTTP(S) fixed bearer tokens;
- Git authentication through standard git configuration, SSH keys, and credential helpers when git is used.

The docs also note that some auth modes are planned but not yet supported. Do not claim support beyond what is documented.

## Environment variable patterns

### Basic authentication

Use:

- `SYSAND_CRED_<X>=<PATTERN>`
- `SYSAND_CRED_<X>_BASIC_USER=<USER>`
- `SYSAND_CRED_<X>_BASIC_PASS=<PASSWORD>`

### Bearer token authentication

Use:

- `SYSAND_CRED_<X>=<PATTERN>`
- `SYSAND_CRED_<X>_BEARER_TOKEN=<TOKEN>`

Where:

- `<X>` is an arbitrary label;
- `<PATTERN>` is a glob-like URL matcher.

## Pattern matching behavior

The docs describe wildcard matching like this:

- `?` matches any single character other than `/`;
- `*` matches any sequence of characters not containing `/`;
- `**` matches any sequence of characters, including `/`.

Behavior to remember:

- credentials are only sent to URLs matching the configured pattern;
- even for matching URLs, Sysand normally first tries an unauthenticated request and only sends credentials when the response is in the 4xx range;
- redirects are a special case: if credentials are sent and the host stays the same, credentials may also be sent to the redirected URL.

## Enterprise-safe guidance

When answering auth questions for private or enterprise environments:

- prefer the narrowest possible pattern instead of broad wildcards;
- recommend least-privilege tokens;
- separate read-only consumer tokens from publish/upload tokens;
- avoid suggesting credentials embedded directly in URLs unless the user explicitly needs that and accepts the risk;
- do not invent Sysand-specific secret stores or config-file credential support if it is not in the docs.

## GitHub and GitLab private index access

Current hosting guidance points to reference repositories for GitHub/GitLab private-index setups. Exact URLs and matcher patterns depend on how those templates are configured.

Use these rules:

- derive credential patterns from the exact index URL users configure in `--index` / `--default-index`;
- keep patterns host-and-path specific (for example `https://host.example.com/path/**`, not `https://**`);
- prefer bearer tokens unless the hosting setup explicitly requires basic auth.

## Publishing reminder

For `sysand publish`, the docs explicitly say that bearer-token credentials are used.
If no matching bearer token is configured for the publish URL, publishing fails before making the upload request.

## How to answer authentication questions well

- identify whether the user is downloading, resolving from an index, cloning a git source, or publishing;
- map the scenario to basic auth, bearer token, or git-native auth;
- explain the URL pattern carefully, because over-broad patterns create unnecessary credential exposure;
- if the user asks for unsupported schemes, say that the docs do not describe support for them.
