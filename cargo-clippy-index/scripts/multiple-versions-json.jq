def tick: "`" + . + "`";

[
  (.diagnostics // [])[]
  | select(.code == "clippy::multiple_crate_versions")
  | (.message | capture("multiple versions for dependency `(?<dependency>[^`]+)`: (?<versions>.+)")) as $match
  | {
      dependency: $match.dependency,
      versions: ($match.versions | split(", ")),
      package: .package
    }
]
| group_by(.dependency)
| map({
    Dependency: (.[0].dependency | tick),
    Versions: ([.[].versions[]] | unique | sort | map(tick) | join(", ")),
    Crates: ([.[].package] | unique | sort | map(tick) | join(", "))
  })
| sort_by(.Dependency)
