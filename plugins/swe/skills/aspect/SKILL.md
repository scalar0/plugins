---
name: aspect
description: Run Aspect CLI tasks, configure AXL, and diagnose build results in Aspect repositories.
---

# Aspect

## Discover and execute

1. Read repository instructions, `.aspect/config.axl` and the modules it composes.
2. Run `aspect describe` to list available tasks in structured JSON.
3. Run `aspect describe '<command>'` for the task's description in structured JSON.

Use repository recipes when they wrap the required task.
Report the command, target scope, result, and unresolved failures.

| Request                        | Workflow                                                                                     |
| ------------------------------ | -------------------------------------------------------------------------------------------- |
| build, test, run, format, lint | Use `aspect build,test,run,format,lint` with affected labels and verified argument handling. |
| Generate BUILD files           | Run `aspect gazelle`, then review its diff.                                                  |
| Select affected tests          | Read [Affected tests](references/tasks.md#affected-tests).                                   |
| Configure AXL                  | Read [AXL composition](references/tasks.md#axl-composition).                                 |
| Diagnose recorded results      | Read [Build results](references/build-results.md).                                           |
| CRUD worktrees                 | Use [aspect-worktree](../aspect-worktree/SKILL.md) before operations.                        |

## MCP servers

| Server        | Use                                               | Requirements                                             |
| ------------- | ------------------------------------------------- | -------------------------------------------------------- |
| `aspect-docs` | Current documentation and AXL APIs.               | Network access.                                          |
| `aspect`      | Read recorded build results through `aspect mcp`. | Aspect executable, stored login, API-enabled deployment. |

Discover available tools and input schemas before calls.
If documentation tools are unavailable, use [the documentation index](https://aspect.build/llms.txt).
Execute tasks through the CLI because the build-results server cannot start builds.
Continue independent local work if a server is unavailable.

Sources: [CLI discovery](https://aspect.build/docs/cli/guides/agents) and [documentation MCP](https://aspect.build/docs/cli/guides/mcp).
