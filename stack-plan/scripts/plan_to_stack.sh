#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  plan_to_stack.sh --input <do-plan.json> --output <stack-plan.json>

Description:
  Deterministically transform a do-plan JSON file into a stack-plan JSON file
  that includes Graphite MCP command objects.
USAGE
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

input=""
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      input="${2:-}"
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

if [[ -z "$input" || -z "$output" ]]; then
  echo "error: --input and --output are required" >&2
  usage >&2
  exit 1
fi

require_command jq

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
transform_filter="$script_dir/transform_do_plan_to_stack.jq"

if [[ ! -f "$transform_filter" ]]; then
  echo "error: jq filter not found: $transform_filter" >&2
  exit 1
fi

if [[ ! -f "$input" ]]; then
  echo "error: input file not found: $input" >&2
  exit 1
fi

jq -e '
  type == "object"
  and (.title | type == "string")
  and (.executive_summary | type == "string")
  and (.high_level_approach | type == "string")
  and (.phases | type == "array")
' "$input" >/dev/null

tmp_output="$(mktemp)"
trap 'rm -f "$tmp_output"' EXIT

jq \
  -f "$transform_filter" \
  "$input" >"$tmp_output"

jq -e '.stack | type == "array" and length > 0' "$tmp_output" >/dev/null

mkdir -p "$(dirname "$output")"
mv "$tmp_output" "$output"
chmod 0644 "$output" 2>/dev/null || true

echo "wrote stack plan: $output"
