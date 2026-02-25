---
name: do-unit-test
description: Design, add, and refactor language-agnostic unit tests that maximize confidence through isolation, determinism, and edge-case coverage. Use when improving test quality or coverage.
---

# Do Unit Test

## Overview

Write focused unit tests that verify observable behavior of a single unit without depending on external systems.

## Workflow

1. Define unit boundaries and public contracts.
2. Choose isolation strategy for collaborators (mock, stub, fake, or in-memory).
3. Select a minimal but complete behavior matrix (happy path, edges, failures).
4. Implement clear arrange-act-assert tests.
5. Remove non-determinism (network, wall-clock time, flaky filesystem state).
6. Use coverage to find meaningful gaps and add targeted tests.

## Design Rules

- Prefer public API tests over private helper tests.
- Keep tests independent and order-insensitive.
- Assert behavior instead of implementation details.
- Use table-driven style for dense input/output matrices.
- Keep fixtures minimal and local to each test where possible.

## Output Expectations

- Include tests with the code change whenever feasible.
- Explain notable isolation decisions when non-obvious.
- Do not expand into integration testing unless explicitly requested.
