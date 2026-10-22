# Locating relevant pages

## Goal

Find the smallest page span that contains the structured data of interest, usually a specification table.

## Typical headings

Search for headings such as:

- `Specification`
- `Specifications`
- `Technical Data`
- `Technical Specifications`
- `Characteristics`
- `Parameters`
- `General`
- `Interface`
- `Features`
- close document-language synonyms

## Preferred first pass

Run the `pdftotext | rg` command from the canonical pipeline in `../SKILL.md` first. If the hit list is noisy, inspect likely pages individually:

```bash
pdftotext -layout -f "$PAGE" -l "$PAGE" "$FILE" -
```

## Selection rule

- Look for actual specification pages over cover pages or marketing summaries.
- If several specification blocks exist, either extract them separately or state the chosen scope.
- Choose the smallest contiguous page range that contains the structured table or tables required for the task.
