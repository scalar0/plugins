def relpath($path; $root):
  if ($path | type) != "string" then ""
  elif $path == $root then "."
  elif ($path | startswith($root + "/")) then $path[($root | length) + 1:]
  elif ($path | startswith("/")) then "<absolute>"
  else $path
  end;
def target_identity($target): {kind: (($target.kind // []) | sort), name: ($target.name // "")};
def span($span; $root): {
  path: relpath(($span.file_name // ""); $root),
  path_valid: (($span.file_name // "") as $path | (($path | type) == "string" and ((($path | startswith("/")) | not) or ($path | startswith($root + "/"))))),
  byte_start: ($span.byte_start // null),
  byte_end: ($span.byte_end // null),
  line: ($span.line_start // null),
  column: ($span.column_start // null)
};

[
  .[]
  | select(.message.reason == "compiler-message")
  | .message.message as $message
  | select(($message.code.code // "") != "")
  | ([($message.spans // [])[] | select(.is_primary == true)][0] // (($message.spans // [])[0] // {})) as $primary
  | {
      package: .package,
      package_id: .package_id,
      target: target_identity(.target),
      level: ($message.level // ""),
      code: $message.code.code,
      message: (($message.message // "") | split("\n")[0]),
      primary: span($primary; $root)
    } as $identity
  | {
      identity: $identity,
      suggestions: [
        ($message.children // [])[]
        | ([.spans[]? | select(has("suggested_replacement"))]) as $replacements
        | select(($replacements | length) > 0)
        | {
            identity: {
              diagnostic: $identity,
              message: (.message // ""),
              applicability: ($replacements[0].suggestion_applicability // null),
              replacements: ($replacements | map({
                path: relpath((.file_name // ""); $root),
                path_valid: ((.file_name // "") as $path | (($path | type) == "string" and ((($path | startswith("/")) | not) or ($path | startswith($root + "/"))))),
                byte_start: (.byte_start // null),
                byte_end: (.byte_end // null),
                replacement_base64: ((.suggested_replacement // "") | @base64)
              }) | unique | sort_by(.path, .byte_start, .byte_end, .replacement_base64))
            }
          }
      ]
    }
] | sort_by(.identity.package, .identity.target.name, .identity.code, .identity.primary.path, .identity.primary.byte_start, .identity.message)
