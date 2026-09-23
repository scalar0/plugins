#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CLIPPY_INDEX_LIBRARY=1
# shellcheck source=clippy-index.sh
source "$script_dir/clippy-index.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() { printf 'test failure: %s\n' "$*" >&2; exit 1; }
assert_eq() { [[ "$1" == "$2" ]] || fail "$3: expected '$1', got '$2'"; }
expect_scan_failure() {
  local root="$1" config="${2:-}" mode="${3:-strict}"
  if CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" scan "$root" "$config" "$mode" >/dev/null 2>&1; then fail "scan unexpectedly succeeded: $root"; fi
}

write_case() {
  local name="$1" source="$2" children="$3" root stage
  root="$tmp/$name"; stage="$tmp/$name-stage"
  mkdir -p "$root/src" "$stage/raw"
  printf '%s' "$source" > "$root/src/lib.rs"
  jq -S -n '{reproducible:false}' > "$stage/plan.json"
  jq -cn --argjson children "$children" '{
    package:"demo",package_id:"demo@0.1.0",target:{name:"demo",kind:["lib"]},
    message:{reason:"compiler-message",message:{level:"warning",code:{code:"clippy::demo"},message:"demo warning",spans:[{file_name:"src/lib.rs",byte_start:0,byte_end:1,line_start:1,column_start:1,is_primary:true}],children:$children}}
  }' > "$stage/raw/demo.annotated.json"
  derive_artifacts "$root" "$stage" test-run
  printf '%s\n' "$stage"
}

child() {
  jq -cn --arg applicability "${1:-MachineApplicable}" --argjson spans "$2" '[{message:"suggestion",spans:($spans|map(.+{suggestion_applicability:$applicability}))}]'
}

span() {
  jq -cn --arg path "$1" --argjson start "$2" --argjson end "$3" --arg replacement "$4" '{file_name:$path,byte_start:$start,byte_end:$end,suggested_replacement:$replacement}'
}

run_golden_tests() {
  local stage spans children status reason patch
  spans="$(jq -sn --argjson a "$(span src/lib.rs 0 2 pub)" '[$a]')"
  stage="$(write_case single 'fn main() {}' "$(child MachineApplicable "$spans")")"
  assert_eq included "$(jq -r '.suggestions[0].status' "$stage/index.json")" 'single span'

  spans="$(jq -sn --argjson a "$(span src/lib.rs 0 2 pub)" --argjson b "$(span src/lib.rs 3 7 test)" '[$a,$b]')"
  stage="$(write_case multi 'fn demo() {}' "$(child MachineApplicable "$spans")")"
  assert_eq included "$(jq -r '.suggestions[0].status' "$stage/index.json")" 'multi span'

  spans="$(jq -sn --argjson a "$(span src/lib.rs 0 2 '')" '[$a]')"
  stage="$(write_case deletion 'fn main() {}' "$(child MachineApplicable "$spans")")"
  assert_eq included "$(jq -r '.suggestions[0].status' "$stage/index.json")" deletion

  spans="$(jq -sn --argjson a "$(span src/lib.rs 0 2 fn)" '[$a]')"
  stage="$(write_case noop 'fn main() {}' "$(child MachineApplicable "$spans")")"
  assert_eq no-op-suggestion "$(jq -r '.suggestions[0].skip_reason' "$stage/index.json")" no-op

  children="$(child MachineApplicable "$(jq -sn --argjson a "$(span src/lib.rs 0 2 pub)" '[$a]')")"
  children="$(jq -cn --argjson a "$children" '$a+$a')"
  stage="$(write_case duplicate 'fn main() {}' "$children")"
  assert_eq 1 "$(jq '.suggestions|length' "$stage/index.json")" 'duplicate collapse'
  assert_eq 2 "$(jq '.suggestions[0].occurrences' "$stage/index.json")" 'duplicate occurrences'

  spans="$(jq -sn --argjson a "$(span src/lib.rs 0 3 aaa)" --argjson b "$(span src/lib.rs 2 4 bb)" '[$a,$b]')"
  stage="$(write_case overlap abcdef "$(child MachineApplicable "$spans")")"
  assert_eq conflicting-suggestion "$(jq -r '.suggestions[0].skip_reason' "$stage/index.json")" overlap

  children="$(jq -sn --argjson a "$(child MachineApplicable "$(jq -sn --argjson s "$(span src/lib.rs 0 2 aa)" '[$s]')")" --argjson b "$(child MachineApplicable "$(jq -sn --argjson s "$(span src/lib.rs 0 2 bb)" '[$s]')")" '$a+$b')"
  stage="$(write_case conflict 'fn main() {}' "$children")"
  assert_eq 2 "$(jq '[.suggestions[]|select(.skip_reason=="conflicting-suggestion")]|length' "$stage/index.json")" conflict

  for spec in 'missing:missing.rs:0:1:missing-file' 'range:src/lib.rs:0:99:byte-span-out-of-range' 'traversal:../lib.rs:0:1:invalid-suggestion-path'; do
    IFS=: read -r name path start end reason <<< "$spec"
    spans="$(jq -sn --argjson a "$(span "$path" "$start" "$end" x)" '[$a]')"
    stage="$(write_case "$name" 'fn main() {}' "$(child MachineApplicable "$spans")")"
    assert_eq "$reason" "$(jq -r '.suggestions[0].skip_reason' "$stage/index.json")" "$name"
  done

  stage="$tmp/nonutf-stage"; mkdir -p "$tmp/nonutf/src" "$stage/raw"; printf '\xff' > "$tmp/nonutf/src/lib.rs"; jq -n '{reproducible:false}' > "$stage/plan.json"
  children="$(child MachineApplicable "$(jq -sn --argjson a "$(span src/lib.rs 0 1 x)" '[$a]')")"
  jq -cn --argjson children "$children" '{package:"demo",package_id:"demo@0.1.0",target:{name:"demo",kind:["lib"]},message:{reason:"compiler-message",message:{level:"warning",code:{code:"clippy::demo"},message:"demo",spans:[],children:$children}}}' > "$stage/raw/demo.annotated.json"
  derive_artifacts "$tmp/nonutf" "$stage" test-run
  assert_eq non-utf8-file "$(jq -r '.suggestions[0].skip_reason' "$stage/index.json")" non-UTF-8

}

make_workspace() {
  local root="$1"
  mkdir -p "$root/src"
  printf '[package]\nname = "demo"\nversion = "0.1.0"\nedition = "2021"\n' > "$root/Cargo.toml"
  printf '# This file is automatically @generated by Cargo.\n# It is not intended for manual editing.\nversion = 4\n\n[[package]]\nname = "demo"\nversion = "0.1.0"\n' > "$root/Cargo.lock"
  printf 'fn main() { let value = 1; println!("{}", value); }\n' > "$root/src/main.rs"
  git -C "$root" init -q
  git -C "$root" add Cargo.toml Cargo.lock src/main.rs
}

run_integration_tests() {
  local one="$tmp/location-one" two="$tmp/location-two" strict="$tmp/strict" relaxed_no_git="$tmp/relaxed-no-git" id_one id_two before after release run patch_backup todo_backup config current_link
  make_workspace "$one"; make_workspace "$two"
  id_one="$(scan "$one" '' relaxed)"; id_two="$(scan "$two" '' relaxed)"
  assert_eq "$id_one" "$id_two" 'absolute-directory independence'
  verify "$one" current >/dev/null
  before="$(artifact_digest "$one/.codex-clippy-index/current" | sha_text)"
  report "$one" current residuals >/dev/null; report "$one" current patch >/dev/null; report "$one" current todo >/dev/null; report "$one" current status >/dev/null
  after="$(artifact_digest "$one/.codex-clippy-index/current" | sha_text)"
  assert_eq "$before" "$after" 'reports are read-only'
  assert_eq "$id_one" "$(scan "$one" '' relaxed)" 'matching run reuse'
  if rg -a -F "$one" "$one/.codex-clippy-index/current"/{plan.json,status.json,index.json,todo.tsv,patch.json,machine-applicable.patch} >/dev/null; then fail 'canonical artifact contains absolute workspace path'; fi

  todo_backup="$tmp/todo-backup"; cp "$two/.codex-clippy-index/current/todo.tsv" "$todo_backup"; current_link="$(readlink "$two/.codex-clippy-index/current")"
  printf 'corrupt\n' >> "$two/.codex-clippy-index/current/todo.tsv"
  if CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" scan "$two" '' relaxed >/dev/null 2>&1; then fail 'canonical conflict was reused'; fi
  assert_eq "$current_link" "$(readlink "$two/.codex-clippy-index/current")" 'conflict changed current'
  [[ -d "$two/.codex-clippy-index/conflicts/$id_two" ]] || fail 'conflicting output was not quarantined'
  cp "$todo_backup" "$two/.codex-clippy-index/current/todo.tsv"

  make_workspace "$tmp/failed"
  printf 'fn main( {\n' > "$tmp/failed/src/main.rs"
  git -C "$tmp/failed" add src/main.rs
  if CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" scan "$tmp/failed" '' relaxed > "$tmp/failed-id" 2>/dev/null; then fail 'failed package scan returned success'; fi
  [[ ! -e "$tmp/failed/.codex-clippy-index/current" ]] || fail 'failed scan updated current'
  [[ -s "$tmp/failed-id" ]] || fail 'failed scan did not print a run ID'

  make_workspace "$strict"
  release="$(rustc -vV | sed -n 's/^release: //p')"
  printf '[toolchain]\nchannel = "%s"\n' "$release" > "$strict/rust-toolchain.toml"
  git -C "$strict" add rust-toolchain.toml
  run="$(scan "$strict" '' strict)"
  assert_eq true "$(jq -r '.reproducible' "$strict/.codex-clippy-index/runs/$run/plan.json")" 'strict reproducibility'

  make_workspace "$relaxed_no_git"; rm -rf "$relaxed_no_git/.git"; rm "$relaxed_no_git/Cargo.lock"
  run="$(scan "$relaxed_no_git" '' relaxed)"
  assert_eq false "$(jq -r '.reproducible' "$relaxed_no_git/.codex-clippy-index/runs/$run/plan.json")" 'non-Git relaxed reproducibility'
  jq -e '.relaxation_reasons | index("git-worktree-unavailable") and index("missing-Cargo.lock")' "$relaxed_no_git/.codex-clippy-index/runs/$run/plan.json" >/dev/null || fail 'relaxed provenance is incomplete'
  [[ ! -e "$relaxed_no_git/Cargo.lock" ]] || fail 'relaxed scan left a generated Cargo.lock'

  make_workspace "$tmp/no-lock"; rm "$tmp/no-lock/Cargo.lock"; git -C "$tmp/no-lock" add -u; expect_scan_failure "$tmp/no-lock"
  make_workspace "$tmp/unpinned"; expect_scan_failure "$tmp/unpinned"
  if RUSTFLAGS=-Cdebuginfo=0 CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" scan "$strict" '' strict >/dev/null 2>&1; then fail 'strict semantic environment accepted'; fi
  config="$tmp/invalid-config.json"; printf '{"version":2}\n' > "$config"; expect_scan_failure "$one" "$config" relaxed
  config="$tmp/unknown-package.json"; printf '{"packages":{"missing":{}}}\n' > "$config"; expect_scan_failure "$one" "$config" relaxed
  config="$tmp/unknown-feature.json"; printf '{"packages":{"demo":{"features":["missing"]}}}\n' > "$config"; expect_scan_failure "$one" "$config" relaxed

  CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" apply "$one" current >/dev/null
  if CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" apply "$one" current >/dev/null 2>&1; then fail 'already-applied run accepted'; fi

  patch_backup="$tmp/patch-backup"; cp "$two/.codex-clippy-index/current/machine-applicable.patch" "$patch_backup"
  printf 'corrupt\n' >> "$two/.codex-clippy-index/current/machine-applicable.patch"
  if CLIPPY_INDEX_LIBRARY=0 bash "$script_dir/clippy-index.sh" verify "$two" current >/dev/null 2>&1; then fail 'corrupted run verified'; fi
  cp "$patch_backup" "$two/.codex-clippy-index/current/machine-applicable.patch"
}

run_golden_tests
run_integration_tests
printf 'cargo-clippy-index tests passed\n'
