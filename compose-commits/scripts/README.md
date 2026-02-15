# Commit Slice Correlations

This tool computes a deterministic correlation matrix between files using tokens
from git diff hunks. It helps group related changes into commit slices.

## Usage

Working tree diff:

```
uv run python tools/commit-slices/commit_slices.py --output /tmp/commit-slices
```

Staged diff:

```
uv run python tools/commit-slices/commit_slices.py --output /tmp/commit-slices --staged
```

Limit to paths:

```
uv run python tools/commit-slices/commit_slices.py --output /tmp/commit-slices --paths crates/vcs specs
```

## Output

- `hunks.csv`: each diff hunk with tokens extracted from the diff lines.
- `corr.csv`: symmetric Jaccard correlation matrix across files.

Use `xan` to explore the matrix, for example:

```
xan view /tmp/commit-slices/corr.csv
xan heatmap /tmp/commit-slices/corr.csv
```

## Notes

- Tokens are alphanumeric/underscore sequences of length >=2.
- Correlations are based on token overlap by file.
- If no hunks exist, the tool still writes empty CSV headers.
