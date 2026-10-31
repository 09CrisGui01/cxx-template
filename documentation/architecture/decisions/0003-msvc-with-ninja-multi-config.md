# ADR 0003: MSVC built with Ninja Multi-Config and cl

- **Status:** Accepted
- **Date:** 2026-10-31

## Context

The project specification asks for MSVC support. The first `msvc` preset used the generator
`Visual Studio 17 2022`. On the GitHub-hosted Windows runner it failed at configure with
`Generator Visual Studio 17 2022 could not find any instance of Visual Studio`, so that runner image
does not provide that Visual Studio version.

## Decision

The `msvc` preset uses `Ninja Multi-Config` with `CMAKE_CXX_COMPILER=cl`, which depends on the
compiler environment being active (an "x64 Native Tools Command Prompt", or `ilammy/msvc-dev-cmd`
in CI) and not on a specific Visual Studio version. The CI Windows job passed with this setup
(Debug), as reported by the repository owner.

## Alternatives considered

- **Visual Studio generator:** failed on the runner; ties the preset to one Visual Studio version.
- **mingw-w64 (GCC on Windows):** not requested and not implemented. It would use a different runtime and standard library than MSVC, so it would test different behavior. It can be added as a separate preset and CI job.
- **clang-cl:** not evaluated.

## Consequences and trade-offs

- The `msvc` preset fails outside a prepared environment (`cl` not found).
- The preset needs Ninja installed.
- Only Debug is exercised in CI; Release on Windows is untested.
- Windows ARM and 32-bit targets are not addressed.
