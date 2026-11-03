# cpp23-template

[![ci](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml)

> **Template placeholders:** replace `{{username}}` and `{{project-name}}` in the badge above
> (both occurrences) with your GitHub account and repository name. Until you do, the badge is broken. Also replace `{{contact-email}}` in `CODE-OF-CONDUCT.md`.

Reusable C++23 application template.

Documentation: start at [documentation/index.md](documentation/index.md).

## Dependencies

**Minimum** is a soft limit: the lowest version the project is supported with. It is the lowest
version this project was built and tested with, rounded down to the minor release. An older tool
may still work; it is simply unsupported. "Provisional" means the CI log did not record the verified
version, so the minimum is a chosen floor to confirm from the next CI Configure log, which now
prints `C++ compiler: <id> <version>`.

| Dependency | Needed for | Minimum (soft) | Enforcement | Lowest version verified |
|------------|-----------|----------------|-------------|-------------------------|
| GCC | Linux | 13.0 | CMake warning at configure | 13.3.0 (local) |
| Clang (libstdc++ on Linux, libc++ on FreeBSD) | Linux, FreeBSD | 18.0 | CMake warning at configure | 18.1.3 (local, Linux); FreeBSD version not recorded |
| Apple Clang (Xcode 26.6 SDK) | macOS | 17.0 (provisional) | CMake warning at configure | not recorded |
| MSVC `cl` | Windows | 19.40, Visual Studio 2022 17.10 (provisional) | CMake warning at configure | not recorded |
| CMake | all platforms | 3.25 (hard: `cmake_minimum_required`, preset schema 6) | CMake error | 3.28.3 (local); CI not recorded |
| Ninja | all presets (`Ninja`, `Ninja Multi-Config`) | 1.11 | not checked | 1.11.1 (local); CI not recorded |
| Git | cloning the repository and its submodules | 2.43 | not checked | 2.43.0 (local); CI not recorded |
| gcovr (optional) | coverage with GCC | none set | not checked | 8.8 (local; pinned in the CI `coverage` job) |
| llvm-cov, llvm-profdata (optional) | coverage with Clang | same major version as Clang | the name with Clang's major version is searched first | 18.1.3 (local) |
| Clang runtime libraries (optional) | Clang coverage and sanitizers | same as Clang | link error when missing | Ubuntu package `libclang-rt-18-dev` 18.1.3 (local) |
| clang-format (optional) | `format` and `format-check` targets | none set | not checked | 18.1.3 (local) |
| clang-tidy (optional) | `tidy` preset | none set | not checked | 18.1.3 (local) |
| spdlog | logging (always) | 1.12 | submodule `external/spdlog` (v1.17.0); if it is not checked out, `find_package(spdlog 1.12)` | 1.17.0 (submodule, GCC 13.3, local); 1.12.0 and fmt 9.1.0 (system and container images, local); other platforms not verified |
| Docker or Podman (optional) | container images | none set | not checked | Docker 29.9.2 with Compose 5.6.1, Podman 4.9.3 (local, Linux) |
| Node.js with npm (optional) | Husky and Commitlint | 22.12 (Commitlint 21 requires it) | npm `engines` field | Node.js 22.23.4, npm 10.9.9 (local); Husky 9.1.7, Commitlint 21.2.4 (pinned in `package.json`) |
| gitleaks (optional) | secret scan in the pre-commit hook and CI | none set | skipped when missing | 8.30.0 (local; pinned in the CI `hygiene` job) |
| shellcheck (optional) | shell script check | none set | skipped when missing | 0.9.0 (local) |
| Doxygen (optional) | `doxygen` target | none set | target not created when missing | 1.9.8 (local) |
| GDB, Valgrind (optional) | debugging and memory checks | none set | not checked | GDB 15.1, Valgrind 3.22.0 (local) |
| Catch2 (tests only) | `BUILD_TESTING=ON` | 3.3 (needed for `SKIP`) | submodule `external/Catch2` (v3.7.1); if it is not checked out, `find_package(Catch2 3.3)` | 3.7.1 (submodule, local); 3.4.0 (container images) |

- The compiler minimums live in `tool/cmake/ToolchainRequirements.cmake` and can be overridden with
  `-DPROJECT_MIN_<ID>_VERSION=<version>`. The warning never stops the build.
- spdlog and Catch2 are Git submodules in `external/` ([ADR 0014](documentation/architecture/decisions/0014-third-party-libraries-as-submodules.md)). Clone with `git clone --recurse-submodules <url>`, or run `git submodule update --init --recursive` in an existing clone. If a submodule is not checked out, CMake uses an installed spdlog 1.12+ or Catch2 3.3+, and stops with an error when it finds neither. GitHub's "Download ZIP" does not include submodules.
- Runtime dependencies: the C++ standard library, plus the spdlog shared library when the build uses an installed spdlog that is a shared library. The submodule spdlog is linked statically.
- Optional tools (the rows marked optional) have no enforced minimum; the table lists the version that was observed. They are described in [Coverage](documentation/testing/coverage.md), [Static analysis](documentation/tooling/static-analysis.md) and [Sanitizers](documentation/testing/sanitizers.md). gcovr needs Python.
- Not required for the default build: Docker, Podman, Node.js, Python, Jenkins.

## Quick start

```sh
git clone --recurse-submodules <url>
cd <directory>
cmake --preset beta
cmake --build --preset beta
ctest --preset beta
./build/Linux/beta/app configuration/default.conf
```

Build files go to `build/<os>/<preset>/`, where `<os>` is CMake's host system name (`Linux`, `Darwin`
for macOS, `Windows`, `FreeBSD`). The path above is for Linux.

Expected: all 28 tests pass; the app prints `app 0.1.0`, `loaded 2 entries` and the entries. `app --version` prints the full version with stage tag and metadata ([Conventions](documentation/development/conventions.md#versions)).

Coverage (optional, see [Coverage](documentation/testing/coverage.md)): `cmake --preset coverage` then `cmake --build --preset coverage-report`; the HTML report is `build/Linux/coverage/coverage/html/index.html`.

Other presets: `alpha` (development, Debug), `gamma` (pre-release, Release); same three commands with the preset name.

## Platform support

| Platform | Compiler | Preset | Status |
|----------|----------|--------|--------|
| Linux | GCC 13.3 | `beta`, `alpha`, `gamma` | verified locally: `beta` and `sanitize` 28/28 tests, coverage report written. `alpha` and `gamma` were not rerun after logging was added. CI runs `beta` |
| Linux | Clang 18.1 | same | verified locally: Debug with `-Werror`, 28/28 tests. `gamma` was not rerun after logging was added. CI runs `beta` |
| Windows | MSVC `cl` (Ninja Multi-Config) | `msvc`, `msvc-debug` | CI passed (Debug only). Release not run |
| macOS | Apple Clang | `alpha` (needs `brew install ninja`) | CI passed (Debug only). Release not run |
| FreeBSD | base Clang | `alpha` (needs `pkg install cmake ninja git`) | CI passed (Debug only). Release not run |

FreeBSD is the only BSD supported.

CI: see [GitHub Actions](documentation/ci-cd/github-actions.md). CI results for Windows, macOS and FreeBSD were reported by the repository owner, not observed by the author.
Windows commands are in [Getting started](documentation/getting-started.md#procedure).

Portability tests (tag `[portability]`): UTF-8 BOM, CRLF files, spaces and non-ASCII paths, symlinks.

## Layout

| Path | Purpose |
|------|---------|
| `internal/` | Implementation (`.cpp`) and declarations (`.hpp`), flat |
| `test/` | Catch2 unit tests and CTest integration tests |
| `tool/cmake/` | Reusable CMake modules |
| `configuration/` | Program configuration files |
| `data/` | Program input, intermediate and output data |
| `external/` | Vendored third-party code (empty) |
| `script/` | Developer automation scripts (empty) |
| `Dockerfile`, `compose.yaml`, `.dockerignore` | Optional container images (development, test, coverage, runtime) |
| `documentation/` | All documentation; start at the index |

## Example application

`app [--version | config-file]` parses a `key=value` file with size limits and prints the entries;
`--version` prints the version with stage tag and metadata. Log messages go to standard error; see [Logging](documentation/development/logging.md).
Exit codes: `0` success, `1` load or parse error (or an unexpected exception), `2` usage error.
To replace the example: swap the sources listed in `CMakeLists.txt` and `test/CMakeLists.txt`.

## Status

Milestones 1 to 4 of 10 are done: foundation, documentation, testing and coverage, and quality
tools. Optional Git hooks and commit linting (Husky, Commitlint, gitleaks, shellcheck), Doxygen and
logging were added afterwards; see [Tool evaluation](documentation/tooling/tool-evaluation.md). Dockerfile, Compose file and container documentation (milestone 6) were added after that, see [Runtime container](documentation/containers/runtime.md#verification-status). AI instructions and Jenkins arrive in later milestones; presets and
documentation for them are added with each feature.
