# ADR 0004: Semantic Versioning with Greek stage tags

- **Status:** Superseded by [ADR 0006](0006-versioning-without-final-release-tag.md)
- **Date:** 2026-10-31

## Context

The repository owner decided that every version of the program uses Semantic Versioning 2.0.0 and
always carries a stage tag and build metadata, `X.Y.Z-TAG+METADATA`, with the stage tags `alpha`
(under heavy development), `beta` (under testing, bug fixing, coverage analysis), `gamma`
(pre-release) and `delta` (final release). Git tags contain only the version and the tag.

Facts about Semantic Versioning 2.0.0 that bear on this decision:

- Identifiers made of letters are compared as ASCII text, so `alpha` < `beta` < `delta` < `gamma`.
- A version with a pre-release tag has lower precedence than the same version without one, so `1.0.0-delta` < `1.0.0`.
- Build metadata is ignored when comparing versions.

CMake's `project(VERSION)` accepts only numeric components.

## Decision

We use `X.Y.Z-TAG+METADATA` for every version, with tags `alpha`, `beta`, `gamma` and `delta`, and Git
tags named `X.Y.Z-TAG`. The project's own stage order is `alpha`, `beta`, `gamma`, `delta`. Tooling
must not rely on Semantic Versioning precedence to order stages.

## Alternatives considered

- **Order-preserving tag names:** a final-release tag that sorts after `gamma` (for example `omega`) would make Semantic Versioning precedence match the stage order. Not chosen by the repository owner.
- **Untagged final release (`1.0.0`):** gives correct precedence and lets external tools see a stable release. Not chosen: every version must have a tag.
- **Numbered pre-release identifiers (`alpha.1`):** allows several builds per stage. Not chosen; the owner specified `X.Y.Z-tag`.

## Consequences and trade-offs

- Tools that sort by Semantic Versioning precedence rank `gamma` above `delta`, and treat every release, even `delta`, as a pre-release (for example "latest release" selection on a host).
- There is no counter, so each `X.Y.Z` has at most one version per stage.
- The meaning of `METADATA` is not defined yet.
- CMake needs separate variables for tag and metadata, and the application's reported version needs them too. This is not implemented; the current `0.1.0` does not follow the format.
- The changelog and Git tags use the version and tag without metadata.
