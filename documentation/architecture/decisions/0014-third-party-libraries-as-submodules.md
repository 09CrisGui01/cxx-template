# ADR 0014: Third-party libraries as Git submodules

- **Status:** Accepted
- **Date:** 2026-11-03
- **Amends:** [ADR 0002](0002-catch2-test-framework.md), [ADR 0010](0010-logging-with-spdlog.md)

## Context

[ADR 0002](0002-catch2-test-framework.md) and [ADR 0010](0010-logging-with-spdlog.md) made CMake
fetch Catch2 and spdlog from GitHub with `FetchContent` when no system install was found, pinned by
tag. The repository owner asked for both libraries to be Git submodules in `external/` instead. A
tag can be moved by its owner; a submodule records the exact commit.

Verified on Linux: with GCC 13.3 the `beta`, `gamma`, `tidy` and `sanitize` presets build and pass
(28 of 28 tests where tests run); with Clang 18.1 the `beta` preset builds with warnings as errors
and passes 28 of 28. A fresh `git clone --recurse-submodules` builds and passes. A clone without
submodules, with spdlog hidden from CMake, stops with the error message quoted above. The
container `test` stage still passes. Not verified: macOS, Windows (MSVC), FreeBSD, and the CI
checkout with `submodules: recursive` on GitHub.

## Decision

We add two submodules: `external/spdlog` at tag v1.17.0 (commit `79524ddd08a4`) and
`external/Catch2` at tag v3.7.1 (commit `fa43b77429ba`). The superproject records the commits, so
the versions are pinned by hash.

CMake looks for the libraries in this order:

1. The submodule, when its directory contains a `CMakeLists.txt`. It is added with
   `add_subdirectory(... SYSTEM)`, so warnings inside the library are not reported.
2. An installed package: spdlog 1.12 or newer, Catch2 3.3 or newer.
3. Otherwise configuring stops with an error that names `git submodule update --init --recursive`.

The `FetchContent` fallback of ADR 0002 and ADR 0010 is removed. The container images do not copy
`external/`, so they use the Ubuntu packages (step 2), as [ADR 0013](0013-multi-stage-container-image.md)
describes. A configure with `-DBUILD_TESTING=OFF` does not need Catch2.

## Alternatives considered

- **Keep `FetchContent`:** works without extra clone steps, but pins by tag and needs network access
  at every fresh configure.
- **Copy the library sources into the repository:** no clone step, but it adds the full third-party
  history of changes to this repository's diffs and makes updates manual.
- **Git subtree:** same drawbacks as copying, plus a harder update procedure.
- **A package manager (vcpkg, Conan):** not evaluated; it would add a tool the project does not use.

## Consequences and trade-offs

- A clone MUST include the submodules: `git clone --recurse-submodules <url>`, or
  `git submodule update --init --recursive` afterwards. Without them the configure fails with a
  clear message, unless the libraries are installed.
- GitHub's "Download ZIP" and release source archives do not contain submodule contents. Such an
  archive needs the libraries installed, or the submodules added by hand.
- CI checkouts MUST fetch submodules (`submodules: recursive`).
- Updating a library is a change of the checked-out tag in the submodule, committed as
  `build(deps)`, together with the README dependency table.
- The container images and the submodule builds use different library versions (spdlog 1.12 and
  Catch2 3.4 in the images, spdlog 1.17.0 and Catch2 3.7.1 in the submodules).
- A fresh configure no longer needs network access, but a fresh clone does.
- The licenses of the libraries stay in their submodule directories.

## Related decisions

[ADR 0002](0002-catch2-test-framework.md), [ADR 0010](0010-logging-with-spdlog.md),
[ADR 0013](0013-multi-stage-container-image.md),
[ASR 0001](../requirements/0001-clean-checkout-reproducibility.md)
