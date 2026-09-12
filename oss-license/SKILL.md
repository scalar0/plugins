---
name: oss-license
description: Compare open source licenses or assess a project's license choice.
---

# OSS License

Treat guidance as informational, not legal advice.
Use [the OSI license list](https://opensource.org/licenses) for approval status, canonical names, and SPDX IDs, then read the [OSI license guide](references/osi-license-guide.md) for the decision matrix, compatibility checks, implementation, and legal-review triggers.

## Workflow

1. Identify project goals: permissive adoption, reciprocal sharing, SaaS/network reciprocity, patent protection, public-domain-style dedication, hardware, fonts, data, or documentation.
2. Inspect the project when a workspace is available: existing `LICENSE`, package metadata, dependency licenses, contribution policy, company ownership, and target ecosystem norms.
3. Resolve only missing high-impact constraints: proprietary downstream use, network distribution, patents, commercial goals, and compatibility.
4. Shortlist common OSI-approved licenses unless the artifact or goal requires a special-purpose option.
5. Explain downstream obligations plainly, flag counsel or owner decisions, and provide the SPDX ID plus canonical text.

## Recommendation Shape

Use a compact table when comparing options:

| License | SPDX ID | Best for | Main tradeoff | Fit |
| ------- | ------- | -------- | ------------- | --- |

After the table, give the recommendation, only meaningful rejected alternatives, required `LICENSE` and metadata changes, and legal-review facts.

## Guardrails

- Do not recommend a non-OSI license when the user asks for open source unless you explicitly label it as not OSI-approved.
- Check dependency compatibility when relevant and identify contributor or ownership implications before relicensing.
- Prefer a current common license over deprecated or superseded variants.
