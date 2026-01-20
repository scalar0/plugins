#!/usr/bin/env bash
set -euo pipefail

export NO_COLOR=1
issue_id="${1:-}"

if [[ -z "$issue_id" || "$issue_id" == "null" ]]; then
  echo "No issue ID provided."
  exit 1
fi

gh issue view "$issue_id" --json body -q '.body'