def residuals($index):
  [$index.diagnostics[] | . as $diagnostic | select(any($index.suggestions[]; .diagnostic_id == $diagnostic.id and .status == "included") | not)];

if $view == "residuals" then
  (["ID", "Package", "Code", "Location", "Message", "Occurrences"] | @csv),
  (residuals(.)[] | [.id, .package, .code, (.primary.path + ":" + ((.primary.line // 0) | tostring)), .message, .occurrences] | @csv)
elif $view == "patch" then
  (["Suggestion", "Status", "Reason", "Applicability", "Message"] | @csv),
  (.suggestions[] | [.id, .status, (.skip_reason // ""), (.applicability // ""), .message] | @csv)
elif $view == "todo" then
  (["ID", "Package", "Code", "Path", "Line", "Message"] | @csv),
  (residuals(.)[] | [.id, .package, .code, .primary.path, (.primary.line // ""), .message] | @csv)
elif $view == "status" then
  (["Package", "Exit", "Command", "Stderr"] | @csv),
  (.[] | [.package, .exit_code, (.args | join(" ")), .stderr] | @csv)
else error("unsupported report view") end
