# Diagram scope

Choose the diagram's abstraction before its notation.
A correct parser result cannot establish correct scope or relationships.

## Select the owning boundary

| Question                                                            | Useful view                      |
| ------------------------------------------------------------------- | -------------------------------- |
| Who interacts with this system?                                     | System context                   |
| Which applications or data stores communicate?                      | Runtime structure and interfaces |
| How do immediate responsibilities interact inside this boundary?    | Component or subsystem structure |
| Which concrete types, functions, or interfaces explain this design? | Selective code view              |
| Where do order, cancellation, or failure change the result?         | Dynamic or state view            |

Keep a code view in subsystem architecture when it explains a boundary-wide seam, ownership rule, or interaction contract.
Move a view of one module's internal state or algorithm beside that module.
Use a responsibility table when it conveys the necessary relationships more clearly.
Do not create a concrete code diagram merely to fill a documentation tier.

Show actual declarations and relationships, with source references.
Distinguish value ownership, shared references, API dependencies, trait implementation, and inheritance according to the language's semantics.
Omit fields and method signatures that only repeat declarations.
Show functions, modules, or data relationships directly when class notation would imply objects that do not exist.
A module dependency graph alone may omit the code relationships the reader needs.

## Respect the chosen model

When the repository uses [C4](https://c4model.com/), map its levels to logical and runtime boundaries rather than directories.
Libraries execute within consumers, while build and test tools may need separate supporting views.
Use the [C4 code guidance](https://c4model.com/diagrams/code) for selective code detail within a component.

Follow the repository's renderer and notation conventions.
For Mermaid C4 views, evaluate native `C4Context`, `C4Container`, and `C4Component` syntax before substituting generic flowcharts.
The [Mermaid C4 reference](https://mermaid.ai/open-source/syntax/c4.html) defines supported syntax.
Use class, sequence, state, or other diagrams where they express the intended relationship accurately.
C4 is not a requirement to adopt when the user requests only a scope review.

## Check the result

Give each diagram a clear subject and scope.
Make element roles, relationship direction, and notation understandable.
Check that relocated diagrams retain accessible source links and adequate context.
Parse diagrams with the available renderer or parser when possible.
Render and inspect diagrams when layout or presentation requires validation.
State any validation limitation instead of claiming parser success proves visual readability.
Use temporary validation tools when appropriate without adding unrequested repository dependencies.
