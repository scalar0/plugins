# MCP Capabilities for `gt`

## Available Graphite MCP tools

- `mcp__graphite__learn_gt`
    - Return a practical guide for stacked PR workflows and common command usage.
    - Use for command selection and workflow reminders before execution.

- `mcp__graphite__run_gt_cmd`
    - Execute Graphite CLI (`gt`) commands.
    - Required inputs:
        - `args`: tokenized argument list, for example `["submit", "--stack"]`
        - `cwd`: absolute repository path
        - `why`: one-line reason for the command

## Operational constraints to preserve

1. Present stack structure before writing code for stacked PR work.
2. Write code before creating each stack branch.
3. Use `gt create` instead of `git commit`.
4. Use `gt submit --no-interactive` instead of `git push`.
5. After final submit, report the first PR link in the stack.

## Recommended MCP usage sequence

1. Call `mcp__graphite__learn_gt` if command choice is unclear.
2. Call `mcp__graphite__run_gt_cmd` with read-only commands first:

- `["log", "short"]`
- `["state"]`
- `["checkout", "<branch>"]` only if needed

3. Call mutating commands in minimal order:

- `["create", "--all", "--message", "<msg>"]`
- `["modify", "--all"]` or `["modify", "--commit", "--all", "--message", "<msg>"]`
- `["submit", "--stack", "--no-interactive"]`
- `["sync"]`, then `["restack"]`/`["continue"]` if conflicts occur

## Failure handling

- If a command fails, read the stderr text and run the smallest corrective command.
- Prefer `gt` recovery commands over raw `git` commands in stack operations.
- Use `gt abort` for interrupted restack/rebase sessions that should be canceled.
