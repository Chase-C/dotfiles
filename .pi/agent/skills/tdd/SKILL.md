---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

This skill is for implementing tasks with specific, verifiable behavior — features, bug fixes, or any work where "done" means the code does a particular thing that can be checked. The deliverable is the working implementation; tests are the means by which you specify behavior precisely and confirm the result is correct. TDD orders the work so behavior is defined before code, one piece at a time.

## Strategy

Each test moves through two states:

- **RED**: A new test exists and fails.
- **GREEN**: All tests pass — achieved by writing the minimum code needed.

Each test is its own RED → GREEN cycle. After every test has cycled, a single REFACTOR pass improves the code without changing behavior.

Writing the test first forces you to define what "working" means before writing code. This keeps tests honest (they catch real regressions) and keeps implementation minimal (no speculative features).

RED → GREEN cycles must be vertical, not horizontal:

```
RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  ...

WRONG (horizontal):
  RED:   test1, test2, test3, test4
  GREEN: impl1, impl2, impl3, impl4
```

Writing all tests before any implementation produces tests of imagined behavior (data shapes, signatures) rather than actual behavior. They become insensitive to real changes — passing when behavior is broken, failing when behavior is fine.

## Preconditions

This skill assumes the user has already specified:

- The public interface to build (function signatures, API shapes)
- Which behaviors to test, in priority order

If either is missing or unclear, stop and request the missing information. Do not invent these — they are inputs to the process, not decisions this skill makes.

## Workflow

### Step 1: Tracer bullet (first cycle)

Pick the most fundamental behavior from the priority list and write a happy-path test for it. Run one full RED → GREEN cycle:

1. Write the test. Run it. It must fail.
2. Write the minimum code to pass. Run it. It must pass.

This proves the path works end-to-end before committing to more.

### Step 2: Iterate (one cycle per test)

Continue writing tests one at a time. For each test, complete every step below before starting the next:

1. Write ONE test
2. Run it — confirm it fails for the right reason
3. Write minimal code to pass
4. Run all tests — confirm they pass

> **When a test passes on first run.** This happens when you're adding tests for behavior that existing code already handles. Don't fake a failure by writing broken code — instead, verify the test has signal:
>
> 1. Mutate the implementation
> 2. Run the test — it should now fail
> 3. Revert the mutation
>
> If the mutation didn't cause the test to fail, the test is wrong — fix it. Otherwise GREEN is a no-op; move on.

A behavior may warrant multiple tests covering different aspects (happy path, edge cases, error conditions). Take them one at a time.

Guidelines:

- One test at a time. Never write multiple failing tests at once.
- Only enough code to pass the current test. Don't anticipate future tests.
- Tests describe what the system does, not how.
- Do not refactor during this step. Save it for Step 3.

### Step 3: Final refactor pass

After all behaviors are tested, and all tests pass, look for refactor candidates:

- **Duplication** → Extract function/class
- **Long methods** → Break into private helpers (keep tests on public interface)
- **Shallow modules** → Combine or deepen into [deep-modules](deep-modules.md)
- **Feature envy** → Move logic to where data lives
- **Primitive obsession** → Introduce value objects
- **Existing code** the new code reveals as problematic

Run tests after each change. Never refactor while RED — if a test breaks, figure out what went wrong and fix it.

When finished, report to the user:

- Which behaviors are tested
- What refactors were applied
- Any decisions made that the user should review

## Writing Good Tests

Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests should not.

**Good tests** read like specifications. "User can checkout with valid cart" tells you exactly what capability exists. They exercise real code paths through public APIs. They survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify state through side channels (like querying a database when there's an interface). Warning sign: your test breaks when you refactor, but behavior hasn't changed.

See [tests](tests.md) for examples and [mocking](mocking.md) for mocking guidelines.
