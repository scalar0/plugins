#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  resolve_jit_create_args.sh \
    --execution <execution.json> \
    --step-index <int> \
    --commit-message <message>

Description:
  Resolve a single stack create-step command by replacing its commit placeholder
  with a just-in-time commit message.
USAGE
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

execution=""
step_index=""
commit_message=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execution)
      execution="${2:-}"
      shift 2
      ;;
    --step-index)
      step_index="${2:-}"
      shift 2
      ;;
    --commit-message)
      commit_message="${2:-}"
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

if [[ -z "$execution" || -z "$step_index" || -z "$commit_message" ]]; then
  echo "error: --execution, --step-index, and --commit-message are required" >&2
  usage >&2
  exit 1
fi

if ! [[ "$step_index" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: --step-index must be a positive integer" >&2
  exit 1
fi

require_command jq

if [[ ! -f "$execution" ]]; then
  echo "error: execution file not found: $execution" >&2
  exit 1
fi

jq -e --argjson idx "$step_index" '
  type == "object"
  and (.commands | type == "array")
  and (.commands | length >= $idx)
' "$execution" >/dev/null

jq -e --argjson idx "$step_index" '
  .commands[$idx - 1] as $cmd
  | ($cmd.jit_commit_msg == true)
  and (($cmd.commit_message_placeholder // "") | type == "string" and length > 0)
' "$execution" >/dev/null

jq \
  --argjson idx "$step_index" \
  --arg msg "$commit_message" \
  '
  .commands[$idx - 1] as $cmd
  | {
      step_index: $cmd.step_index,
      pr_index: $cmd.pr_index,
      task_id: $cmd.task_id,
      task_name: $cmd.task_name,
      original_args: $cmd.args,
      resolved_args: (
        $cmd.args
        | map(
            if . == $cmd.commit_message_placeholder then
              $msg
            else
              .
            end
          )
      ),
      why: $cmd.why
    }
  ' "$execution"
