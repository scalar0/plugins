.diagnostics
| unique_by([.package, .code, .file, .line, .message])
| map({
    package: (.package // ""),
    code: (.code // ""),
    file: (.file // ""),
    line: ((.line // "") | tostring),
    message: (.message // "")
  })
