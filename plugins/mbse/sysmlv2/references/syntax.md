# SysML v2 textual syntax essentials

## Comments and documentation

- Line note: `// <text>`
- Block note: `//* <text> */`
- Comment: `/* <text> */`
- Documentation: `doc /* <text> */`

## Core declaration patterns

- Definition: `<kind> def <Name>`
- Usage: `<kind> <name> : <Type>`
- Specialization / subsetting: `<member> :> <base>`
- Redefinition: `:>> <property>`
- Import: `<visibility> import <name>`
- Alias: `alias <Short> for <Qualified::Name>;`

## Common operators

### `:` — typing / defined by

Use for the ordinary typed relationship.

Examples:

- `part vehicle : Vehicle`
- `attribute mass : MassValue`
- `subject vehicle : Vehicle`

### `:>` — specialization or subsetting

Use for specialization and subsetting relationships shown in the cheat sheet.

Examples:

- `part def SportsCar :> Vehicle`
- `part engine1 [1] :> engines`
- `attribute fuelMass :> ISQ::mass`

### `:>>` — redefinition

Use when redefining or overriding an inherited property/value.

Examples:

- `:>> wheels = 4`
- `attribute :>> massActual = vehicle.mass`

### `::>` — bound / referenced target

Use for explicit reference binding, such as connection ends bound to existing elements.

Examples:

- `end part hub ::> mainSwitch`
- `end part device ::> sensorFeed`

## Multiplicity and qualification

- Multiplicity range: `<name> [<lower>..<upper>]`
- Fixed multiplicity: `<name> [<count>]`
- Qualified name: `<namespace>::<member>`

Examples:

- `Wheel [0..*]`
- `wheel [4] : Wheel`
- `ISQ::MassValue`

## Expression snippets

- Assignment: `<target> = <value>`
- Comparison operators: `< <= == != >= > === !==`
- Metadata: `@<metadata>`
- User-defined keyword: `#<keyword>`

Examples:

- `mass = 1500 [kg]`
- `tank.fuelLevel == tank.maxFuelLevel`
- `@ToolMetadata`
- `#cause 'Short Circuit'`

## Import and visibility guidance

- Use `public import` when imported names should remain exposed as part of the package surface.
- Use `private import` when imported names are only needed internally.
- Prefer aliases when a qualified name is repeated often.

## Shorthand notes from the cheat sheet

The cheat sheet explicitly highlights shorthand support for:

- `:` as defined by
- `:>` as specializes
- `:>>` as redefines

It also notes a shorthand caveat:

- `a:b,c` is allowed
- `a::>b,c` is not allowed

## Practical advice

- Prefer short, explicit declarations over overly compressed syntax when generating examples for a user.
- If external quantity/value types are used, import or qualify them explicitly.
- When in doubt, favor readable qualified names and explicit bindings.
