---
name: do-plan
description: Create implementation plans, with structured JSON, only when the user requests a plan in JSON format for automated processing.
---

# Do Plan

Use the user's requirements and relevant repository context to define the work.
Fetch referenced issue content only when the plan needs information that the user has not supplied.
Use available issue tools or the GitHub CLI without requiring another skill.

Include actionable tasks, dependencies, completion checks, and material risks.
Use phases and detailed steps only when they help explain the work.
Identify missing decisions that affect scope or implementation.

## Output

| Request                         | Output                                                                                       |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| Markdown or no specified format | A plan whose structure and detail match the task.                                            |
| JSON                            | A plan that follows [schema.json](assets/schema.json). Load the schema only for this format. |

Return the plan in the conversation unless the user requests a file.
For file output, use the requested path.
Check dependency references and completion conditions before delivery.
