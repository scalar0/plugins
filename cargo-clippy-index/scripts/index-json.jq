def by_key($patches):
  reduce $patches[] as $patch ({}; .[$patch.suggestion_key] = $patch);

($diagnostics[0] // []) as $diagnostic_rows
| ($patches[0] // []) as $patch_rows
| by_key($patch_rows) as $patch_by_key
| {
    generated_at: $generated_at,
    workspace_root: $workspace_root,
    diagnostics: (
      $diagnostic_rows
      | map(
          .suggestions = (
            (.suggestions // [])
            | map(
                . as $suggestion
                | ($patch_by_key[$suggestion.key] // null) as $patch
                | if $patch == null then
                    .
                  else
                    .status = $patch.status
                    | .skip_reason = (if $patch.reason == "" then null else $patch.reason end)
                    | .patch_id = (if $patch.id == "" then null else $patch.id end)
                  end
              )
          )
          | .patch_ids = ([.suggestions[]? | .patch_id // empty] | unique)
        )
    ),
    patches: (
      $patch_rows
      | map(
          . as $patch
          | ($diagnostic_rows[]? | .suggestions[]? | select(.key == $patch.suggestion_key)) as $suggestion
          | ($diagnostic_rows[]? | select(any(.suggestions[]?; .key == $patch.suggestion_key))) as $diagnostic
          | {
              id: (if $patch.id == "" then null else $patch.id end),
              package: $diagnostic.package,
              code: $diagnostic.code,
              message: $diagnostic.message,
              file: $diagnostic.file,
              line: $diagnostic.line,
              suggestion_key: $patch.suggestion_key,
              suggestion_message: $suggestion.message,
              status: $patch.status,
              reason: (if $patch.reason == "" then null else $patch.reason end),
              path: (if $patch.path == "" then null else $patch.path end),
              files: $patch.files
            }
        )
    )
  }
