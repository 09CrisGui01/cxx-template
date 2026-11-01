# ADR 0006: Versioning without a final release tag

- **Status:** Accepted
- **Date:** 2026-11-01
- **Supersedes:** [ADR 0004](0004-semver-versioning-with-greek-stage-tags.md)

## Context

[ADR 0004](0004-semver-versioning-with-greek-stage-tags.md) required every version to be
`X.Y.Z-TAG+METADATA` with the stage tags `alpha`, `beta`, `gamma` and `delta` (final release). Its
consequences were that Semantic Versioning precedence ranked `gamma` above `delta`, and that every
release, even `delta`, was a pre-release for external tools.

The repository owner then decided:

- The final release tag (`delta`) is removed entirely.
- Version tags and version metadata are for documentation only: they appear in the changelog, the documentation and commits that refer directly to a version. No code has to address a version with its tag and metadata, but the build must offer ways to determine them through macros, build flags or execution flags.
- The stage tags mean: `alpha` development, `beta` testing and debugging, `gamma` pre-release. The configure presets are named after them (`alpha`, `beta`, `gamma`; formerly `debug`, `test`, `release`), so the preset field of the metadata reads as a stage name.
- Version metadata is `<timestamp>.<build-preset>.<os>.<architecture>.<toolchain>`.

## Decision

- The stage tags are `alpha`, `beta` and `gamma`. A final release has no tag: `X.Y.Z`.
- The full version is `X.Y.Z-TAG+METADATA`, or `X.Y.Z+METADATA` for a final release. Git tags use the version and tag without metadata (`X.Y.Z-TAG`, or `X.Y.Z`), with no `v` prefix.
- Metadata is five dot-separated fields: UTC configure date as year, month and day (`YYYYMMDD`), configure preset name (`none` without a preset), operating system, architecture and toolchain (compiler id and version). Characters outside `0-9A-Za-z-` become `-`.
- `tool/cmake/Version.cmake` computes the tag, tagged version, metadata and full version, validates them, and the `app` target receives them as the compile definitions `APP_VERSION_TAG`, `APP_VERSION_METADATA` and `APP_VERSION_FULL`. `app --version` prints the full version. The stage is selected with `-DPROJECT_VERSION_TAG=<tag>` (default `alpha`; empty for a final release).
- The changelog heading carries the full version.

## Alternatives considered

- **Keep `delta` ([ADR 0004](0004-semver-versioning-with-greek-stage-tags.md)):** wrong precedence order and no stable release for external tools. Withdrawn by the owner.
- **Numbered pre-release identifiers (`alpha.1`):** would allow several builds per stage. Not chosen; the owner kept `X.Y.Z-tag`.
- **Metadata computed from Git (commit hash):** not part of the owner's field list. Not chosen.
- **Metadata fixed by hand in `CMakeLists.txt`:** cannot describe the build. Not chosen.

## Consequences and trade-offs

- The stage order `alpha`, `beta`, `gamma`, final release now matches Semantic Versioning precedence, and external tools can recognize a final release.
- A tag has no counter, so each `X.Y.Z` has at most one version per stage.
- The metadata describes one build, while a release can be built many times. The changelog records the metadata of the build the maintainer designates as the release build.
- The date makes builds of the same source differ when made on different days, unless `SOURCE_DATE_EPOCH` is set. A build that must be reproducible MUST set it.
- Metadata is computed at configure time, not at build time. Rebuilding without reconfiguring keeps the old date.
- The compile definitions change when the date changes, so the first reconfigure on a new day rebuilds `internal/main.cpp`.
- The numeric version stays in `project(VERSION)`; the tag has its own default in `CMakeLists.txt`.
