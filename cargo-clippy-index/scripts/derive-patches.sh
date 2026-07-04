#!/usr/bin/env bash
set -euo pipefail

index_dir=".codex-clippy-index"
field_separator=$'\x1f'
machine_applicable="MachineApplicable"

root="${1:-.}"
root="$(realpath "$root")"
patches_dir="$root/$index_dir/patches"

mkdir -p "$patches_dir"
find "$patches_dir" -type f -name '*.patch' -delete

printf 'suggestion_key%sid%sstatus%sreason%spath%sfiles\n' \
  "$field_separator" "$field_separator" "$field_separator" "$field_separator" "$field_separator"

input="$(mktemp)"
rows="$(mktemp)"
group="$(mktemp)"
trap 'rm -f "$input" "$rows" "$group"' EXIT

cat > "$input"
tail -n +2 "$input" | sort -t "$field_separator" -k1,1 -k5,5 -k6,6nr > "$rows"

emit_result() {
  local suggestion_key="$1"
  local id="$2"
  local status="$3"
  local reason="$4"
  local path="$5"
  local files="$6"
  printf '%s%s%s%s%s%s%s%s%s%s%s\n' \
    "$suggestion_key" "$field_separator" \
    "$id" "$field_separator" \
    "$status" "$field_separator" \
    "$reason" "$field_separator" \
    "$path" "$field_separator" \
    "$files"
}

join_files() {
  sort -u "$1" | paste -sd, -
}

invalid_int() {
  [[ ! "$1" =~ ^[0-9]+$ ]]
}

process_group() {
  local current_key="$1"
  local applicability replacement_count replacement_index file_name byte_start byte_end replacement_base64
  local expected_count=""
  local rows_seen=0
  local reason=""
  local tmpdir files_touched changed_files patch_tmp patch_id patch_path previous_file previous_end

  tmpdir="$(mktemp -d)"
  files_touched="$tmpdir/files-touched"
  changed_files="$tmpdir/changed-files"
  patch_tmp="$tmpdir/patch"
  : > "$files_touched"
  : > "$changed_files"

  while IFS="$field_separator" read -r _ applicability replacement_count replacement_index file_name byte_start byte_end replacement_base64; do
    rows_seen=$((rows_seen + 1))
    if [[ "$expected_count" == "" ]]; then
      expected_count="$replacement_count"
    fi
    if [[ "$applicability" != "$machine_applicable" && "$reason" == "" ]]; then
      reason="non-machine-applicable"
    fi
    if [[ "$file_name" == "" || "$byte_start" == "" || "$byte_end" == "" || "$replacement_count" == "" ]]; then
      if [[ "$reason" == "" ]]; then
        reason="missing-span-data"
      fi
    elif invalid_int "$byte_start" || invalid_int "$byte_end" || invalid_int "$replacement_count"; then
      if [[ "$reason" == "" ]]; then
        reason="invalid-byte-span"
      fi
    elif (( byte_end < byte_start )); then
      if [[ "$reason" == "" ]]; then
        reason="invalid-byte-span"
      fi
    fi
  done < "$group"

  if [[ "$reason" == "" && "$expected_count" != "$rows_seen" ]]; then
    reason="missing-span-data"
  fi

  previous_file=""
  previous_end=-1
  if [[ "$reason" == "" ]]; then
    while IFS="$field_separator" read -r _ _ _ _ file_name byte_start byte_end _; do
      if [[ "$file_name" != "$previous_file" ]]; then
        previous_file="$file_name"
        previous_end=-1
      fi
      if (( byte_start < previous_end )); then
        reason="overlapping-spans"
        break
      fi
      previous_end="$byte_end"
    done < <(sort -t "$field_separator" -k5,5 -k6,6n "$group")
  fi

  if [[ "$reason" == "" ]]; then
    while IFS="$field_separator" read -r _ _ _ _ file_name byte_start byte_end replacement_base64; do
      local source_path="$root/$file_name"
      local modified_path="$tmpdir/modified/$file_name"
      local next_path="$tmpdir/next"
      local source_size

      if [[ ! -f "$source_path" ]]; then
        reason="missing-file"
        break
      fi
      source_size="$(wc -c < "$source_path" | tr -d ' ')"
      if (( byte_end > source_size )); then
        reason="byte-span-out-of-range"
        break
      fi

      if [[ ! -f "$modified_path" ]]; then
        mkdir -p "$(dirname "$modified_path")"
        cp "$source_path" "$modified_path"
      fi

      {
        head -c "$byte_start" "$modified_path"
        if [[ "$replacement_base64" != "" ]]; then
          printf '%s' "$replacement_base64" | base64 -d
        fi
        tail -c "+$((byte_end + 1))" "$modified_path"
      } > "$next_path"
      mv "$next_path" "$modified_path"
      printf '%s\n' "$file_name" >> "$files_touched"
    done < "$group"
  fi

  if [[ "$reason" == "" ]]; then
    while IFS= read -r file_name; do
      local source_path="$root/$file_name"
      local modified_path="$tmpdir/modified/$file_name"
      if ! cmp -s "$source_path" "$modified_path"; then
        printf '%s\n' "$file_name" >> "$changed_files"
        diff -u --label "a/$file_name" --label "b/$file_name" "$source_path" "$modified_path" >> "$patch_tmp" || true
      fi
    done < <(sort -u "$files_touched")

    if [[ ! -s "$patch_tmp" ]]; then
      reason="empty-patch"
    elif ! git -C "$root" apply --check "$patch_tmp" >/dev/null 2>&1; then
      reason="invalid-patch"
    fi
  fi

  if [[ "$reason" != "" ]]; then
    emit_result "$current_key" "" "skipped" "$reason" "" "$(join_files "$changed_files")"
    rm -rf "$tmpdir"
    return
  fi

  patch_id="$(git patch-id --stable < "$patch_tmp" | cut -d' ' -f1)"
  patch_path="$patches_dir/$patch_id.patch"
  cp "$patch_tmp" "$patch_path"
  emit_result "$current_key" "$patch_id" "written" "" "$index_dir/patches/$patch_id.patch" "$(join_files "$changed_files")"
  rm -rf "$tmpdir"
}

current_key=""
: > "$group"
while IFS="$field_separator" read -r suggestion_key rest; do
  if [[ "$suggestion_key" == "" ]]; then
    continue
  fi
  if [[ "$current_key" != "" && "$suggestion_key" != "$current_key" ]]; then
    process_group "$current_key"
    : > "$group"
  fi
  current_key="$suggestion_key"
  printf '%s%s%s\n' "$suggestion_key" "$field_separator" "$rest" >> "$group"
done < "$rows"

if [[ "$current_key" != "" ]]; then
  process_group "$current_key"
fi
