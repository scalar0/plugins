# Tool Details

## Setup

1. Check available commands and MCP tools.
2. For missing tools, use repository setup or the existing package manager within current permissions.
3. For Python tools, use the repository's uv environment or `uvx`.
4. If setup is blocked, report the missing capability and continue independent work.

Keep shared commands and dependency versions in existing repository configuration.
Do not change global configuration or add installation hooks.
If RTK is unavailable, use bounded jq structure queries.
If Quicktype MCP is unavailable, report incomplete inference.

## RTK Inspection

Use `--keys-only --depth 3` for initial inspection.
Check `rtk json --help` for installed options.

| Limit                                                      | Response                                                         |
| ---------------------------------------------------------- | ---------------------------------------------------------------- |
| Summaries can sample the first array element and omit keys | Check varied records with targeted jq queries.                   |
| Compression fallback can expose raw values                 | Prepare a safe sample when values must stay out of context.      |
| RTK reads the full input internally                        | Treat short output as a context benefit, not a memory guarantee. |
| A summary is not source JSON                               | Validate and transform the source, not the summary.              |

See the [RTK implementation](https://github.com/rtk-ai/rtk/blob/master/src/cmds/system/json_cmd.rs) and [output fallback](https://github.com/rtk-ai/rtk/blob/master/src/core/guard.rs).

## jq Processing

| Need or failure                        | Action                                                                                           |
| -------------------------------------- | ------------------------------------------------------------------------------------------------ |
| JSONL output                           | Use `-c` for one JSON value per line.                                                            |
| Bounded aggregation                    | Use `-s` only when collecting all values is acceptable.                                          |
| Input exceeds memory                   | Use `--stream` path/value events with a suitable filter, or an existing native streaming parser. |
| Exact numbers or source representation | Check precision and conversion requirements.                                                     |
| Repeated or complex transformations    | Use repository filters with `-f` and modules with `-L`.                                          |
| Whole-stream predicate                 | Reduce to one result because `-e` uses the last output value.                                    |
| Missing, null, or false                | Check presence with `has` and types separately because `//` replaces both null and false.        |
| Shell values in JSON                   | Pass strings through `--arg` and JSON values through `--argjson`.                                |

Quote jq programs to prevent shell expansion.
Ordinary jq parses each complete input value even when output is small.
Report malformed input and command failures before accepting output.
Consult the [jq manual](https://jqlang.org/manual/) for exact syntax.

## Schema Validation

If the repository has no validator, use the [uv fallback example](examples.md#schema-validation-and-drift).
`check-jsonschema` checks supported formats by default, while other validators can treat formats as annotations.
Match the contract's format behavior before classifying differences as drift.
Its `--fill-defaults` option changes instances before validation.
Validate original data during diagnosis.

Declare the dialect with schema `$schema`.
Use `$id` for a needed stable identifier and `$ref` for reuse.

`check-jsonschema` has no native JSONL record mode.
Use separate record files for small fixtures and an existing record validator for large JSONL inputs.
If none exists, report the schema-validation gap.

See [check-jsonschema usage](https://check-jsonschema.readthedocs.io/en/latest/usage.html), [JSON Schema guidance](https://json-schema.org/understanding-json-schema), and [draft 2020-12](https://json-schema.org/draft/2020-12).

## Quicktype MCP

The plugin's root `mcp.json` declares the hosted service.
Other hosts must expose it through their MCP setup.
Discover the tool by capability, not a host-specific identifier.
The service needs no API key or local runtime and documents no version selector.

| Argument    | Use                                         |
| ----------- | ------------------------------------------- |
| `json`      | Prepared sample encoded as a JSON string.   |
| `language`  | `schema` or the consumer's target language. |
| `typeName`  | Root model name.                            |
| `justTypes` | Types without serializers, where supported. |

1. Prepare small, varied samples without sensitive values, preserving relevant types and structure.
2. Send the samples to the hosted tool using the [inference example](examples.md#candidate-inference).
3. Review required fields, nullability, formats, and additional-property constraints against producer evidence.
4. Inspect the emitted dialect, which can be draft-06, before conversion to draft 2020-12.
5. Check keyword semantics, definition references, and root shape during conversion.
6. Validate the converted schema against its metaschema and representative valid and invalid instances.

Changing `$schema` alone does not establish a correct conversion.
Generated types do not replace runtime validation.

See [MCP setup](https://mcp.quicktype.io/), the [Quicktype schema workflow](https://github.com/glideapps/quicktype), and [plugin packaging](https://developers.openai.com/plugins/build/plugins).

## Bazel

Prefer [jq.bzl](https://github.com/bazel-contrib/jq.bzl) for suitable Bazel JSON transformations.
Check the pinned dependency's rule API before adding a target.
Declare source files, filters, and outputs as build dependencies.
Reuse the configured jq toolchain instead of a host binary in an ad hoc shell action.
Use reusable jq filters when the rule supports them.
