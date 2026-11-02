# ADR 0008: Coverage with gcovr for GCC and llvm-cov for Clang

- **Status:** Accepted
- **Date:** 2026-11-01

## Context

The specification asks for an optional, compiler-aware coverage workflow: gcov-compatible
reporting for GCC and source-based coverage for Clang where practical, kept separate from normal
builds, with terminal, HTML and optionally CI-compatible XML reports, predictable locations and a
configurable threshold. The default build must not need Python or other optional tools
([ASR 0002](../requirements/0002-minimal-core-toolchain.md)).

Facts checked locally: GCC 13.3 `--coverage` and gcovr 8.8 produced terminal, HTML and Cobertura
reports; Clang 18.1 source-based coverage with `llvm-profdata` and `llvm-cov` produced terminal,
HTML and LCOV reports; `llvm-cov` has no Cobertura output; linking Clang-instrumented programs needs
the compiler-rt profile library, which was not installed by default.

## Decision

- Coverage is off unless `PROJECT_ENABLE_COVERAGE` is ON, set by the `coverage` preset. Instrumentation is applied per target by `project_set_coverage()` in `tool/cmake/Coverage.cmake`.
- GCC uses `--coverage`, `gcov` and gcovr. Clang uses source-based coverage with `llvm-profdata` and `llvm-cov`.
- One CMake script, `tool/cmake/RunCoverage.cmake`, runs the tests and writes the reports, driven by a `coverage` target. It runs on every host that has CMake, so no shell and PowerShell variants are needed.
- Reports go to `<build dir>/coverage/`, which Git already ignores. The threshold is `PROJECT_COVERAGE_MIN_LINE`, default 0 (disabled).
- MSVC is not supported; enabling coverage with it is a configure error.

## Alternatives considered

- **gcovr for both compilers** (Clang through `llvm-cov gcov`): one tool and Cobertura for both, but it is not Clang's source-based coverage, which the specification names. Not chosen.
- **lcov and genhtml:** another tool with no capability gcovr lacks here, and not installed locally. Not chosen.
- **Shell and PowerShell scripts in `script/`:** two implementations to keep equal. A CMake script has one. Not chosen.
- **A fixed threshold:** the specification forbids a threshold that makes the untouched template fail. Not chosen.

## Consequences and trade-offs

- Percentages from the two toolchains differ because they count lines differently; they are not comparable across tools.
- Cobertura XML exists only for GCC.
- gcovr needs Python and Clang needs the profile runtime package, both documented as optional prerequisites.
- Coverage is measured only for code under `internal/`; a new source directory needs the filter in `RunCoverage.cmake` changed.
- The `coverage` target runs `ctest` itself, so it repeats a test run done separately.
- `llvm-cov` prints a "mismatched data" warning for one function; see [Coverage](../../testing/coverage.md#troubleshooting).
- The `coverage` preset name is not a stage name (`alpha`, `beta`, `gamma`), like `msvc`.
