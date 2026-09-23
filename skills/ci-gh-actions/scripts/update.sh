#!/usr/bin/env bash

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing dependency: gh CLI" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Missing dependency: curl" >&2
  exit 1
fi

usage() {
  cat <<'USAGE'
Download every markdown file from GitHub docs actions workflow references.

Usage:
  ./update.sh [--output-dir PATH] [--include-index] [--dry-run]

Options:
  --output-dir PATH   Output folder for markdown files.
  --include-index     Also download index.md.
  -h, --help          Show this message.
USAGE
}

output_dir="ci-gh-actions/references/"
include_index=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      output_dir="$2"
      shift 2
      ;;
    --include-index)
      include_index=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$output_dir"

api_path="repos/github/docs/contents/content/actions/reference/workflows-and-actions"
jq_filter='.[] | select(.type=="file") | select(.name|endswith(".md"))'
if [[ "$include_index" == "false" ]]; then
  jq_filter+=' | select(.name!="index.md")'
fi
jq_filter+=' | "\(.name)\t\(.download_url)"'

mapfile -t items < <(
  gh api "$api_path" --paginate --jq "$jq_filter"
)

if [[ ${#items[@]} -eq 0 ]]; then
  echo "No markdown files found."
  exit 0
fi

count=0
for item in "${items[@]}"; do
  name="${item%%$'\t'*}"
  url="${item#*$'\t'}"

  echo "Downloading $name..."
  curl --fail --silent --show-error --location "$url" -o "$output_dir/$name"
  count=$((count + 1))
done

echo "Downloaded $count files into $(realpath "$output_dir")."
