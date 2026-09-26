---
name: json-proc
description: Inspect, transform, or validate JSON and JSONL, investigate schema drift, and infer candidate schemas for reusable interfaces.
---

# JSON Processing

## Workflow

1. Identify the result, input format, data size, and consumer.
2. Find existing tools and schemas through validation commands, producer documentation, schema associations, or build configuration.
3. Select the applicable actions below.
4. Validate inputs and outputs against their applicable contracts.
5. Report the result, validation status, and unresolved limits.

| Condition                                        | Action                                                                            |
| ------------------------------------------------ | --------------------------------------------------------------------------------- |
| Unfamiliar or large structure                    | Inspect with RTK after reading its [limits](references/tools.md#rtk-inspection).  |
| Known fields or transformation                   | Use targeted jq selection, transformation, predicates, merging, or serialization. |
| Existing schema                                  | Use the repository validator with the authoritative schema and its dialect.       |
| Unfamiliar reusable interface without a schema   | Follow [Quicktype inference](references/tools.md#quicktype-mcp).                  |
| Application objects or unnecessary serialization | Use native parsing, types, and validation.                                        |

Combine actions as needed.
Skip inspection for known fields.
Use jq by default unless native processing, fidelity, or resource limits justify an alternative.
For JSONL, process records without collecting the whole file unless aggregation requires it.
Convert other formats with an existing converter only when JSON preserves required information.

Read [examples](references/examples.md) for query, merge, serialization, validation, and inference patterns.
Read [tool details](references/tools.md) for setup, jq failure modes, streaming, validator differences, and Bazel integration.

## Schema-First Processing

For persistent contracts without schemas, define a draft 2020-12 schema with field descriptions and structural constraints.
Persistent contracts include reusable interfaces, persisted configuration, and shared artifacts.
Temporary extraction results need no schema unless their consumer requires one.
Associate data through repository configuration or validator arguments.
Add `schema_version` only when explicitly required.

Keep inferred candidates separate from established schemas until explicit review permits a change.
Use jq predicates for task-specific checks, not JSON Schema validation.
Write outputs separately.
Validate them before replacement or publication.

## Schema Drift

1. Confirm schema selection, dialect, reference resolution, and validator options.
2. Record the failing instance path, constraint, and expected and observed types or values.
3. Extract the smallest relevant example with jq.
4. Compare the example with producer documentation, code, and known valid data.
5. Repair clear data or transformation defects within the authorized task.
6. Before changing an established schema, present evidence and compatibility effects for explicit review.
7. Validate the correction and check affected consumers.

Report unresolved failures.
Do not weaken constraints, discard failing records, or apply defaults solely to make validation pass.
