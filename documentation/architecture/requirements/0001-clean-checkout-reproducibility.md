# ASR 0001: Clean-checkout reproducibility

- **Status:** Accepted
- **Date:** 2026-10-31
- **Verification status:** Partially met

## Context

The project specification names a clean checkout as a non-negotiable principle and ranks
reproducibility first among its priorities. A developer must be able to clone the repository,
install the documented prerequisites, and build and test without hidden configuration.

## Requirement

Quality attribute: reproducibility. After a fresh clone and installation of the documented
prerequisites, the commands in [Getting started](../../getting-started.md) MUST configure, build
and test the project without untracked files, developer-specific absolute paths, undocumented
environment variables, existing build directories or embedded credentials. Acceptance: the commands
succeed in a new directory.

## Verification

- Fresh `git clone` into a new directory, then `cmake --preset beta`, `cmake --build --preset beta`, `ctest --preset beta`: run on Linux with GCC 13.3 and Clang 18.1 after each change; passed.
- The CI workflow checks out the repository fresh for every job; the repository owner reported all jobs passed.
- Not verified: a build on a machine without network access to github.com (a clone needs it for the submodules); a machine with no prior Catch2 and a different CMake version than 3.28.3.

## Alternatives considered

- **Vendor Catch2 in `external/`:** removes the network need but adds third-party source to the repository. Not chosen; see [ADR 0002](../decisions/0002-catch2-test-framework.md).
- **Require a container for all builds:** guarantees the toolchain but contradicts [ASR 0002](0002-minimal-core-toolchain.md).

## Consequences and trade-offs

- All build inputs MUST be tracked or fetched by the build itself.
- Since [ADR 0014](../decisions/0014-third-party-libraries-as-submodules.md), spdlog and Catch2 are submodules. A clone made without `--recurse-submodules` cannot configure until `git submodule update --init --recursive` runs, unless the libraries are installed.
- The submodules pin the libraries by commit hash. The earlier open point about tag pinning no longer applies to them. GitHub Actions and the container base image are still referenced by tag.
- Build directories live under `build/`, which is ignored, so stale local state cannot be committed.

## Related decisions

[ASR 0002](0002-minimal-core-toolchain.md), [ADR 0002](../decisions/0002-catch2-test-framework.md)
