---
name: convert-to-sysml
description: Convert structured engineering-document JSON, typically produced by mbse/datasheet-extract, into SysML v2 structural code. Use when the input is already extracted JSON and the goal is a traceable structural model.
---

# Convert Extracted JSON to SysML v2

## Overview

Use this skill when the task is to convert structured engineering-document JSON into SysML v2 structural code.

The primary input is the contract-conformant JSON produced by `../datasheet-extract/SKILL.md`, using the machine-readable schema at `../datasheet-extract/assets/contract.schema.json`.

That schema is intentionally loose inside the extracted payload. Rely on the stable wrapper fields, not on one fixed internal taxonomy for `data`.

This skill is for:

- consuming extracted JSON rather than parsing PDFs directly;
- flattening the extracted `data` object into candidate facts;
- separating structure from behavior, requirements, compliance, and ambiguity;
- mapping structural facts into minimal SysML v2 constructs;
- preserving traceability back to JSON paths and `metadata`.

Do not use this skill for:

- direct PDF or image ingestion as the normal path — first use `../datasheet-extract/SKILL.md`;
- tool installation or project management questions about Sysand — use `../sysand/SKILL.md` instead;
- pure SysML v2 notation authoring when the structure is already fully decided — use `../sysmlv2/SKILL.md` instead;
- behavior modeling, requirement authoring, or ACE reformulation.

## Input Contract

Expect input that conforms to `../datasheet-extract/assets/contract.schema.json` and includes exactly two wrapper fields: `data` and `metadata`.

Treat the internal shape of `data` as document-specific. Do not assume one fixed section list or one fixed nesting pattern.

Relevant `metadata` fields include `source_file`, `pages_used`, and `notes` — see the schema for the full set.

If the user provides a raw PDF or other source document instead of contract-conformant JSON, redirect to `../datasheet-extract/SKILL.md` first.

## Default Workflow

1. Confirm the input contract and identify the subject.
    - Derive a subject label from `metadata.source_file` (stem, no path or extension) or from a prominent key at the top of `data`.
    - Read `data` as the modeling input.
    - Keep `metadata` for provenance, cautions, and page references.
2. Establish the modeling boundary.
    - Are we modeling a reusable definition or a specific usage?
    - Is the source only strong enough for a black-box view, or does it justify internal parts too?
3. Flatten `data` into candidate facts.
    - Represent each leaf or structured cluster as a fact with a path, label, value, and section context.
    - Use path arrays from the contract for traceability.
4. Triage the facts.
    - Structure → candidate parts, ports, items, connections, attributes.
    - Behavior / requirements / compliance → defer unless the user explicitly asked for them.
    - Ambiguous claims → keep conservative and mark assumptions.
5. Map structural facts into SysML constructs using this table.

    | Evidence                           | SysML construct           |
    |------------------------------------|---------------------------|
    | whole device                       | `part def`                |
    | named constituent                  | nested `part`             |
    | I/O terminal / connector / port    | `port def` + `port` usage |
    | exchanged signal or message        | `item def`                |
    | static property with units         | `attribute` with value    |
    | explicit link between endpoints    | `connection`              |

    For multiplicity: use `[N]` for exact counts, `[1]` for single confirmed instances, omit brackets when count is unknown.

    Derive SysML names from JSON keys by converting `snake_case` to `PascalCase` for `def` names and `camelCase` for usages (e.g. `rs_485_port` → `Rs485Port` / `rs485Port`).
6. Build the smallest model that fits the extracted facts.
    - Prefer black-box structure when the JSON does not justify decomposition.
    - Do not infer hidden parts from flat capability or marketing fields.
7. Produce the answer.
    - SysML v2 structural code first; embed a `// [data.path.key] "<raw value>"` comment on the line before each structural claim so every modeled element traces back to its source fact.
    - Deferred non-structural material (behavior, compliance, protocols) second.
    - Assumptions and open questions last.
8. Validate notation conservatively.
    - Follow `../sysmlv2/SKILL.md` for notation.
    - Use `sysmlv2-mcp` via that skill when available.

## Fact Extraction Heuristics

When flattening `data`, keep each candidate fact lightweight and traceable. Recommended shape: `{ "path": [...], "label": "...", "section": "...", "value": "..." }`.

Treat these as strong structure cues:

- section or key names containing `interface`, `port`, `connector`, `terminal`, `io`, `input`, `output`, `bus`, `network storage`, `rs-485`, `ethernet`
- explicit counts such as `1 RJ45`, `2 CAN ports`, `8 digital inputs`
- physical properties such as dimensions, mass, material, voltage range, storage size
- named contained units explicitly presented as constituents

Treat these cautiously or defer them:

- protocols, codecs, browser support, clients, APIs
- frame rate, update rate, timing, DORI, sensing range
- approvals, IP ratings, EMC, safety, compliance listings
- event and smart-function catalogs unless they clearly imply an interface or exchanged item
- marketing bullets that do not establish structure

## Traceability Discipline

Embed traceability directly in the SysML output as `// [data.path.key] "<raw value>"` line comments before each structural claim. Supplement with `metadata.source_file` and `metadata.pages_used` in a package-level comment when they add useful provenance context. Record `metadata.notes` entries as open questions or assumptions if they flag ambiguity.

If multiple interpretations are plausible, choose the smaller structural commitment and mark it as an inference.

## Quality Gates

Before finishing, check that:

- the input is treated as contract-conformant JSON, not as raw document layout;
- every structural claim traces back to a JSON path, optionally supplemented by `metadata`;
- black-box vs internal structure is not mixed accidentally;
- ports are distinguished from exchanged items and protocol lists;
- connections are introduced only when endpoints or attachment intent are evidenced;
- multiplicities come from explicit counts, not guesswork;
- behavior, requirements, and compliance are separated into deferred notes when they are not structural;
- the resulting structure is minimal, coherent, and does not invent hidden parts;
- the final answer includes SysML v2 structural code, not only prose.

## Minimal Worked Example

Input:

```json
{
  "data": {
    "interfaces": {
      "ethernet": "1 × RJ45 100 M self-adaptive",
      "rs_485": "2 ports, 2-wire"
    },
    "general": { "weight_kg": 0.35 }
  },
  "metadata": { "source_file": "acme-encoder-ds.pdf", "pages_used": [3] }
}
```

Extracted facts:
- `["data","interfaces","ethernet"]` → port, 1×, RJ45
- `["data","interfaces","rs_485"]` → port, 2×, RS-485
- `["data","general","weight_kg"]` → attribute, 0.35 kg

SysML output:

```sysml
// source: acme-encoder-ds.pdf, p. 3
package AcmeEncoderDs {
    private import SI::*;

    port def EthernetPort;
    port def Rs485Port;

    part def AcmeEncoder {
        // [data.general.weight_kg] 0.35
        attribute weightKg : Real = 0.35 [kg];

        // [data.interfaces.ethernet] "1 × RJ45 100 M self-adaptive"
        port ethernet : EthernetPort[1];

        // [data.interfaces.rs_485] "2 ports, 2-wire"
        port rs485 : Rs485Port[2];
    }
}
```

Deferred: protocol details (self-adaptive negotiation, 2-wire variant) — not structural.

## Quick References

Load the smallest reference that matches the task:

- `../datasheet-extract/assets/contract.schema.json` — stable input contract shared with `datasheet-extract`
- `../sysmlv2/references/construct-patterns.md` — structural construct patterns for parts, ports, items, and connections
