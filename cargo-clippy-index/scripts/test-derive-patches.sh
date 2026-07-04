#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
justfile="$script_dir/Justfile"
workspace="$(mktemp -d)"
trap 'rm -rf "$workspace"' EXIT

write_jsonl() {
  local root="$1"
  local package="$2"
  local file_name="$3"
  local source="$4"
  local applicability="$5"
  local replacements_json="$6"

  mkdir -p "$root/.codex-clippy-index/raw"
  jq -cn \
    --arg file_name "$file_name" \
    --arg source "$source" \
    --arg applicability "$applicability" \
    --argjson replacements "$replacements_json" \
    '{
      reason: "compiler-message",
      message: {
        level: "warning",
        code: {code: "clippy::uninlined_format_args"},
        message: "variables can be used directly in the format string",
        spans: [
          {
            file_name: $file_name,
            line_start: 1,
            is_primary: true,
            text: [{text: $source}]
          }
        ],
        children: [
          {
            message: "use inline format args",
            spans: (
              $replacements
              | map({
                  file_name: .file,
                  byte_start: .start,
                  byte_end: .end,
                  suggested_replacement: .replacement,
                  suggestion_applicability: $applicability
                })
            )
          }
        ]
      }
    }' > "$root/.codex-clippy-index/raw/$package.jsonl"
}

new_case() {
  local name="$1"
  local root="$workspace/$name"
  mkdir -p "$root/src"
  printf '%s\n' "$root"
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"
  if [[ "$expected" != "$actual" ]]; then
    printf 'assertion failed: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

patch_status() {
  jq -r '.patches[0].status' "$1/.codex-clippy-index/index.json"
}

patch_reason() {
  jq -r '.patches[0].reason // ""' "$1/.codex-clippy-index/index.json"
}

patch_id() {
  jq -r '.patches[0].id // ""' "$1/.codex-clippy-index/index.json"
}

patch_path() {
  jq -r '.patches[0].path // ""' "$1/.codex-clippy-index/index.json"
}

run_index() {
  just -f "$justfile" index-json "$1" >/dev/null
}

test_single_replacement() {
  local root source needle start end path id git_id
  root="$(new_case single)"
  git -C "$root" init >/dev/null
  source='fn main() { println!("{}", value); }'
  needle='"{}"'
  printf '%s\n' "$source" > "$root/src/lib.rs"
  start="${source%%$needle*}"
  start="${#start}"
  end=$((start + 4))
  write_jsonl "$root" demo src/lib.rs "$source" MachineApplicable \
    "[{\"file\":\"src/lib.rs\",\"start\":$start,\"end\":$end,\"replacement\":\"\\\"{value}\\\"\"}]"

  run_index "$root"

  assert_eq written "$(patch_status "$root")" "single replacement status"
  path="$(patch_path "$root")"
  git -C "$root" apply --check "$root/$path"
  id="$(patch_id "$root")"
  git_id="$(git patch-id --stable < "$root/$path" | cut -d' ' -f1)"
  assert_eq "$git_id" "$id" "patch id uses git patch-id"
}

test_multi_span_same_file() {
  local root source first second patch
  root="$(new_case multi)"
  source='fn demo() { let a = 1; let b = 2; }'
  printf '%s\n' "$source" > "$root/src/lib.rs"
  first="${source%%let a*}"
  first="${#first}"
  second="${source%%let b*}"
  second="${#second}"
  write_jsonl "$root" demo src/lib.rs "$source" MachineApplicable \
    "[{\"file\":\"src/lib.rs\",\"start\":$first,\"end\":$((first + 5)),\"replacement\":\"let alpha\"},{\"file\":\"src/lib.rs\",\"start\":$second,\"end\":$((second + 5)),\"replacement\":\"let beta\"}]"

  run_index "$root"

  assert_eq written "$(patch_status "$root")" "multi replacement status"
  patch="$root/$(patch_path "$root")"
  grep -q 'let alpha' "$patch"
  grep -q 'let beta' "$patch"
}

test_non_machine_applicable_skip() {
  local root source
  root="$(new_case non-machine)"
  source='fn demo() {}'
  printf '%s\n' "$source" > "$root/src/lib.rs"
  write_jsonl "$root" demo src/lib.rs "$source" MaybeIncorrect \
    '[{"file":"src/lib.rs","start":0,"end":2,"replacement":"pub fn"}]'

  run_index "$root"

  assert_eq skipped "$(patch_status "$root")" "non-machine status"
  assert_eq non-machine-applicable "$(patch_reason "$root")" "non-machine reason"
}

test_overlapping_span_skip() {
  local root source
  root="$(new_case overlap)"
  source='abcdef'
  printf '%s\n' "$source" > "$root/src/lib.rs"
  write_jsonl "$root" demo src/lib.rs "$source" MachineApplicable \
    '[{"file":"src/lib.rs","start":0,"end":3,"replacement":"ABC"},{"file":"src/lib.rs","start":2,"end":4,"replacement":"CD"}]'

  run_index "$root"

  assert_eq skipped "$(patch_status "$root")" "overlap status"
  assert_eq overlapping-spans "$(patch_reason "$root")" "overlap reason"
}

test_missing_file_skip() {
  local root
  root="$(new_case missing)"
  write_jsonl "$root" demo src/lib.rs 'fn demo() {}' MachineApplicable \
    '[{"file":"src/lib.rs","start":0,"end":2,"replacement":"pub fn"}]'

  run_index "$root"

  assert_eq skipped "$(patch_status "$root")" "missing-file status"
  assert_eq missing-file "$(patch_reason "$root")" "missing-file reason"
}

test_stable_patch_id() {
  local root source needle start end first second
  root="$(new_case stable)"
  source='fn main() { println!("{}", value); }'
  needle='"{}"'
  printf '%s\n' "$source" > "$root/src/lib.rs"
  start="${source%%$needle*}"
  start="${#start}"
  end=$((start + 4))
  write_jsonl "$root" demo src/lib.rs "$source" MachineApplicable \
    "[{\"file\":\"src/lib.rs\",\"start\":$start,\"end\":$end,\"replacement\":\"\\\"{value}\\\"\"}]"

  run_index "$root"
  first="$(patch_id "$root")"
  run_index "$root"
  second="$(patch_id "$root")"

  assert_eq "$first" "$second" "stable patch id"
}

test_single_replacement
test_multi_span_same_file
test_non_machine_applicable_skip
test_overlapping_span_skip
test_missing_file_skip
test_stable_patch_id

printf 'derive-patches tests passed\n'
