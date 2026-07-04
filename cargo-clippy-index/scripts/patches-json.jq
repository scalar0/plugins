[
  (.patches // [])[]
  | {
      id: (.id // ""),
      status: (.status // ""),
      reason: (.reason // ""),
      package: (.package // ""),
      code: (.code // ""),
      file: (.file // ""),
      line: ((.line // "") | tostring),
      path: (.path // ""),
      files: ((.files // []) | join(","))
    }
]
