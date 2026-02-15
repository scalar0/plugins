#!/usr/bin/env python3
"""
Generate commit slice correlations from git diff hunks.

Outputs two CSVs in a target directory:
- hunks.csv: per-hunk metadata and diff text
- corr.csv: symmetric correlation matrix across files based on shared tokens

Designed to be deterministic and fast for local use.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple

WORD_RE = re.compile(r"[A-Za-z0-9_]{2,}")


@dataclass(frozen=True)
class Hunk:
    hunk_id: str
    file_path: str
    header: str
    diff: str
    token_set: Tuple[str, ...]


def run_git(args: Sequence[str], cwd: Path) -> str:
    result = subprocess.run(
        ["git", *args], cwd=cwd, text=True, capture_output=True, check=False
    )
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        sys.exit(result.returncode)
    return result.stdout


def git_root(cwd: Path) -> Path:
    return Path(run_git(["rev-parse", "--show-toplevel"], cwd=cwd).strip())


def collect_hunks(cwd: Path, diff_args: Sequence[str]) -> List[Hunk]:
    raw = run_git(["diff", "--patch", "--unified=3", *diff_args], cwd=cwd)
    lines = raw.splitlines()
    hunks: List[Hunk] = []
    file_path = None
    hunk_header = None
    hunk_lines: List[str] = []

    def flush_hunk():
        nonlocal hunk_header, hunk_lines
        if file_path and hunk_header is not None:
            diff_text = "\n".join(hunk_lines).strip("\n")
            tokens = tokenize(diff_text)
            if tokens:
                hunks.append(
                    Hunk(
                        hunk_id=hash_hunk(file_path, hunk_header, diff_text),
                        file_path=file_path,
                        header=hunk_header,
                        diff=diff_text,
                        token_set=tokens,
                    )
                )
        hunk_header = None
        hunk_lines = []

    for line in lines:
        if line.startswith("diff --git "):
            flush_hunk()
            file_path = None
            continue
        if line.startswith("+++ b/"):
            file_path = line[len("+++ b/") :].strip()
            continue
        if line.startswith("@@ "):
            flush_hunk()
            hunk_header = line.strip()
            hunk_lines = []
            continue
        if hunk_header is not None:
            if line.startswith("\\ No newline"):
                continue
            hunk_lines.append(line)
    flush_hunk()
    return hunks


def hash_hunk(file_path: str, header: str, diff_text: str) -> str:
    payload = f"{file_path}\n{header}\n{diff_text}".encode("utf-8")
    return hashlib.sha1(payload).hexdigest()[:12]


def tokenize(text: str) -> Tuple[str, ...]:
    tokens = {t.lower() for t in WORD_RE.findall(text)}
    return tuple(sorted(tokens))


def unique_files(hunks: Iterable[Hunk]) -> List[str]:
    return sorted({h.file_path for h in hunks})


def file_token_sets(hunks: Iterable[Hunk]) -> dict[str, set[str]]:
    tokens: dict[str, set[str]] = {}
    for hunk in hunks:
        bucket = tokens.setdefault(hunk.file_path, set())
        bucket.update(hunk.token_set)
    return tokens


def jaccard(a: set[str], b: set[str]) -> float:
    if not a and not b:
        return 1.0
    if not a or not b:
        return 0.0
    inter = a.intersection(b)
    union = a.union(b)
    return len(inter) / len(union)


def write_hunks_csv(path: Path, hunks: Sequence[Hunk]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["hunk_id", "file_path", "header", "diff", "tokens"])
        for h in hunks:
            writer.writerow(
                [h.hunk_id, h.file_path, h.header, h.diff, " ".join(h.token_set)]
            )


def write_corr_csv(
    path: Path, files: Sequence[str], token_sets: dict[str, set[str]]
) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["file", *files])
        for left in files:
            row = [left]
            for right in files:
                score = jaccard(
                    token_sets.get(left, set()), token_sets.get(right, set())
                )
                row.append(f"{score:.4f}")
            writer.writerow(row)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compute commit slice correlations")
    parser.add_argument(
        "--output",
        required=True,
        help="Output directory for CSV files",
    )
    parser.add_argument(
        "--staged",
        action="store_true",
        help="Use staged diff instead of working tree diff",
    )
    parser.add_argument(
        "--paths",
        nargs="*",
        default=[],
        help="Optional paths to limit diff scope",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    cwd = Path.cwd()
    repo_root = git_root(cwd)

    diff_args: List[str] = []
    if args.staged:
        diff_args.append("--cached")
    if args.paths:
        diff_args.append("--")
        diff_args.extend(args.paths)

    hunks = collect_hunks(repo_root, diff_args)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    write_hunks_csv(output_dir / "hunks.csv", hunks)

    files = unique_files(hunks)
    tokens = file_token_sets(hunks)
    write_corr_csv(output_dir / "corr.csv", files, tokens)

    print(f"Wrote {len(hunks)} hunks to {output_dir / 'hunks.csv'}")
    print(
        f"Wrote correlation matrix for {len(files)} files to {output_dir / 'corr.csv'}"
    )


if __name__ == "__main__":
    main()
