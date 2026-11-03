# ADR 0012: Doxygen for API documentation

- **Status:** Accepted
- **Date:** 2026-11-02

## Context

The project documented its API only in plain `//` comments, with no generated output. The
repository owner listed Doxygen among the tools to consider. Doxygen 1.9.8 was installed on the
verification machine (Linux). Not verified: other Doxygen versions and other operating systems.

## Decision

We add `tool/cmake/Documentation.cmake`, which defines the function `project_add_doxygen_target()`.
It creates the target `doxygen` only when Doxygen is found, as the other optional tools do
([ADR 0009](0009-optional-quality-tools-as-cmake-modules.md)). The target reads the headers in
`internal/`, writes HTML to `<build dir>/doxygen/html`, lists all entities, and fails on a Doxygen
warning but not on a missing comment. The comments in the headers use the `///` form, which Doxygen
reads. The target is not part of the default build. The README is not used as the main page,
because Doxygen cannot resolve its relative links to `.md` files.

## Alternatives considered

- **No generator:** keeps the toolchain smaller, but gives no browsable API reference.
- **Failing on undocumented entities:** useful for a mature library, but it would make the template
  fail on every new header. It can be enabled by setting `DOXYGEN_WARN_IF_UNDOCUMENTED` to `YES`.
- **Other generators (for example Sphinx with Breathe):** need Python; not evaluated.

## Consequences and trade-offs

- Developers who want the API reference install Doxygen; nobody else is affected.
- A plain `//` comment in a header is not part of the output. New header comments MUST use `///`.
- The CI job `quality` does not run the target yet.

## Related decisions

[ADR 0009](0009-optional-quality-tools-as-cmake-modules.md), [ASR 0002](../requirements/0002-minimal-core-toolchain.md)
