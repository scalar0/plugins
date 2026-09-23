---
name: oss-bootstrap
description: Find and compare open source repositories for a requested capability or reuse plan.
---

# OSS Bootstrap

Use the user's source set when supplied.
Consult [github.list](references/github.list) when preferred organizations can help narrow the search.
Use structured `gh` output for discovery and inspection, package registries or project docs for secondary verification, and general web search only when GitHub cannot answer a required question.

## Workflow

1. Restate the demand as capability keywords, ecosystem constraints, integration surface, and non-goals.
2. Confirm GitHub CLI access with `gh auth status` if commands fail or authentication is uncertain.
3. Select organization queries or global GitHub search based on the requested capability and available evidence.
4. Expand the search when the first candidates do not meet the user's constraints.
5. Inspect candidate README, license, releases, issues, merged PRs, examples, API stability, archive status, and dependency footprint.
6. Prefer repos with permissive licenses, active maintenance, small reusable modules, documented APIs, tests, and examples close to the user's need.
7. Inspect the target codebase's language, package manager, architecture, and license before recommending vendoring or forking.
8. Reject stale, service-coupled, incompatibly licensed, or excessively broad candidates.
9. Rank the remaining candidates by fit, reuse path, integration cost, license risk, activity, and confidence.

## GH Query Patterns

Normalize preferred organizations by removing the leading `@`.

```bash
gh repo list ORG --limit 1000 --json nameWithOwner,description,url,primaryLanguage,repositoryTopics,licenseInfo,pushedAt,isArchived
gh search repos "CAPABILITY LANGUAGE_OR_FRAMEWORK" --limit 50 --sort updated --json fullName,description,url,language,license,updatedAt
gh repo view OWNER/REPO --json nameWithOwner,description,url,homepageUrl,licenseInfo,primaryLanguage,repositoryTopics,stargazerCount,forkCount,pushedAt,latestRelease,isArchived
gh api repos/OWNER/REPO/readme --jq '.content' | base64 --decode
gh api repos/OWNER/REPO/contents --jq '.[].name'
gh issue list --repo OWNER/REPO --state open --limit 20 --json number,title,createdAt,updatedAt,labels
gh pr list --repo OWNER/REPO --state merged --limit 20 --json number,title,mergedAt
gh release list --repo OWNER/REPO --limit 10
```

## Recommendation Format

| Rank | Repo | Fit | Reuse path | License | Activity | Risk |
| ---- | ---- | --- | ---------- | ------- | -------- | ---- |

Follow the table with the best pick, concrete vendor or fork entry points, remaining gaps, and verification performed.

## Guardrails

- Do not recommend copying code without checking license compatibility.
- Do not treat star count as evidence of technical fit.
- Do not hide uncertainty when a repo looks promising but was not deeply inspected.
- Request target codebase or license context only when reuse would otherwise be risky.
- Keep commands non-interactive and report authentication or rate-limit blockers.
