#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C TZ=UTC CARGO_TERM_COLOR=never CARGO_INCREMENTAL=0

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
index_name=.codex-clippy-index
canonical_files=(plan.json status.json index.json todo.tsv patch.json machine-applicable.patch)

die() { printf 'cargo-clippy-index: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "required tool not found: $1"; }
sha_file() { sha256sum "$1" | cut -d' ' -f1; }
sha_text() { sha256sum | cut -d' ' -f1; }
canonical_json() { jq -S -c '.' "$1"; }
write_json() { jq -S '.' > "$1"; }
root_path() { realpath "$1"; }

resolve_run() {
  local root="$1" run="$2" path
  path="$root/$index_name/runs/$run"
  if [[ "$run" == current ]]; then
    path="$root/$index_name/current"
  fi
  [[ -d "$path" ]] || die "run not found: $run"
  realpath "$path"
}

engine_digest() {
  local file
  for file in Justfile clippy-index.sh normalize-plan.jq canonicalize-diagnostics.jq report.jq; do
    printf '%s  %s\n' "$(sha_file "$script_dir/$file")" "$file"
  done | sha_text
}

workspace_fingerprint() {
  local root="$1" path type mode hash target encoded tmp git_worktree
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN
  git_worktree=false; git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 && git_worktree=true
  if [[ "$git_worktree" == true ]]; then
    git -C "$root" ls-files -co --exclude-standard -z | sort -z > "$tmp.paths"
  else
    (cd "$root" && find . -path "./$index_name" -prune -o -path './.git' -prune -o \( -type f -o -type l \) -print0) | sort -z > "$tmp.paths"
  fi
  while IFS= read -r -d '' path; do
        path="${path#./}"
        [[ "$path" == "$index_name" || "$path" == "$index_name/"* ]] && continue
        [[ "$path" == /* ]] && die "invalid Git path"
        if [[ -L "$root/$path" ]]; then
          type=symlink; mode=120000; target="$(readlink "$root/$path")"; hash="$(printf '%s' "$target" | sha_text)"
        elif [[ -f "$root/$path" ]]; then
          type=file
          [[ -x "$root/$path" ]] && mode=100755 || mode=100644
          target=""; hash="$(sha_file "$root/$path")"
        else
          type=missing; mode=0; target=""; hash=""
        fi
        encoded="$(printf '%s' "$path" | base64 -w0)"
        jq -cn --arg p "$encoded" --arg type "$type" --arg mode "$mode" --arg hash "$hash" --arg target "$(printf '%s' "$target" | base64 -w0)" \
          '{path_base64:$p,type:$type,mode:($mode|tonumber),sha256:$hash,symlink_target_base64:$target}'
      done < "$tmp.paths" > "$tmp"
  jq -S -s '
    map(
      if ((.path_base64 | @base64d | @base64) != .path_base64) or ((.symlink_target_base64 | @base64d | @base64) != .symlink_target_base64)
      then error("workspace paths and symlink targets must be UTF-8") else . end
      | .path=(.path_base64|@base64d) | del(.path_base64)
      | .symlink_target=(.symlink_target_base64|@base64d) | del(.symlink_target_base64)
    )' "$tmp"
  rm -f "$tmp" "$tmp.paths"
  trap - RETURN
}

config_hashes() {
  local root="$1" file
  for file in .cargo/config .cargo/config.toml; do
    if [[ -f "$root/$file" ]]; then
      jq -cn --arg path "$file" --arg hash "$(sha_file "$root/$file")" '{path:$path,sha256:$hash}'
    fi
  done | jq -S -s 'sort_by(.path)'
}

toolchain_channel() {
  local root="$1"
  if [[ -f "$root/rust-toolchain.toml" ]]; then
    sed -n 's/^[[:space:]]*channel[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$root/rust-toolchain.toml" | head -n1
  elif [[ -f "$root/rust-toolchain" ]]; then
    tr -d '[:space:]' < "$root/rust-toolchain"
  fi
}

semantic_environment() {
  local name
  for name in RUSTFLAGS RUSTDOCFLAGS CARGO_ENCODED_RUSTFLAGS CARGO_BUILD_TARGET CARGO_TARGET_DIR CARGO_BUILD_JOBS RUSTC RUSTC_WRAPPER RUSTC_WORKSPACE_WRAPPER RUSTUP_TOOLCHAIN; do
    if [[ -v "$name" && -n "${!name}" ]]; then
      jq -cn --arg name "$name" --arg value "${!name}" '{name:$name,value_base64:($value|@base64)}'
    fi
  done | jq -S -s 'sort_by(.name)'
}

normalize_config() {
  local root="$1" config_path="$2" metadata="$3" host="$4" input
  if [[ -n "$config_path" ]]; then
    config_path="$(realpath "$config_path")"
    [[ -f "$config_path" ]] || die "configuration not found"
  elif [[ -f "$root/clippy-index.json" ]]; then
    config_path="$root/clippy-index.json"
  fi
  input="$(mktemp)"
  if [[ -n "$config_path" ]]; then
    jq -n --slurpfile config "$config_path" --slurpfile metadata "$metadata" --arg host "$host" \
      '{config:$config[0],metadata:$metadata[0],host:$host}' > "$input"
  else
    jq -n --slurpfile metadata "$metadata" --arg host "$host" '{config:{},metadata:$metadata[0],host:$host}' > "$input"
  fi
  jq -S -f "$script_dir/normalize-plan.jq" "$input"
  rm -f "$input"
}

artifact_digest() {
  local run="$1" file
  for file in "${canonical_files[@]}"; do
    [[ -f "$run/$file" ]] || die "missing canonical artifact: $file"
    printf '%s  %s\n' "$(sha_file "$run/$file")" "$file"
  done
  if [[ -d "$run/sources" ]]; then
    find "$run/sources" -maxdepth 1 -type f -printf '%f\n' | sort | while read -r file; do
      printf '%s  sources/%s\n' "$(sha_file "$run/sources/$file")" "$file"
    done
  fi
}

add_content_ids() {
  local canonical="$1" output="$2" diagnostics suggestions line seed id did sid tmpd tmps
  tmpd="$(mktemp)"; tmps="$(mktemp)"
  while IFS= read -r line; do
    seed="$(jq -S -c '.identity' <<< "$line")"; did="$(printf '%s' "$seed" | sha_text)"
    jq -S -c --arg id "$did" '.identity + {id:$id}' <<< "$line" >> "$tmpd"
    while IFS= read -r suggestion; do
      [[ -n "$suggestion" ]] || continue
      seed="$(jq -S -c --arg did "$did" '.identity | .diagnostic=$did' <<< "$suggestion")"; sid="$(printf '%s' "$seed" | sha_text)"
      jq -S -c --arg id "$sid" --arg did "$did" '.identity | .diagnostic_id=$did | del(.diagnostic) | . + {id:$id}' <<< "$suggestion" >> "$tmps"
    done < <(jq -c '.suggestions[]' <<< "$line")
  done < <(jq -c '.[]' "$canonical")
  jq -S -s 'sort_by(.id) | group_by(.id) | map(.[0] + {occurrences:length})' "$tmpd" > "$output.diagnostics"
  jq -S -s 'sort_by(.id) | group_by(.id) | map(.[0] + {occurrences:length,status:"pending",skip_reason:null})' "$tmps" > "$output.suggestions"
  rm -f "$tmpd" "$tmps"
}

validate_suggestions() {
  local root="$1" stage="$2" suggestions="$3" results spans line id applicability path valid start end replacement source_size before slice replacement_file noop count good
  results="$stage/.suggestion-results.jsonl"; spans="$stage/.accepted-spans.tsv"
  : > "$results"; : > "$spans"; mkdir -p "$stage/sources"
  while IFS= read -r line; do
    id="$(jq -r '.id' <<< "$line")"; applicability="$(jq -r '.applicability // ""' <<< "$line")"
    if [[ "$applicability" != MachineApplicable ]]; then
      jq -cn --arg id "$id" '{id:$id,status:"skipped",skip_reason:"non-machine-applicable"}' >> "$results"; continue
    fi
    good=1; noop=1; count=0
    while IFS=$'\t' read -r path valid start end replacement; do
      count=$((count + 1))
      path="$(printf '%s' "$path" | base64 -d)"
      if [[ "$valid" != true || -z "$path" || "$path" == /* || "$path" == "<absolute>" || "$path" == .. || "$path" == ../* || "$path" == */../* || "$path" == */.. ]]; then
        good=0; reason=invalid-suggestion-path; break
      fi
      if [[ ! "$start" =~ ^[0-9]+$ || ! "$end" =~ ^[0-9]+$ || "$end" -lt "$start" ]]; then
        good=0; reason=invalid-byte-span; break
      fi
      if [[ ! -f "$root/$path" ]]; then good=0; reason=missing-file; break; fi
      if ! iconv -f UTF-8 -t UTF-8 "$root/$path" >/dev/null 2>&1; then good=0; reason=non-utf8-file; break; fi
      source_size="$(wc -c < "$root/$path" | tr -d ' ')"
      if (( end > source_size )); then good=0; reason=byte-span-out-of-range; break; fi
      before="$(sha_file "$root/$path")"; cp --update=none "$root/$path" "$stage/sources/$before"
      [[ "$(sha_file "$stage/sources/$before")" == "$before" ]] || { good=0; reason=stale-source; break; }
      replacement_file="$(mktemp)"; printf '%s' "$replacement" | base64 -d > "$replacement_file"
      if ! iconv -f UTF-8 -t UTF-8 "$replacement_file" >/dev/null 2>&1; then rm -f "$replacement_file"; good=0; reason=replacement-produces-non-utf8; break; fi
      slice="$(mktemp)"; dd if="$root/$path" of="$slice" bs=1 skip="$start" count="$((end-start))" status=none
      if ! cmp -s "$slice" "$replacement_file"; then noop=0; fi
      rm -f "$slice" "$replacement_file"
      printf '%s\t%s\t%s\t%s\t%s\n' "$id" "$(printf '%s' "$path" | base64 -w0)" "$start" "$end" "$replacement" >> "$spans"
    done < <(jq -r '.replacements[] | [(.path|@base64), (.path_valid|tostring), (.byte_start|tostring), (.byte_end|tostring), .replacement_base64] | @tsv' <<< "$line")
    if (( ! good )); then
      jq -cn --arg id "$id" --arg reason "$reason" '{id:$id,status:"skipped",skip_reason:$reason}' >> "$results"
      awk -F '\t' -v id="$id" '$1 != id' "$spans" > "$spans.tmp"; mv "$spans.tmp" "$spans"
    elif (( count == 0 )); then
      jq -cn --arg id "$id" '{id:$id,status:"skipped",skip_reason:"missing-span-data"}' >> "$results"
    elif (( noop )); then
      jq -cn --arg id "$id" '{id:$id,status:"skipped",skip_reason:"no-op-suggestion"}' >> "$results"
      awk -F '\t' -v id="$id" '$1 != id' "$spans" > "$spans.tmp"; mv "$spans.tmp" "$spans"
    fi
  done < <(jq -c '.[]' "$suggestions")
}

mark_conflicts() {
  local stage="$1" spans="$stage/.accepted-spans.tsv" conflicts="$stage/.conflicts" a b aid ap as ae ar bid bp bs be br
  : > "$conflicts"
  mapfile -t rows < "$spans"
  for ((a=0; a<${#rows[@]}; a++)); do
    IFS=$'\t' read -r aid ap as ae ar <<< "${rows[a]}"
    for ((b=a+1; b<${#rows[@]}; b++)); do
      IFS=$'\t' read -r bid bp bs be br <<< "${rows[b]}"
      if [[ "$ap" == "$bp" ]] && { [[ "$as" == "$bs" && "$ae" == "$be" && "$ar" != "$br" ]] || [[ "$as" -lt "$be" && "$bs" -lt "$ae" && !( "$as" == "$bs" && "$ae" == "$be" && "$ar" == "$br" ) ]]; }; then
        printf '%s\n%s\n' "$aid" "$bid" >> "$conflicts"
      fi
    done
  done
  sort -u "$conflicts" -o "$conflicts"
  while IFS= read -r aid; do
    [[ -n "$aid" ]] || continue
    jq -cn --arg id "$aid" '{id:$id,status:"skipped",skip_reason:"conflicting-suggestion"}' >> "$stage/.suggestion-results.jsonl"
    awk -F '\t' -v id="$aid" '$1 != id' "$spans" > "$spans.tmp"; mv "$spans.tmp" "$spans"
  done < "$conflicts"
}

build_patch() {
  local root="$1" stage="$2" spans="$stage/.accepted-spans.tsv" modified="$stage/.modified" path64 path start end replacement src dst next id before after
  mkdir -p "$modified"; : > "$stage/machine-applicable.patch"; : > "$stage/.patch-files.jsonl"
  cut -f2 "$spans" | sort -u | while IFS= read -r path64; do
    [[ -n "$path64" ]] || continue
    path="$(printf '%s' "$path64" | base64 -d)"; src="$root/$path"; dst="$modified/$path"
    mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"
    awk -F '\t' -v p="$path64" '$2 == p' "$spans" | sort -t $'\t' -k3,3nr -k4,4nr -k5,5 \
      | awk -F '\t' '!seen[$2 FS $3 FS $4 FS $5]++' \
      | while IFS=$'\t' read -r id _ start end replacement; do
          next="$(mktemp)"
          head -c "$start" "$dst" > "$next"
          printf '%s' "$replacement" | base64 -d >> "$next"
          tail -c "+$((end + 1))" "$dst" >> "$next"
          mv "$next" "$dst"
        done
  done
  cut -f2 "$spans" | sort -u | while IFS= read -r path64; do
    [[ -n "$path64" ]] || continue
    path="$(printf '%s' "$path64" | base64 -d)"
    if ! cmp -s "$root/$path" "$modified/$path"; then
      diff -u --label "a/$path" --label "b/$path" "$root/$path" "$modified/$path" >> "$stage/machine-applicable.patch" || true
      before="$(sha_file "$root/$path")"; after="$(sha_file "$modified/$path")"
      jq -cn --arg path "$path" --arg before "$before" --arg after "$after" '{path:$path,before_sha256:$before,after_sha256:$after}' >> "$stage/.patch-files.jsonl"
    fi
  done
  cut -f1 "$spans" | sort -u | while IFS= read -r id; do
    jq -cn --arg id "$id" '{id:$id,status:"included",skip_reason:null}'
  done >> "$stage/.suggestion-results.jsonl"
}

derive_artifacts() {
  local root="$1" stage="$2" run_id="$3" records canonical tmp suggestions diagnostics patch_hash
  records="$stage/.records.json"; canonical="$stage/.canonical.json"; tmp="$stage/.ids"
  jq -S -s '.' "$stage"/raw/*.annotated.json > "$records"
  jq -S --arg root "$root" -f "$script_dir/canonicalize-diagnostics.jq" "$records" > "$canonical"
  add_content_ids "$canonical" "$tmp"
  diagnostics="$tmp.diagnostics"; suggestions="$tmp.suggestions"
  validate_suggestions "$root" "$stage" "$suggestions"
  mark_conflicts "$stage"; build_patch "$root" "$stage"
  jq -S -s 'sort_by(.id) | group_by(.id) | map(last)' "$stage/.suggestion-results.jsonl" > "$stage/.results.json"
  jq -S --slurpfile results "$stage/.results.json" '
    map(. as $s | ($results[0][] | select(.id == $s.id)) as $r | $s + $r) | sort_by(.id)' "$suggestions" > "$stage/.final-suggestions.json"
  patch_hash="$(sha_file "$stage/machine-applicable.patch")"
  jq -S -n --arg hash "$patch_hash" --slurpfile suggestions "$stage/.final-suggestions.json" --slurpfile files "$stage/.patch-files.jsonl" \
    '{sha256:$hash,included_suggestion_ids:[$suggestions[0][]|select(.status=="included")|.id],skipped:[$suggestions[0][]|select(.status=="skipped")|{id,reason:.skip_reason}],files:($files|sort_by(.path))}' > "$stage/patch.json"
  jq -S -n --arg run_id "$run_id" --slurpfile plan "$stage/plan.json" --slurpfile diagnostics "$diagnostics" \
    --slurpfile suggestions "$stage/.final-suggestions.json" --slurpfile patch "$stage/patch.json" \
    '{schema_version:2,run_id:$run_id,reproducible:$plan[0].reproducible,diagnostics:$diagnostics[0],suggestions:$suggestions[0],patch:$patch[0]}' > "$stage/index.json"
  printf 'id\tpackage\tcode\tpath\tline\tmessage\toccurrences\n' > "$stage/todo.tsv"
  jq -r '.diagnostics[] | [.id,.package,.code,.primary.path,(.primary.line//""),(.message|gsub("[\\t\\r\\n]";" ")),.occurrences] | @tsv' "$stage/index.json" >> "$stage/todo.tsv"
  rm -rf "$stage/.modified" "$stage"/raw/*.annotated.json "$stage"/.records.json "$stage"/.canonical.json "$stage"/.ids.* "$stage"/.accepted-spans.tsv "$stage"/.conflicts "$stage"/.results.json "$stage"/.final-suggestions.json "$stage"/.suggestion-results.jsonl "$stage"/.patch-files.jsonl
}

scan() {
  local requested_root="${1:-.}" config_path="${2:-}" mode="${3:-strict}" root index staging stage metadata host channel env_json reasons reproducible fingerprint_before fingerprint_after fingerprint_hash lock_hash cargo_configs versions normalized engine run_id package failures command_file status_file key args_json code raw stderr target_dir existing digest conflict tmp_link active_release active_toolchain generated_lock=false git_worktree=false
  local -a tool_env=()
  [[ "$mode" == strict || "$mode" == relaxed ]] || die 'mode must be strict or relaxed'
  for tool in bash jq sha256sum base64 git cargo rustc diff iconv realpath; do need "$tool"; done
  root="$(root_path "$requested_root")"; [[ -f "$root/Cargo.toml" ]] || die 'Cargo.toml not found'
  index="$root/$index_name"; mkdir -p "$index/runs" "$index/.staging" "$index/conflicts"
  staging="$(mktemp -d "$index/.staging/run.XXXXXX")"; stage="$staging/run"; mkdir -p "$stage/raw"
  [[ -f "$root/Cargo.lock" ]] || generated_lock=true
  trap 'if [[ "${generated_lock:-false}" == true ]]; then rm -f "$root/Cargo.lock"; fi; rm -rf "$staging"' EXIT INT TERM HUP
  reasons='[]'; reproducible=true
  [[ -f "$root/Cargo.lock" ]] || { [[ "$mode" == strict ]] && die 'strict mode requires Cargo.lock'; reasons="$(jq -c '.+["missing-Cargo.lock"]' <<< "$reasons")"; }
  channel="$(toolchain_channel "$root")"
  if [[ ! "$channel" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?([_-].*)?$ && ! "$channel" =~ ^(stable|beta|nightly)-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    [[ "$mode" == strict ]] && die 'strict mode requires a pinned numeric or dated Rust toolchain'
    reasons="$(jq -c '.+["unpinned-toolchain"]' <<< "$reasons")"
  fi
  env_json="$(semantic_environment)"
  if [[ "$(jq length <<< "$env_json")" != 0 ]]; then
    [[ "$mode" == strict ]] && die 'strict mode rejects semantic Rust or Cargo environment overrides'
    reasons="$(jq -c '.+["semantic-environment-overrides"]' <<< "$reasons")"
  fi
  [[ "$mode" == relaxed ]] && reproducible=false
  if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then git_worktree=true; fi
  if [[ "$git_worktree" == false ]]; then
    [[ "$mode" == strict ]] && die 'strict mode requires a Git worktree'
    reasons="$(jq -c '.+["git-worktree-unavailable"]' <<< "$reasons")"
  fi
  active_release="$(rustc -vV | sed -n 's/^release: //p')"
  if [[ "$channel" == "$active_release" ]] && command -v rustup >/dev/null 2>&1; then
    active_toolchain="$(rustup show active-toolchain 2>/dev/null | awk '{print $1}')"
    [[ -n "$active_toolchain" ]] && tool_env=(env "RUSTUP_TOOLCHAIN=$active_toolchain")
  fi
  metadata="$staging/metadata.json"
  if [[ "$mode" == strict ]]; then (cd "$root" && "${tool_env[@]}" cargo metadata --frozen --format-version 1 > "$metadata") || die 'cargo metadata --frozen failed'
  else (cd "$root" && "${tool_env[@]}" cargo metadata --format-version 1 > "$metadata") || die 'cargo metadata failed'; fi
  [[ "$generated_lock" == true ]] && rm -f "$root/Cargo.lock"
  host="$("${tool_env[@]}" rustc -vV | sed -n 's/^host: //p')"; [[ -n "$host" ]] || die 'rustc host triple unavailable'
  normalize_config "$root" "$config_path" "$metadata" "$host" > "$staging/normalized.json"
  if jq -e --arg root "$root" '.. | strings | select(contains($root))' "$staging/normalized.json" >/dev/null; then die 'configuration must not embed the absolute workspace path'; fi
  fingerprint_before="$(workspace_fingerprint "$root")"; fingerprint_hash="$(printf '%s' "$fingerprint_before" | sha_text)"
  lock_hash=""; [[ "$generated_lock" == false && -f "$root/Cargo.lock" ]] && lock_hash="$(sha_file "$root/Cargo.lock")"
  cargo_configs="$(config_hashes "$root")"; engine="$(engine_digest)"
  versions="$(jq -Sn --arg cargo "$("${tool_env[@]}" cargo --version)" --arg rustc "$("${tool_env[@]}" rustc --version)" --arg clippy "$("${tool_env[@]}" cargo clippy --version)" '{cargo:$cargo,clippy:$clippy,rustc:$rustc}')"
  run_id="$(jq -Scn --arg engine "$engine" --arg mode "$mode" --argjson reproducible "$reproducible" --argjson reasons "$reasons" --argjson environment "$env_json" --arg fingerprint "$fingerprint_hash" --arg lock "$lock_hash" --argjson config "$(cat "$staging/normalized.json")" --argjson cargo_configs "$cargo_configs" --argjson versions "$versions" '{engine:$engine,mode:$mode,reproducible:$reproducible,relaxation_reasons:$reasons,environment:$environment,config:$config,fingerprint:$fingerprint,lock:$lock,cargo_configs:$cargo_configs,target:$config.target,versions:$versions}' | sha_text)"
  jq -S -n --arg run_id "$run_id" --arg engine "$engine" --arg mode "$mode" --argjson reproducible "$reproducible" --argjson reasons "$reasons" \
    --arg fingerprint "$fingerprint_hash" --argjson fingerprint_entries "$fingerprint_before" --arg lock "$lock_hash" --argjson cargo_configs "$cargo_configs" --argjson versions "$versions" \
    --argjson environment "$env_json" --slurpfile config "$staging/normalized.json" \
    '{schema_version:2,run_id:$run_id,engine_digest:$engine,mode:$mode,reproducible:$reproducible,relaxation_reasons:$reasons,workspace_fingerprint:{sha256:$fingerprint,entries:$fingerprint_entries},cargo_lock_sha256:$lock,cargo_config_hashes:$cargo_configs,tool_versions:$versions,environment:$environment,configuration:$config[0]}' > "$stage/plan.json"
  status_file="$stage/.status.jsonl"; : > "$status_file"; failures=0; target_dir="$staging/target"
  while IFS= read -r package; do
    key="$(jq -r '.key' <<< "$package")"; mapfile -t args < <(jq -r '
      ["clippy","--package",.name,"--target",$target]
      + (if .all_targets then ["--all-targets"] else [] end)
      + (if .default_features then [] else ["--no-default-features"] end)
      + (if (.features|length)>0 then ["--features",(.features|join(","))] else [] end)
      + (if $frozen then ["--frozen"] else [] end)
      + ["--message-format","json-diagnostic-short","--","-W","clippy::all","-W","clippy::pedantic","-W","clippy::nursery","-W","clippy::cargo"]
      + $extra | .[]' --arg target "$(jq -r '.configuration.target' "$stage/plan.json")" --argjson frozen "$([[ "$mode" == strict ]] && echo true || echo false)" --argjson extra "$(jq '.configuration.extra_clippy_args' "$stage/plan.json")" <<< "$package")
    raw="$stage/raw/$key.jsonl"; stderr="$stage/raw/$key.stderr"
    set +e; (cd "$root" && CARGO_BUILD_JOBS=1 CARGO_TARGET_DIR="$target_dir" "${tool_env[@]}" cargo "${args[@]}") > "$raw" 2> "$stderr"; code=$?; set -e
    (( code == 0 )) || failures=$((failures + 1))
    args_json="$(printf '%s\0' cargo "${args[@]}" | jq -Rs 'split("\u0000")[:-1]')"
    jq -cn --arg package "$key" --argjson code "$code" --argjson args "$args_json" --arg stderr "raw/$key.stderr" '{package:$package,exit_code:$code,args:$args,stderr:$stderr}' >> "$status_file"
    jq -c --arg package "$key" --arg package_id "$(jq -r '.package_id' <<< "$package")" --slurpfile metadata "$metadata" \
      '. as $message | ($metadata[0].packages[] | select(.name==$package)) as $p | ($message.target.name // "") as $target_name | {package:$package,package_id:$package_id,target:(($p.targets[]|select(.name==$target_name)) // ($p.targets[0] // {})),message:$message}' "$raw" > "$stage/raw/$key.annotated.json"
  done < <(jq -c '.configuration.packages[] | select(.enabled)' "$stage/plan.json")
  jq -S -s 'sort_by(.package)' "$status_file" > "$stage/status.json"; rm -f "$status_file"
  if [[ "$generated_lock" == true ]]; then rm -f "$root/Cargo.lock"; generated_lock=false; fi
  fingerprint_after="$(workspace_fingerprint "$root")"
  if [[ "$fingerprint_before" != "$fingerprint_after" ]]; then
    printf '%s\n' "$fingerprint_before" > "$staging/fingerprint-before.json"
    printf '%s\n' "$fingerprint_after" > "$staging/fingerprint-after.json"
    diff -u "$staging/fingerprint-before.json" "$staging/fingerprint-after.json" >&2 || true
    die 'workspace changed during scan'
  fi
  derive_artifacts "$root" "$stage" "$run_id"
  fingerprint_after="$(workspace_fingerprint "$root")"; [[ "$fingerprint_before" == "$fingerprint_after" ]] || die 'workspace changed while deriving artifacts'
  digest="$(artifact_digest "$stage" | sha_text)"; existing="$index/runs/$run_id"
  if [[ -d "$existing" ]]; then
    if [[ "$(artifact_digest "$existing" | sha_text)" == "$digest" ]]; then rm -rf "$stage"; else
      conflict="$index/conflicts/$run_id/$digest"; mkdir -p "$(dirname "$conflict")"; mv "$stage" "$conflict"; printf '%s\n' "$run_id"; die "canonical output conflict stored at conflicts/$run_id/$digest"
    fi
  else mv "$stage" "$existing"; fi
  if (( failures == 0 )); then
    tmp_link="$index/.current.$BASHPID"; ln -s "runs/$run_id" "$tmp_link"; mv -Tf "$tmp_link" "$index/current"
  fi
  rm -rf "$staging"; trap - EXIT INT TERM HUP
  printf '%s\n' "$run_id"
  (( failures == 0 )) || die "$failures package command(s) failed; current was not changed"
}

report() {
  local root run view dir
  need jq; need xan; root="$(root_path "${1:-.}")"; run="${2:-current}"; view="${3:-residuals}"; dir="$(resolve_run "$root" "$run")"
  case "$view" in
    residuals|patch|todo) jq -r --arg view "$view" -f "$script_dir/report.jq" "$dir/index.json" | xan to md ;;
    status) jq -r --arg view "$view" -f "$script_dir/report.jq" "$dir/status.json" | xan to md ;;
    *) die 'view must be residuals, patch, todo, or status' ;;
  esac
}

verify() {
  local root dir patch_hash line seed expected actual todo
  root="$(root_path "${1:-.}")"; dir="$(resolve_run "$root" "${2:-current}")"
  jq -e '.schema_version==2 and .run_id==$id' --arg id "$(basename "$dir")" "$dir/index.json" >/dev/null || die 'index identity mismatch'
  patch_hash="$(sha_file "$dir/machine-applicable.patch")"; [[ "$(jq -r '.sha256' "$dir/patch.json")" == "$patch_hash" ]] || die 'patch hash mismatch'
  jq -e --slurpfile patch "$dir/patch.json" '.patch==$patch[0]' "$dir/index.json" >/dev/null || die 'index patch manifest mismatch'
  while IFS= read -r line; do
    expected="$(jq -r '.id' <<< "$line")"; seed="$(jq -S -c 'del(.id,.occurrences)' <<< "$line")"; actual="$(printf '%s' "$seed" | sha_text)"
    [[ "$expected" == "$actual" ]] || die 'diagnostic content ID mismatch'
  done < <(jq -c '.diagnostics[]' "$dir/index.json")
  while IFS= read -r line; do
    expected="$(jq -r '.id' <<< "$line")"
    seed="$(jq -S -c 'del(.id,.occurrences,.status,.skip_reason) | .diagnostic=.diagnostic_id | del(.diagnostic_id)' <<< "$line")"; actual="$(printf '%s' "$seed" | sha_text)"
    [[ "$expected" == "$actual" ]] || die 'suggestion content ID mismatch'
  done < <(jq -c '.suggestions[]' "$dir/index.json")
  todo="$(mktemp)"; printf 'id\tpackage\tcode\tpath\tline\tmessage\toccurrences\n' > "$todo"
  jq -r '.diagnostics[] | [.id,.package,.code,.primary.path,(.primary.line//""),(.message|gsub("[\\t\\r\\n]";" ")),.occurrences] | @tsv' "$dir/index.json" >> "$todo"
  cmp -s "$todo" "$dir/todo.tsv" || { rm -f "$todo"; die 'todo.tsv does not match index.json'; }; rm -f "$todo"
  while IFS= read -r source; do [[ "$(sha_file "$source")" == "$(basename "$source")" ]] || die 'source snapshot hash mismatch'; done < <(find "$dir/sources" -type f | sort)
  while IFS=$'\t' read -r before path; do [[ -f "$dir/sources/$before" ]] || die "missing source snapshot for $path"; done < <(jq -r '.files[] | [.before_sha256,.path] | @tsv' "$dir/patch.json")
  printf 'verified %s\n' "$(basename "$dir")"
}

apply_run() {
  local root dir failures expected current fingerprint
  root="$(root_path "${1:-.}")"; dir="$(resolve_run "$root" "${2:-current}")"; verify "$root" "${2:-current}" >/dev/null
  failures="$(jq '[.[]|select(.exit_code!=0)]|length' "$dir/status.json")"; (( failures == 0 )) || die 'cannot apply a run with package failures'
  expected="$(jq -r '.workspace_fingerprint.sha256' "$dir/plan.json")"; fingerprint="$(workspace_fingerprint "$root")"; current="$(printf '%s' "$fingerprint" | sha_text)"; [[ "$expected" == "$current" ]] || die 'workspace fingerprint does not match the run'
  [[ "$(jq -r '.reproducible' "$dir/plan.json")" == true ]] || printf 'warning: applying a non-reproducible relaxed run\n' >&2
  [[ -s "$dir/machine-applicable.patch" ]] || { printf 'patch is empty\n'; return; }
  git -C "$root" apply --check "$dir/machine-applicable.patch" || die 'patch preconditions failed or patch was already applied'
  git -C "$root" apply "$dir/machine-applicable.patch"
}

run_tests() {
  bash -n "$script_dir/clippy-index.sh"
  jq -n '{config:{},host:"test",metadata:{workspace_members:["p"],packages:[{id:"p",name:"p",version:"0.1.0",features:{},targets:[]}]}}' | jq -e -f "$script_dir/normalize-plan.jq" >/dev/null
  printf '[]\n' | jq -e --arg root /workspace -f "$script_dir/canonicalize-diagnostics.jq" >/dev/null
  jq -n '{diagnostics:[],suggestions:[]}' | jq -e -r --arg view residuals -f "$script_dir/report.jq" >/dev/null
  bash "$script_dir/test-clippy-index.sh"
}

if [[ "${CLIPPY_INDEX_LIBRARY:-0}" != 1 ]]; then
  case "${1:-}" in
    scan) shift; scan "$@" ;;
    report) shift; report "$@" ;;
    apply) shift; apply_run "$@" ;;
    verify) shift; verify "$@" ;;
    test) run_tests ;;
    *) die 'usage: clippy-index.sh {scan|report|apply|verify|test} ...' ;;
  esac
fi
