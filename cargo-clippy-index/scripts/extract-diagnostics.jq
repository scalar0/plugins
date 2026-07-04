def primary_span:
  (.spans // []) as $spans
  | (first($spans[]? | select(.is_primary == true)) // ($spans[0] // {}));

def suggestion_key($package; $diagnostic_index; $suggestion_index):
  [$package, ($diagnostic_index | tostring), ($suggestion_index | tostring)] | join("|");

def suggestions($package; $diagnostic_index; $message):
  [
    ($message.children // [])
    | to_entries[]
    | . as $suggestion
    | ($suggestion.value.spans // [] | map(select(has("suggested_replacement")))) as $replacement_spans
    | select(($replacement_spans | length) > 0)
    | {
        key: suggestion_key($package; $diagnostic_index; $suggestion.key),
        message: ($suggestion.value.message // ""),
        applicability: ($replacement_spans[0].suggestion_applicability // null),
        replacement_count: ($replacement_spans | length),
        status: "pending",
        skip_reason: null,
        patch_id: null
      }
  ];

to_entries[]
| select(.value.reason == "compiler-message")
| .key as $diagnostic_index
| .value.message as $message
| ($message.code.code // empty) as $code
| select($code != "")
| ($message | primary_span) as $span
| {
    package: $package,
    diagnostic_index: $diagnostic_index,
    level: $message.level,
    code: $code,
    message: (($message.message // "") | split("\n")[0]),
    file: ($span.file_name // null),
    line: ($span.line_start // null),
    suggestions: suggestions($package; $diagnostic_index; $message),
    patch_ids: []
  }
