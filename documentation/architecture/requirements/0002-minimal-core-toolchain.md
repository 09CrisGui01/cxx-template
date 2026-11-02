# ASR 0002: Minimal core toolchain

- **Status:** Accepted
- **Date:** 2026-10-31
- **Verification status:** Met

## Context

The specification requires that the default C++ build not depend on Docker, Podman, Jenkins,
Node.js, Python, a documentation generator or AI tools, and that optional tooling stay optional.

## Requirement

Quality attribute: simplicity of the build environment. Configuring, building and testing the
default targets MUST need only a C++23 compiler, CMake, Ninja (used by the presets) and Git (used
by `FetchContent` for Catch2). Acceptance: no build or test file invokes Docker, Podman, Jenkins,
Node.js or Python.

## Verification

- Inspection: `grep -i` for `node`, `npm`, `python`, `docker`, `podman` and `jenkins` over `CMakeLists.txt`, `CMakePresets.json`, `test/`, `tool/`, `internal/` and `.github/` found no references.
- Build and test succeed in a fresh clone and in CI with the tools listed in the README [dependency table](../../../README.md#dependencies).
- Not verified: a machine where Node.js, Python and Docker are absent. The author's machine has Node.js and Python installed, so absence of use was shown by inspection, not by removal.

## Alternatives considered

- **Python helper scripts for builds:** easier cross-platform scripting, but adds a required runtime. Not chosen.
- **Container-only builds:** see [ASR 0001](0001-clean-checkout-reproducibility.md).

## Consequences and trade-offs

- Later milestones (Commitlint with Node.js, containers, documentation generator, Jenkins) MUST stay optional and MUST NOT be wired into the default CMake targets.
- Developer automation beyond CMake presets has to be written as shell and PowerShell scripts or CMake scripts (as `tool/cmake/RunCoverage.cmake` is), not as a Python dependency.
- gcovr is a Python tool. It is used only by the optional `coverage` target with GCC and by the optional CI `coverage` job (`pipx install gcovr==8.8` in `.github/workflows/ci.yml`), so the default build stays free of Python.

## Related decisions

[ASR 0001](0001-clean-checkout-reproducibility.md)
