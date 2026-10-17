# Build results

## Diagnose a recorded result

1. Discover the server tools and their input schemas.
2. Use `list_invocations` to find the requested build by repository, status, or Bazel invocation UUID.
3. Use the returned build `id` for later calls.
4. Read `get_invocation` and `tail_build_log` to locate the failure.
5. Read failed targets with `list_invocation_targets` and `get_target` as needed.
6. For a flake or regression, compare target history with `list_target_invocations` and `get_target_stats`.
7. Report the build, target, observed failure, and evidence for the proposed fix.

A Bazel invocation UUID is not the build `id`.
Use local CLI builds or tests to validate a fix when authorized.

## Connection failures

Run `aspect auth status --output=json` to inspect login state and the selected deployment.
For an authentication failure, report the returned `login_command`.
For an unavailable API, report the deployment requirement from the server error.
Change deployment selection only when the task requires it.

Source: [aspect mcp](https://aspect.build/docs/cli/tasks/mcp).
