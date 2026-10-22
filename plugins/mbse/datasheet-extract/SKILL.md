---
name: datasheet-extract
description: Extract structured JSON data from product datasheets and specification sheets using a jq-first pipeline. Use when a PDF or similar document must be converted into clean hierarchical JSON.
compatibility: Requires pdftotext or another readable first-pass extractor for page discovery, plus pdftohtml, xq, jq, and a shell environment.
---

# Datasheet Extract

## Overview

Use this skill when the goal is to turn a datasheet into structured JSON while keeping the extraction as deterministic as possible.

The workflow has three steps:

1. Locate the smallest relevant page range; record the search term used as `metadata.page_locator`.
2. Run the deterministic command-line extraction pipeline over only that range to produce the raw line-array JSON intermediate.
3. Reshape the line array into a hierarchical JSON document with snake_case keys, wrap it in the stable contract from `./assets/contract.schema.json`, and save as `<source_stem>-extract.json` next to the source file unless the user specifies otherwise.

The schema intentionally stabilizes the wrapper and provenance hooks while leaving the document-specific `data` payload flexible.

Prefer shell and `jq` for processing. Use the model for the last semantic shaping step instead of spending effort on an extra jq program.

Not suitable for scanned PDFs with no text layer or tasks where only a prose summary is needed.

## Canonical Pipeline

```bash
pdftotext -layout "$FILE" - | rg -ni 'specification|specifications|technical data|technical specifications|characteristics|parameters'

pdftohtml -l "$LAST" -f "$FIRST" -xml -stdout -i "$FILE" \
| xq --compact --no-color --json | jq -Mc -f ./assets/filter.jq
```

The output of this pipeline is the raw, model-facing intermediate representation. From there, produce the final contract-conformant JSON directly.

## Quality Gates

Before finishing, check that:

- the chosen page range is justified;
- only the relevant pages are extracted;
- the deterministic extraction pipeline is run as a single unmodified shell command, not reconstructed or approximated;
- `metadata.page_locator` is set to the search term used to find the relevant pages;
- all keys in the final JSON document use snake_case;
- the final JSON conforms to `./assets/contract.schema.json`;
- the final JSON reflects document structure rather than raw PDF layout noise.

## References

Load the smallest reference you need:

- `./references/locating-pages.md` — page discovery guidance
- `./references/final-json-shaping.md` — heuristics for constructing contract-conformant JSON from the line array
- `./assets/contract.schema.json` — machine-readable handoff contract for downstream skills
