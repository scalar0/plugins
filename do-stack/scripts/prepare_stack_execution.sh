#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  prepare_stack_execution.sh \
    --plan <stack-plan.json> \
    --output <execution.json>

Description:
  Compile a deterministic, executable do-stack manifest from stack-plan output.
USAGE
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

plan=""
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)
      plan="${2:-}"
      shift 2
      ;;
    --output)
      output="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$plan" || -z "$output" ]]; then
  echo "error: --plan and --output are required" >&2
  usage >&2
  exit 1
fi

require_command jq
require_command git

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
filter="$script_dir/compile_execution.jq"

if [[ ! -f "$filter" ]]; then
  echo "error: jq filter not found: $filter" >&2
  exit 1
fi
if [[ ! -f "$plan" ]]; then
  echo "error: plan file not found: $plan" >&2
  exit 1
fi
repo_root="$(git rev-parse --show-toplevel)"

jq -e '
  type == "object"
  and (.schema_version | type == "string")
  and (.source_plan | type == "object")
  and (.stack | type == "array" and length > 0)
  and (.execution | type == "object")
  and (.execution.preflight | type == "array")
' "$plan" >/dev/null

tmp_output="$(mktemp)"
trap 'rm -f "$tmp_output"' EXIT

jq \
  --arg repo_root "$repo_root" \
  -f "$filter" \
  "$plan" >"$tmp_output"

jq -e '
  .commands | type == "array" and length > 0
' "$tmp_output" >/dev/null

mkdir -p "$(dirname "$output")"
mv "$tmp_output" "$output"
chmod 0644 "$output" 2>/dev/null || true

echo "wrote execution manifest: $output"
