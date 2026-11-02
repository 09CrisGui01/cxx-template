# ASR 0006: Optional coverage measurement

- **Status:** Accepted
- **Date:** 2026-11-01
- **Verification status:** Partially met

## Context

The specification requires an optional coverage workflow, separate from normal Debug and Release
builds, with predictable report locations, reports kept out of version control and a configurable
threshold that the untouched template does not fail.

## Requirement

Quality attribute: testability and simplicity of the build. A normal configure, build and test
MUST NOT instrument code, MUST NOT need coverage tools and MUST NOT write coverage data. Coverage
MUST run only on request, MUST write its reports under `<build dir>/coverage/` and MUST fail on a
minimum line coverage only when `PROJECT_COVERAGE_MIN_LINE` is set above 0.

## Verification

- Linux, GCC 13.3: `cmake --preset coverage` and `cmake --build --preset coverage-report` ran the 19 tests and wrote the HTML and Cobertura reports.
- Linux, Clang 18.1: the same with `--target coverage` wrote HTML and LCOV reports.
- Threshold: with `PROJECT_COVERAGE_MIN_LINE=90` both passed; with 99 both failed with the reports written.
- The default build (`alpha` preset) contained no `--coverage` option in its build commands.
- A missing `gcovr` produced a configure warning and no `coverage` target.
- Not verified: macOS, Windows and FreeBSD; Apple Clang; the GitHub `coverage` job; a clean machine without the Clang profile runtime other than the observed link failure; report content beyond reading the terminal summary and listing the output files.

## Alternatives considered

- **Coverage always on in Debug:** simpler, but slows every build and needs the tools everywhere. Not chosen.
- **A fixed threshold:** rejected by the specification.

## Consequences and trade-offs

- A coverage figure is a measurement only; see [Coverage](../../testing/coverage.md).
- Every new executable that tests run MUST be added to the `coverage` target by hand.

## Related decisions

[ADR 0008](../decisions/0008-coverage-with-gcovr-and-llvm-cov.md),
[ASR 0002](0002-minimal-core-toolchain.md), [ASR 0005](0005-deterministic-self-contained-tests.md)
