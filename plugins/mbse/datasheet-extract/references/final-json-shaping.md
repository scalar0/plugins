# Final JSON shaping

## Purpose

Build the final JSON object directly from the line array produced by `../assets/filter.jq`, using snake_case for every JSON key, then wrap it in the contract defined by `../assets/contract.schema.json`.

## Line array structure

Each entry from `filter.jq` has the shape:

```json
{"page":3,"line_pos":142,"heading":false,"text":["Ethernet Interface","1 × RJ45 100 M self-adaptive"]}
{"page":3,"line_pos":158,"heading":true, "text":["Interface & I/O"]}
{"page":3,"line_pos":174,"heading":false,"text":["Weight","0.35"]}
```

Fields:
- `page` — source page number
- `line_pos` — vertical position in PDF units; lines sharing the same `line_pos` are already merged into one entry
- `heading` — `true` only when the line is a single bold token; treat as a conservative signal (see below)
- `text` — left-to-right ordered array of text fragments across the line

Numeric-looking strings are already converted to numbers by `normalize_scalar`; do not re-stringify them.

## Common strategy

1. Work from the line array directly.
2. Treat `heading == true` as a section boundary candidate.
3. Use the ordered `text` array to infer label/value patterns.
4. Merge multiline continuations across nearby lines in the same section.
5. Build the final nested `data` object with snake_case keys.
6. Wrap that `data` object in the contract.

## Label/value detection

When `text` has two or more elements: `text[0]` is the label, `text[1..]` are value fragments — join them with a space if there are more than one.

When `text` has one element and the previous line was a section heading: treat it as a sub-label or continuation, not a standalone value.

## Heading heuristic limitation

`heading: true` only fires for a single-token bold line. Multi-word headings or sections not printed in bold will be `heading: false`. Supplement with:

- left-alignment (`left` near the document's leftmost margin)
- a vertical gap larger than the median line spacing above the line

Use these corroborating signals to promote additional `heading: false` lines to section boundaries when `heading: true` alone misses them.

## Multi-column tables

`filter.jq` sorts by `(page, top, left)`, so cells at the same `top` from a two-column layout are adjacent in `text`. Treat `text[0]` as the left-column label and `text[1]` as the right-column value — the same as the standard label/value case.

## Noise filtering

Before shaping, discard lines where:

- `text[0]` matches a bare page-number pattern (`^\d+$` or `^-\s*\d+\s*-$`)
- the same string appears at the same `line_pos` on every page (repeated header or footer)
- `text` contains only a copyright notice, document number, or revision marker

Do not include these lines in `data`.
