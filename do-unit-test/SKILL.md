---
name: do-unit-test
description: Language-agnostic unit testing workflow and best practices. Use when Codex needs to design, add, or refactor unit tests, improve unit test coverage, or evaluate unit test quality (isolation, determinism, edge cases) across any programming language or framework.
---

# Do Unit Test

## Overview

Design and implement unit tests that are isolated, deterministic, and focused on a single unit's behavior while maximizing meaningful coverage.

## Workflow

1. Identify unit boundaries and public contracts (inputs, outputs, side effects).
2. Inventory collaborators and decide isolation strategy (mock, stub, fake, in-memory, or real).
3. Define a minimal set of behaviors to test (happy path, edge cases, error paths).
4. Implement tests with clear arrangement, action, and assertions.
5. Validate determinism and remove external dependencies (network, time, filesystem) unless explicitly required.
6. Review coverage and add targeted tests for missed branches or error handling.

## Design Checklist

- Prefer testing public APIs; test private helpers only when behavior is not observable.
- Use table-driven tests for input/output matrices.
- Name tests with intent: `when_<condition>_then_<result>` or `it_<does_behavior>`.
- Keep tests independent and order-insensitive.
- Assert on behavior, not implementation details.
- Minimize shared mutable fixtures; use per-test setup.
- Favor small, focused tests over large scenario tests.

## Isolation Techniques

| Technique      | Best For                          | Risks                         | Notes                                        |
| -------------- | --------------------------------- | ----------------------------- | -------------------------------------------- |
| Mock           | Verifying interactions            | Overfitting to implementation | Use to assert calls, arguments, and counts.  |
| Stub           | Returning canned data             | Missing integration issues    | Use to force deterministic branches.         |
| Fake           | Lightweight in-memory replacement | Divergence from real system   | Use for caches, repositories, queues.        |
| In-memory real | Pure logic with no I/O            | None                          | Prefer when dependencies are simple structs. |

## Coverage Guidance

- Target meaningful coverage by exercising branches and error paths.
- Avoid brittle tests that only satisfy coverage tools.
- Use coverage reports to find untested logic, then add focused tests.

## Output Expectations

- Provide updated or new unit tests alongside code changes.
- Explain isolation choices and test scope in commit notes or summaries when needed.
- Avoid integration tests unless explicitly requested.
