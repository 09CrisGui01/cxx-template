# ASR 0007: Tool findings fail the run

- **Status:** Accepted
- **Date:** 2026-11-01
- **Verification status:** Partially met

## Context

The specification forbids suppressing warnings or findings to make CI pass. A tool that only prints
a finding lets a defective change pass.

## Requirement

Quality attribute: reliability and security. When an optional quality tool is enabled, a finding
MUST make the build or the test run fail with a nonzero exit status: a clang-tidy finding fails the
build, a `format-check` difference fails the target, and an AddressSanitizer, UndefinedBehaviorSanitizer
or ThreadSanitizer finding fails the test.

## Verification

- Linux, GCC 13.3 and Clang 18.1: a deliberately added use-after-move made the `tidy` build fail with `bugprone-use-after-move`.
- A deliberate extra space made `format-check` fail with exit status 1.
- Deliberate faults in a test case: a heap overflow and a signed integer overflow failed under `sanitize` (exit status 1), and a data race failed under `tsan` (exit status 66), with both compilers. Each fault was removed afterwards.
- Not verified: macOS, Windows, FreeBSD; ThreadSanitizer on real concurrent production code (the example has none); the CI `quality` job on GitHub.

## Alternatives considered

- **Report only:** findings would be easy to overlook. Not chosen.
- **A baseline of accepted findings:** useful for an existing code base, not for a new template. Not chosen.

## Consequences and trade-offs

- A new finding blocks the build until fixed; a false positive in third-party code needs a documented, narrow check exclusion, as in `test/.clang-tidy`.
- Tool upgrades can introduce new findings.

## Related decisions

[ADR 0009](../decisions/0009-optional-quality-tools-as-cmake-modules.md),
[ASR 0003](0003-bounded-untrusted-input.md)
