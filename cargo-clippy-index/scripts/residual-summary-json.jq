def tick: "`" + . + "`";

[
  (.diagnostics // [])[]
  | select(.code != "clippy::multiple_crate_versions")
]
| group_by([.code, .message])
| map({
    Code: (.[0].code | tick),
    Message: .[0].message,
    Crates: ([.[].package] | unique | sort | map(tick) | join(", "))
  })
| sort_by(.Code, .Message)
