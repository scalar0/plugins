---
name: oss-license
description: Help choose an OSI-approved open source license for a software project. Use when the user asks which license to use, wants to compare permissive, weak copyleft, strong copyleft, network copyleft, patent-protective, public-domain-style, or special-purpose OSS licenses, needs SPDX identifiers, wants LICENSE file guidance, or needs licensing tradeoffs for publishing, vendoring, forking, or dual-licensing a project.
---

# OSS License

Use this skill to recommend an open source license choice with explicit tradeoffs, OSI approval status, and clear uncertainty boundaries.

This skill is not legal advice.

## Primary Source

- Use <https://opensource.org/licenses> as the baseline source for OSI-approved licenses, license names, SPDX IDs, and OSI categories.
- Read `references/osi-license-guide.md` when choosing or comparing licenses.
- Check current OSI pages before finalizing advice when the user asks about a license not covered in the reference.

## Workflow

1. Identify project goals: permissive adoption, reciprocal sharing, SaaS/network reciprocity, patent protection, public-domain-style dedication, hardware, fonts, data, or documentation.
2. Inspect the project when a workspace is available: existing `LICENSE`, package metadata, dependency licenses, contribution policy, company ownership, and target ecosystem norms.
3. Ask only for missing high-impact constraints: commercial use expectations, patent concerns, whether downstream proprietary use should be allowed, whether hosted-service modifications should be shared, and whether compatibility with an existing project matters.
4. Load `references/osi-license-guide.md` and shortlist licenses that fit the goals.
5. Prefer common OSI-approved licenses with strong ecosystem recognition unless the project has a concrete reason for a special-purpose license.
6. Explain obligations for users and downstreams in plain language.
7. Flag legal-review cases instead of overconfidently resolving them.
8. Provide the SPDX ID and point to the canonical OSI page or SPDX text for the selected license.

## Recommendation Shape

Use a compact table when comparing options:

| License | SPDX ID | Best for | Main tradeoff | Fit |
| ------- | ------- | -------- | ------------- | --- |

Then provide:

- `Recommendation`: Name the best license and why.
- `Why not the others`: Mention only meaningful alternatives.
- `Implementation`: State the `LICENSE` file and package metadata changes to make.
- `Legal review`: List any facts that need counsel or project-owner approval.

## Guardrails

- Do not present licensing guidance as legal advice.
- Do not recommend a non-OSI license when the user asks for open source unless you explicitly label it as not OSI-approved.
- Do not assume dependency license compatibility without checking the dependency set when compatibility matters.
- Do not replace a project's existing license without calling out contributor and ownership implications.
- Do not use deprecated or superseded licenses when a modern popular equivalent fits.
