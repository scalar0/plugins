# SysML v2 writing checklist

## Use this checklist when generating or reviewing textual SysML

### 1. Start from intent

- What is the user trying to model: structure, behavior, interface, rule, or requirement?
- Which named elements are reusable definitions, and which are usages?

### 2. Set up scope

- Create a `package` when the snippet needs a namespace.
- Add `public import` / `private import` or aliases for reused external names.
- If values like `1500 [kg]` or `ISQ::MassValue` appear, ensure the needed units/value types are imported or the assumption is stated.

### 3. Choose the right construct

- Reusable type → `<kind> def <Name>`
- Typed member/instance → `<kind> <name> : <Type>`
- Specialized type/member → `:>`
- Redefined inherited feature → `:>>`
- Bound existing target/reference → `::>`

### 4. Write the body

- Add attributes, ends, ports, actions, states, subjects, or bindings explicitly.
- Keep names consistent and scoped.
- Prefer smaller complete examples over sprawling incomplete ones.

### 5. Check operator correctness

- `:` for typing
- `:>` for specialization/subsetting
- `:>>` for redefinition
- `::>` for reference binding

### 6. Check dependency consistency

- Every referenced type is either defined earlier, imported, or qualified.
- Every connection end points to an element that exists in scope.
- Every constraint usage binds required inputs.
- Every requirement usage sets or redefines the expected attributes.

### 7. Keep the answer useful

- Return the SysML text first when the user clearly wants code.
- Briefly explain assumptions after the snippet, not before it.
- If the modeling intent is ambiguous, choose a minimal plausible structure and say what you assumed.

## Common pitfalls

- Using a usage where a definition is needed
- Using `:>>` without an inherited feature to redefine
- Referencing external types without import or qualification
- Leaving connection endpoints or constraint inputs unbound
- Mixing package organization with unrelated modeling details in one tiny example

## Good output qualities

- Internally consistent names and types
- Small but complete snippets
- Explicit imports or assumptions
- Operators used deliberately rather than approximately
- Examples shaped like the cheat-sheet patterns instead of invented notation
