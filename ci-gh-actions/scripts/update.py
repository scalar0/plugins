#!/usr/bin/env python3
"""Download every workflow reference markdown file except index.md."""

from __future__ import annotations

import argparse
import json
import sys
import textwrap
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

API_URL = "https://api.github.com/repos/github/docs/contents/content/actions/reference/workflows-and-actions"


def fetch_markdown_entries(include_index: bool = False):
    request = Request(API_URL, headers={"Accept": "application/vnd.github+json"})
    with urlopen(request, timeout=15) as response:
        entries = json.load(response)

    for entry in entries:
        if entry.get("type") != "file":
            continue
        name = entry.get("name", "")
        if not name.endswith(".md"):
            continue
        if not include_index and name == "index.md":
            continue
        yield entry


def download_entry(entry: dict, output_dir: Path) -> Path:
    url = entry["download_url"]
    name = entry["name"]
    destination = output_dir / name
    request = Request(url)
    with urlopen(request, timeout=15) as response:
        destination.write_bytes(response.read())
    return destination


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=textwrap.dedent(
            """
            Download every markdown file from the GitHub docs Actions workflow reference
            except index.md (unless --include-index is supplied).
            """
        )
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        type=Path,
        default=Path("workflows-and-actions"),
        help="Directory where downloaded markdown files will be saved.",
    )
    parser.add_argument(
        "--include-index",
        action="store_true",
        help="Also download index.md (disabled by default to match the request).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List the files that would be downloaded but do not write them.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    output_dir = args.output_dir
    if not args.dry_run:
        output_dir.mkdir(parents=True, exist_ok=True)

    try:
        entries = list(fetch_markdown_entries(include_index=args.include_index))
    except (HTTPError, URLError) as exc:
        print(f"Failed to list files: {exc}", file=sys.stderr)
        return 1
    if not entries:
        print("No markdown files found.")
        return 0

    for entry in entries:
        name = entry["name"]
        if args.dry_run:
            print(f"Would download: {name}")
            continue
        print(f"Downloading {name}...")
        try:
            path = download_entry(entry, output_dir)
            print(f"Saved to {path}")
        except (HTTPError, URLError) as exc:
            print(f"Failed to download {name}: {exc}", file=sys.stderr)
            return 1

    print(f"Downloaded {len(entries)} files into {output_dir.resolve()}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
