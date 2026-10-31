# cpp23-template

[![ci](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{username}}/{{project-name}}/actions/workflows/ci.yml)

> **Template placeholders:** replace `{{username}}` and `{{project-name}}` in the badge above
> (both occurrences) with your GitHub account and repository name. Until you do, the badge is broken.

Reusable C++23 application template. Milestone 1 of 10: minimal foundation.

## Dependencies

"Lowest version verified" is the lowest version this project was actually built and tested with.
Lower versions are untested, not known to fail. "not recorded" means CI ran but the version was
not captured; it appears in the CI Configure log (`The CXX compiler identification is ...`).

| Dependency | Needed for | Declared minimum | Lowest version verified |
|------------|-----------|------------------|-------------------------|
| C++23 compiler: GCC | Linux | none declared | 13.3.0 (local, Linux) |
| C++23 compiler: Clang with libstdc++ | Linux | none declared | 18.1.3 (local, Linux) |
| C++23 compiler: Apple Clang (Xcode 26.6 SDK) | macOS | none declared | CI, compiler version not recorded |
| C++23 compiler: MSVC `cl` | Windows | none declared | CI, version not recorded |
| C++23 compiler: FreeBSD base Clang with libc++ | FreeBSD | none declared | CI, version not recorded |
| CMake | all platforms | 3.25 (`cmake_minimum_required`, preset schema 6) | 3.28.3 (local); CI versions not recorded |
| Ninja | all presets (`Ninja`, `Ninja Multi-Config`) | none declared | 1.11.1 (local); CI versions not recorded |
| Git | fetching Catch2 (`FetchContent`) | none declared | 2.43.0 (local); CI versions not recorded |
| Catch2 (tests only) | `BUILD_TESTING=ON` | 3.3 (`find_package(Catch2 3.3)`, needed for `SKIP`) | 3.7.1 (fetched, pinned in `test/CMakeLists.txt`) |

- Catch2: a system install of version 3.3 or newer is used if found; otherwise v3.7.1 is fetched
  from github.com, which needs network access on the first configure.
- Runtime dependencies: none beyond the C++ standard library (`<filesystem>` is used).
- Not required: Docker, Podman, Node.js, Python, Jenkins.

## Quick start

```sh
cmake --preset test
cmake --build --preset test
ctest --preset test
./build/test/app configuration/default.conf
```

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

Only milestone 1 exists. Docs, coverage, sanitizers, formatting, containers, CI and
Commitlint arrive in later milestones; presets for them are added with each feature.
