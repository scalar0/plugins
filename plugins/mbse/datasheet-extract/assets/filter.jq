def pages:
  .pdf2xml.page
  | if type == "array" then . else [.] end;

def text_array:
  if . == null then []
  elif type == "array" then .
  else [.] end;

def text_fragments:
  ([.. | objects | .["#text"]? | strings] + [.. | objects | .b? | strings]);

def normalized_text:
  (text_fragments | join(" "))
  | gsub("[[:space:]]+"; " ")
  | gsub("^ "; "")
  | gsub(" $"; "");

def normalize_scalar:
  if type == "string" and test("^-?[0-9]+(\\.[0-9]+)?$") then tonumber
  else .
  end;

def has_bold:
  ([.. | objects | has("b")] | any);

def concat_page_text:
  [
    pages[] as $p
    | ($p["@number"] | tonumber) as $page
    | ($p.text | text_array)[]
    | . + {"@page": $page}
  ];

def keep_text_bearing_nodes:
  [
    .[]
    | select((normalized_text | length) > 0)
    | select((normalized_text | test("^[•●▪◦◾◽◆◇■□▸▹►▻◀◁◊○◎]+$")) | not)
  ];

def normalize_coordinates:
  [
    .[]
    | {
        page: (.["@page"] | normalize_scalar),
        top: (.["@top"] | normalize_scalar),
        left: (.["@left"] | normalize_scalar),
        width: (.["@width"] | normalize_scalar),
        height: (.["@height"] | normalize_scalar),
        font: (.["@font"] | normalize_scalar),
        bold: has_bold,
        text: normalized_text
      }
  ]
  | sort_by(.page, .top, .left);

def build_lines:
  (
    .
    | group_by([.page, .top])
    | map(
        sort_by(.left)
        | {
            page: .[0].page,
            line_pos: .[0].top,
            heading: (length == 1 and .[0].bold),
            text: map(.text)
          }
      )
  );

def line_array_pipeline:
  concat_page_text
  | keep_text_bearing_nodes
  | normalize_coordinates
  | build_lines;

line_array_pipeline