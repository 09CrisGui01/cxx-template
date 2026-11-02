# ASR 0004: Multi-platform portability

- **Status:** Accepted
- **Date:** 2026-10-31
- **Verification status:** Partially met

## Context

The specification asks for a cross-platform template supporting GCC, Clang and MSVC. During
development the repository owner extended this to Linux, macOS, Windows and FreeBSD, and then
restricted the BSD family to FreeBSD only.

## Requirement

Quality attribute: portability. The default targets MUST build without warnings-as-errors failures
and pass all tests on: Linux with GCC and Clang, macOS with Apple Clang, Windows with MSVC, and
FreeBSD with its base Clang. Acceptance: the corresponding CI job passes for Debug and Release.

## Verification

- Linux, GCC 13.3 and Clang 18.1: Debug and Release built and tested locally with `-Werror`; passed.
- macOS, Windows and FreeBSD: the CI jobs for the Debug configuration passed, as reported by the repository owner. The macOS log showed an `arm64` build. Compiler versions were not recorded.
- Not verified: Release on macOS, Windows and FreeBSD; macOS on Intel; Windows on ARM or 32-bit; OpenBSD and NetBSD (out of scope); mingw-w64 (not requested).

## Alternatives considered

- **Linux only:** simplest, but contradicts the specification.
- **All BSDs:** removed by the repository owner to focus on FreeBSD.

## Consequences and trade-offs

- Code MUST avoid library behavior that differs between libstdc++, libc++ and the MSVC STL. Past failures: `std::expected` missing on Clang 18 with libstdc++ ([ADR 0001](../decisions/0001-result-type-instead-of-std-expected.md)); `std::to_string` ambiguity on libc++ in a test helper.
- Platform-specific build settings are isolated in `tool/cmake/Portability.cmake` and the `msvc` preset ([ADR 0003](../decisions/0003-msvc-with-ninja-multi-config.md)).
- Build directories are separated per host OS (`build/<os>/<preset>/`) so one source tree can be built on several systems.
- The CI matrix covers Debug only; extending it to Release raises CI time.

## Related decisions

[ADR 0001](../decisions/0001-result-type-instead-of-std-expected.md), [ADR 0003](../decisions/0003-msvc-with-ninja-multi-config.md)
