# ADR 0002: Catch2 as the test framework

- **Status:** Accepted; amended by [ADR 0014](0014-third-party-libraries-as-submodules.md)
- **Date:** 2026-10-31

## Context

The template needs one unit-test framework that integrates with CTest and builds on Linux, macOS,
Windows (MSVC) and FreeBSD. Catch2 v3.7.1 was built and run on all four in CI (Debug), and on Linux
with GCC and Clang locally.

## Decision

We use Catch2 v3. `test/CMakeLists.txt` prefers a system install (`find_package(Catch2 3.3)`) and
otherwise fetches tag v3.7.1 with `FetchContent`. `catch_discover_tests` registers each test case
as a CTest test. Version 3.3 is the declared floor because the tests use the `SKIP` macro.

## Alternatives considered

- **doctest, GoogleTest:** not evaluated or built in this repository. They remain valid choices; only one framework should be used.

## Consequences and trade-offs

- The first configure needs network access to github.com unless Catch2 is installed.
- Catch2 is compiled as part of the build (a clean build had 114 build steps, most of them Catch2), which lengthens it.
- The fetched tag is pinned by tag name, not by commit hash. A tag can be moved; pinning a hash or using `URL_HASH` is a possible hardening step.
- CTest receives test names but not Catch2 tags as labels, so selection by tag uses the `app_tests` binary directly.
