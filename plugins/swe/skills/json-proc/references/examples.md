# Examples

Run examples in a temporary directory.

## Inspection and Targeted Extraction

Use this small fixture as `records.json`:

```json
[
    {"id": 1, "name": "Example", "active": true},
    {"id": 2, "name": null, "active": false, "note": "Optional"}
]
```

Inspect structure before selecting unfamiliar fields:

```sh
rtk json --keys-only --depth 3 records.json
jq 'map(keys) | unique' records.json
```

The jq query finds `note` in the second record, which a first-record summary can miss.

For a known identifier, extract only the required fields:

```sh
jq --argjson id 2 '.[] | select(.id == $id) | {id, name}' records.json
```

The result is `{"id":2,"name":null}`.

## Transformation, Merging, and Serialization

Convert an array to one JSON value per line:

```sh
jq -c '.[] | {id, active}' records.json > records.jsonl
```

Pass shell values through jq arguments:

```sh
jq -n --arg name 'A "quoted" name' --argjson active false \
    '{name: $name, active: $active}' > request.json
```

For small configuration objects, apply a shallow override:

```sh
jq -s '.[0] + .[1]' base.json override.json > merged.json
```

The inputs must each contain one object.
The override wins for duplicate keys.
Nested objects and array-valued fields are replaced, not recursively merged or concatenated.

## Schema Validation and Drift

Use this example contract as `record.schema.json`:

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
        "id": {
            "type": "integer",
            "description": "The record identifier."
        },
        "active": {
            "type": "boolean",
            "description": "Whether the record is active."
        }
    },
    "required": ["id", "active"]
}
```

This example permits additional fields.
Use the producer's contract to decide whether to restrict them.

If the repository has no validator, use the uv fallback:

```sh
jq '.[0]' records.json > record-1.json
jq '.[1]' records.json > record-2.json
uvx check-jsonschema --check-metaschema record.schema.json
uvx check-jsonschema --schemafile record.schema.json record-1.json record-2.json
```

Both records pass, including the record with `active: false`.
A string identifier fails the integer constraint:

```sh
jq '.id = "2"' record-2.json > invalid-record.json
uvx check-jsonschema --schemafile record.schema.json invalid-record.json
jq '{id, id_type: (.id | type)}' invalid-record.json
```

Expect validation failure at `id`.
Follow the [drift workflow](../SKILL.md#schema-drift) before changing the data or contract.

For a task-specific predicate over every parsed record:

```sh
jq -ne 'reduce inputs as $record
    (true; . and ($record | type == "object" and (.id | type == "number")))' records.jsonl
```

An invalid middle record makes the final boolean false and the exit status nonzero, even when the last record passes.
Empty input passes this predicate.
It checks parsed JSON values, not JSON Schema constraints or physical line boundaries.

## Candidate Inference

Use the synthetic inspection fixture with these Quicktype MCP arguments:

```json
{
    "json": "[{\"id\":1,\"name\":\"Example\",\"active\":true},{\"id\":2,\"name\":null,\"active\":false,\"note\":\"Optional\"}]",
    "language": "schema",
    "typeName": "Record"
}
```

An array sample can produce an array schema, not a schema for individual records.
The sample supplies evidence for nullable `name` and optional `note`.
It cannot prove that every other field is required or that additional fields are forbidden.

Follow the [schema-first workflow](../SKILL.md#schema-first-processing) before adopting a candidate.
