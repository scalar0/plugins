---
name: sysmlv2
description: Write or revise SysML v2 in textual notation. Use when asked to generate SysML v2 text, model packages, parts, items, connections, ports, actions, constraints, or requirements, or when translating modeling intent into textual SysML syntax. Helps choose between definitions and usages, apply operators like `:`, `:>`, `:>>`, and `::>`, organize imports and packages, keep notation structurally consistent, and reference short local indexes of standard SysML/domain libraries and official training examples (excluding KerML Kernel libraries).
---

# SysML v2 Textual Notation

## Overview

Use this skill when the task is to write, extend, or fix SysML v2 in textual notation.

This skill is for:

- generating compact but valid-looking SysML v2 text from modeling intent;
- choosing the correct construct form for packages, parts, items, ports, connections, actions, constraints, and requirements;
- using common textual operators correctly;
- keeping definitions, usages, imports, and references internally consistent;
- selecting existing standard/domain library namespaces from a local index of `sysml.library` (excluding KerML/Kernel libraries);
- finding official SysML v2 training examples quickly via a lightweight index of the `SysML-v2-Pilot-Implementation` training set.

This skill is grounded in the Sensmetry SysML v2 textual notation cheat sheet and its downloadable example model, which are based on the SysML v2.0 Beta 4 notation examples shown there.

When the `sysmlv2-mcp` server is available, treat it as the primary source for language-server style validation and inspection: parsing, diagnostics, symbol lookup, and other syntax-checking assistance should come from that server before finalizing output. If the server is unavailable, say so explicitly and fall back to conservative notation without claiming validation.

## When to Use

Use this skill when the user asks for any of the following:

- “write SysML v2 text for this model”;
- “convert this idea into textual SysML”;
- “create a package / part / item / port / connection / action / requirement in SysML v2”;
- “fix my textual notation syntax”;
- “show the right operator for specialization, redefinition, or reference binding”.

Do not use this skill for:

- tool installation or package management questions about Sysand — use `../sysand/SKILL.md` instead;
- authoritative conformance claims beyond the cheat-sheet guidance available in this skill.

## Writing Workflow

1. Identify the modeling goal.
    - Is the user defining a reusable type, declaring a usage, constraining behavior, or organizing a package?
2. Choose the construct category.
    - Structural: package, part, item, port, connection.
    - Behavioral: action, perform action, state.
    - Analytical/compliance: constraint, requirement, satisfy.
3. Decide whether each element is a definition or a usage.
    - Reusable type → `<kind> def <Name>`.
    - Declared member/instance/occurrence → `<kind> <name> : <Type>`.
4. Add relationships using the smallest correct operator.
    - Typing / defined-by: `:`
    - Specialization / subsetting: `:>`
    - Redefinition: `:>>`
    - Reference binding to an existing element: `::>`
5. Add namespace organization.
    - Create a package when the user is defining a model scope.
    - Add imports or aliases when external names are referenced repeatedly.
    - For standard SysML or domain library imports, consult `./references/sysml-library-index.md` first (and do not pull from `Kernel Libraries`).
6. Fill in attributes, ends, ports, subjects, inputs, outputs, or bindings.
7. Check consistency before finalizing.
    - Are referenced types defined or imported?
    - Are usages typed?
    - Are redefinitions applied only where inherited features exist?
    - Are connection ends and requirement bindings explicit?
    - If `sysmlv2-mcp` is available, validate syntax and symbol references with it before responding.
8. Return the SysML v2 text, and briefly explain any modeling assumptions if they were not provided.

## Decision Rules

### Definition vs usage

- Use `<kind> def <Name>` when introducing a reusable classifier or definition.
- Use `<kind> <name> : <Type>` when declaring a concrete usage/member typed by an existing definition.

### Specialization vs redefinition

- Use `:>` when one definition specializes another.
- Use `:>>` when overriding or redefining an inherited feature or assigning a replacement value/property.

### Reference binding

- Use `::>` for qualified or bound references such as connection ends pointing to existing items/parts.

### Packages and imports

- Use `package <Name> { ... }` to group related declarations.
- Use `public import` when the imported namespace should remain visible to downstream users.
- Use `private import` when the import is only an internal dependency.
- Use `alias <Short> for <Qualified::Name>;` to shorten repeated qualified names.

## Quality Gates

Before finishing, make sure the output satisfies these checks:

- The construct kind matches the modeling intent.
- Definitions appear before or are import-accessible to their usages.
- Operators are used consistently:
    - `:` for typing,
    - `:>` for specialization/subsetting,
    - `:>>` for redefinition,
    - `::>` for bound references.
- Qualified names use `Namespace::Member` syntax.
- Requirement and constraint usages bind their inputs or attributes explicitly.
- If `sysmlv2-mcp` is available, use its language-server features to validate syntax, bindings, and symbol references rather than relying on guesswork.
- If the model uses external quantity/value types, the needed imports or assumptions are clear.

## Core Patterns

### Minimal package

```sysml
package VehicleModel {
    public import VehicleParts;
    private import ISQ::MassValue;
    private import SI::*;
}
```

### Definition and usage

```sysml
part def Vehicle {
    attribute mass : MassValue;
}

part vehicle : Vehicle {
    :>> mass = 1500 [kg];
}
```

### Specialization

```sysml
part def SportsCar :> Vehicle {
    :>> wheels = 4;
}
```

### Connection end binding

```sysml
connection conn : DeviceConn {
    end part hub ::> mainSwitch;
    end part device ::> sensorFeed;
}
```

### Requirement usage

```sysml
requirement <R1> vehicleMass : MassRequirement {
    attribute :>> massActual = vehicle.mass;
    attribute :>> massLimit = 1800 [kg];
}
```

## References

Load the smallest reference that matches the task:

- `./references/syntax.md` — operators, shorthand, comments, imports, multiplicity, and common expression forms
- `./references/construct-patterns.md` — package, part, item, port, connection, action, state, constraint, and requirement patterns
- `./references/writing-checklist.md` — step-by-step generation and review checklist for textual SysML output
- `./references/sysml-library-index.md` — short local index of standard SysML + domain libraries from `SysML-v2-Release/sysml.library` (excludes KerML `Kernel Libraries`)
- `./references/training-example-index.md` — lightweight index of official SysML v2 training examples from `SysML-v2-Pilot-Implementation/sysml/src/training`

## Source Material

Primary source: `https://sensmetry.com/sysml-cheatsheet/`
Related source used for concrete examples: `https://sensmetry.com/sysml-cheatsheet/downloads/sysmlv2-cheatsheet-examples.sysml`
Official training examples index source: `https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/tree/master/sysml/src/training`
