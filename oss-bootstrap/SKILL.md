---
name: oss-bootstrap
description: Find existing open source repositories, components, libraries, or implementation examples that can bootstrap a user's requested feature or project by querying GitHub with the `gh` CLI. Use when the user asks whether an OSS repo already does something, wants to vendor or fork a component, needs reference implementations from trusted organizations, or asks to compare candidate repositories before building from scratch.
---

# OSS Bootstrap

Use this skill to turn a user demand into a short, evidence-backed shortlist of OSS repositories that can be reused, vendored, forked, or studied by querying GitHub through `gh`.

## Sources

- Read `assets/github.list` before searching unless the user names a different source set.
- Treat the list as preferred GitHub organizations, not an exhaustive boundary.
- Use `gh` as the primary discovery and inspection interface.
- Use package registries or project docs only as secondary verification after GitHub candidates are found.
- Avoid general web search for discovery; use it only when `gh` cannot answer a required verification question.

## Workflow

1. Restate the demand as capability keywords, ecosystem constraints, integration surface, and non-goals.
2. Confirm GitHub CLI access with `gh auth status` if commands fail or authentication is uncertain.
3. Query preferred organizations from `assets/github.list` with `gh repo list` or `gh api` and filter repos locally by name, description, topics, language, and activity.
4. Search GitHub globally with `gh search repos` only after checking the preferred organizations or when the user asks for ecosystem-wide coverage.
5. Inspect each candidate's README, license, release activity, issue activity, examples, API stability, and dependency footprint through `gh repo view`, `gh api`, and repository contents.
6. Prefer repos with permissive licenses, active maintenance, small reusable modules, documented APIs, tests, and examples close to the user's need.
7. Reject candidates that are stale, tightly coupled to a service, missing a compatible license, or too broad to vendor safely.
8. If the user's target codebase is available, inspect its language, package manager, architecture, and licensing before recommending vendoring or forking.
9. Present a ranked shortlist with direct links, reuse path, integration cost, license risk, and confidence.

## GH Query Patterns

Normalize entries from `assets/github.list` by removing the leading `@`.

List and filter organization repositories:

```bash
gh repo list ORG --limit 1000 --json name,nameWithOwner,description,url,primaryLanguage,repositoryTopics,licenseInfo,stargazerCount,pushedAt,isArchived --jq 'map(select((.name + " " + (.description // "") + " " + ((.repositoryTopics // []) | map(.name) | join(" "))) | test("CAPABILITY|KEYWORD"; "i")))'
```

Inspect a candidate:

```bash
gh repo view OWNER/REPO --json nameWithOwner,description,url,homepageUrl,licenseInfo,primaryLanguage,repositoryTopics,stargazerCount,forkCount,pushedAt,latestRelease,isArchived
gh api repos/OWNER/REPO/readme --jq '.content' | base64 --decode
gh api repos/OWNER/REPO/contents --jq '.[].name'
```

Check activity and maintenance:

```bash
gh issue list --repo OWNER/REPO --state open --limit 20 --json number,title,createdAt,updatedAt,labels
gh pr list --repo OWNER/REPO --state merged --limit 20 --json number,title,mergedAt
gh release list --repo OWNER/REPO --limit 10
```

Search all GitHub repositories only when needed:

```bash
gh search repos "CAPABILITY LANGUAGE_OR_FRAMEWORK" --owner ORG --limit 50 --json fullName,description,url,language,license,updatedAt
gh search repos "CAPABILITY LANGUAGE_OR_FRAMEWORK" --limit 50 --sort updated --json fullName,description,url,language,license,updatedAt
```

When a package ecosystem matters, also search package registries:

```text
npm <capability> <framework>
crates.io <capability>
pypi <capability>
maven <capability>
go package <capability>
```

## Recommendation Format

Use a compact table for candidates:

| Rank | Repo | Fit | Reuse path | License | Activity | Risk |
| ---- | ---- | --- | ---------- | ------- | -------- | ---- |

Follow the table with:

- `Best pick`: Name the strongest candidate and why.
- `Vendor/fork notes`: Mention files, packages, or modules to start from when known.
- `Gaps`: State what still needs implementation.
- `Verification`: List searches or docs checked.

## Guardrails

- Do not recommend copying code without checking license compatibility.
- Do not treat star count as evidence of technical fit.
- Do not hide uncertainty when a repo looks promising but was not deeply inspected.
- Ask for the target codebase path or license only when vendoring or forking would otherwise be risky.
- Prefer structured `gh --json` output over scraped text.
- Keep `gh` commands non-interactive and report authentication or rate-limit blockers explicitly.
