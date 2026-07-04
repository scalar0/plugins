def primary_span:
  (.spans // []) as $spans
  | (first($spans[]? | select(.is_primary == true)) // ($spans[0] // {}));

def diagnostic_key($package; $diagnostic_index):
  [$package, ($diagnostic_index | tostring)] | join("|");

def suggestion_key($package; $diagnostic_index; $suggestion_index):
  [$package, ($diagnostic_index | tostring), ($suggestion_index | tostring)] | join("|");

def replacement_rows($package; $diagnostic_index; $suggestion_index; $suggestion):
  ($suggestion.value.spans // [])
  | map(select(has("suggested_replacement")))
  | length as $replacement_count
  | if $replacement_count == 0 then
      empty
    else
      ($suggestion.value.spans // [])
      | to_entries[]
      | select(.value | has("suggested_replacement"))
      | [
          suggestion_key($package; $diagnostic_index; $suggestion_index),
          ($suggestion.value.spans[0].suggestion_applicability // ""),
          ($replacement_count | tostring),
          (.key | tostring),
          (.value.file_name // ""),
          ((.value.byte_start // "") | tostring),
          ((.value.byte_end // "") | tostring),
          ((.value.suggested_replacement // "") | @base64)
        ]
    end;

[
  "suggestion_key",
  "applicability",
  "replacement_count",
  "replacement_index",
  "file_name",
  "byte_start",
  "byte_end",
  "replacement_base64"
],
(
  to_entries[]
  | select(.value.reason == "compiler-message")
  | .key as $diagnostic_index
  | .value.message as $message
  | select(($message.code.code // null) != null)
  | ($message.children // [])
  | to_entries[]
  | replacement_rows($package; $diagnostic_index; .key; .)
)
| @tsv
