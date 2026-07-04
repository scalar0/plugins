def rows:
  split("\n")
  | map(select(length > 0) | split("\t"));

rows as $rows
| ($rows[0] // []) as $header
| $rows[1:]
| map(
    . as $row
    | reduce range(0; $header | length) as $index
        ({}; .[$header[$index]] = ($row[$index] // ""))
    | {
        suggestion_key,
        id,
        status,
        reason,
        path,
        files: (if .files == "" then [] else (.files | split(",")) end)
      }
  )
