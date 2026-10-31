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
prerequisites, the commands in [Getting started](../../getting-started.md) shall configure, build
and test the project without untracked files, developer-specific absolute paths, undocumented
environment variables, existing build directories or embedded credentials. Acceptance: the commands
succeed in a new directory.

## Verification

- Fresh `git clone` into a new directory, then `cmake --preset test`, `cmake --build --preset test`, `ctest --preset test`: run on Linux with GCC 13.3 and Clang 18.1 after each change; passed.
- The CI workflow checks out the repository fresh for every job; the repository owner reported all jobs passed.
- Not verified: a build on a machine without network access to github.com (the first configure fetches Catch2); a machine with no prior Catch2 and a different CMake version than 3.28.3.

## Alternatives considered

- **Vendor Catch2 in `external/`:** removes the network need but adds third-party source to the repository. Not chosen; see [ADR 0002](../decisions/0002-catch2-test-framework.md).
- **Require a container for all builds:** guarantees the toolchain but contradicts [ASR 0002](0002-minimal-core-toolchain.md).

## Consequences and trade-offs

- All build inputs must be tracked or fetched by the build itself.
- The Catch2 fetch pins a tag, not a commit hash, so a moved tag would change a "reproducible" build. Pinning a hash is an open improvement.
- Build directories live under `build/`, which is ignored, so stale local state cannot be committed.

## Related decisions

[ASR 0002](0002-minimal-core-toolchain.md), [ADR 0002](../decisions/0002-catch2-test-framework.md)
