# cpp23-template

[![ci](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml)

> **Template placeholders:** replace `{{username}}` and `{{project-name}}` in the badge above
> (both occurrences) with your GitHub account and repository name. Until you do, the badge is broken.

Reusable C++23 application template. Milestones 1-2 of 10 done: foundation and documentation.

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
| Git | fetching Catch2 (`FetchContent`) | 2.43 | not checked | 2.43.0 (local); CI not recorded |
| Catch2 (tests only) | `BUILD_TESTING=ON` | 3.3 (needed for `SKIP`) | `find_package(Catch2 3.3)`; an older install is ignored and 3.7.1 is fetched | 3.7.1 (fetched, pinned in `test/CMakeLists.txt`) |

- The compiler minimums live in `tool/cmake/ToolchainRequirements.cmake` and can be overridden with
  `-DPROJECT_MIN_<ID>_VERSION=<version>`. The warning never stops the build.
- Catch2: a system install of version 3.3 or newer is used if found; otherwise v3.7.1 is fetched
  from github.com, which needs network access on the first configure.
- Runtime dependencies: none beyond the C++ standard library (`<filesystem>` is used).
- Not required: Docker, Podman, Node.js, Python, Jenkins.

## Quick start

```sh
cmake --preset test
cmake --build --preset test
ctest --preset test
./build/Linux/test/app configuration/default.conf
```

Build files go to `build/<os>/<preset>/`, where `<os>` is CMake's host system name (`Linux`, `Darwin`
for macOS, `Windows`, `FreeBSD`). The path above is for Linux.

Expected: all tests pass; the app prints `app 0.1.0`, `loaded 2 entries` and the entries.

Other presets: `debug`, `release` (same three commands with the preset name).

## Platform support

| Platform | Compiler | Preset | Status |
|----------|----------|--------|--------|
| Linux | GCC 13.3 | `test`, `debug`, `release` | verified locally: Debug and Release, 17/17 tests. CI runs `test` |
| Linux | Clang 18.1 | same | verified locally: Debug and Release with `-Werror`, 17/17 tests. CI runs `test` |
| Windows | MSVC `cl` (Ninja Multi-Config) | `msvc`, `msvc-debug` | CI passed (Debug only). Release not run |
| macOS | Apple Clang | `debug` (needs `brew install ninja`) | CI passed (Debug only). Release not run |
| FreeBSD | base Clang | `debug` (needs `pkg install cmake ninja git`) | CI passed (Debug only). Release not run |

FreeBSD is the only BSD supported.

CI matrix: `.github/workflows/ci.yml`. CI results for Windows, macOS and FreeBSD were reported by the repository owner, not observed by the author.
Windows: run from an "x64 Native Tools Command Prompt" (needs `cl` and `ninja` on PATH):
`cmake --preset msvc`, `cmake --build --preset msvc-debug`, `ctest --preset msvc-debug`.

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

## Example application

`app [config-file]` parses a `key=value` file with size limits and prints the entries.
Exit codes: `0` success, `1` load/parse error, `2` usage error.
To replace the example: swap the sources listed in `CMakeLists.txt` and `test/CMakeLists.txt`.

## Status

Milestones 1 and 2 exist. Coverage, sanitizers, formatting, static analysis, Commitlint,
containers, AI instructions and Jenkins arrive in later milestones; presets and docs for them
are added with each feature.
