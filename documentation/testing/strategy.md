# Testing strategy

**Purpose:** say what the project tests, at which level, and which commands run which checks. The
procedures are in [Unit and integration tests](unit-and-integration-tests.md) and
[Coverage](coverage.md); this page does not repeat them.

## Levels

| Level | Tool | Where | What it checks |
|-------|------|-------|----------------|
| Unit | Catch2 ([ADR 0002](../architecture/decisions/0002-catch2-test-framework.md)) | `test/config_test.cpp` | The `app_core` library: valid input, invalid input, boundaries of every limit, file failures, platform behavior |
| Integration | CTest running the real `app` | `test/CMakeLists.txt` | Exit status, output text and argument handling of the executable |
| Coverage | gcov and gcovr, or llvm-cov | `tool/cmake/Coverage.cmake` | Which lines the two levels above execute. A measurement, not a test. |
| Sanitizers | ASan, UBSan, TSan | `sanitize` and `tsan` presets | Memory errors, undefined behavior and data races while the tests run. See [Sanitizers](sanitizers.md). |
| Static analysis | clang-format, clang-tidy | `format-check` target, `tidy` preset | Style and code defects without running anything. See [Formatting, static analysis and warnings](../tooling/static-analysis.md). |

Commands: `cmake --preset sanitize`, `cmake --build --preset sanitize`, `ctest --preset sanitize`; `cmake --preset tidy`, `cmake --build --preset tidy`.

## Rules

- Every behavior change MUST come with a test, and every bug fix with a regression test that fails without the fix ([Coding standards](../development/coding-standards.md#testing-expectations)).
- Tests MUST be deterministic, MUST NOT need the network and MUST NOT depend on files other than the ones they create and the tracked sample `configuration/default.conf` ([ASR 0005](../architecture/requirements/0005-deterministic-self-contained-tests.md)).
- A failing test MUST make `ctest` exit nonzero. This was verified: see [Unit and integration tests](unit-and-integration-tests.md#a-failing-test-fails-the-build).
- Coverage is a measurement of what tests execute. It is not evidence that the code is correct or secure ([ASR 0006](../architecture/requirements/0006-optional-coverage-measurement.md)).

## Commands

| Goal | Command |
|------|---------|
| Run all tests | `cmake --preset beta`, `cmake --build --preset beta`, `ctest --preset beta` |
| Run all tests and measure coverage | `cmake --preset coverage`, `cmake --build --preset coverage-report` |

## Related

[Unit and integration tests](unit-and-integration-tests.md), [Coverage](coverage.md),
[Architecture overview](../architecture/overview.md#test-architecture)
