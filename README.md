# cpp23-template

Reusable C++23 application template. Milestone 1 of 10: minimal foundation.

## Prerequisites

Required:

- C++23 compiler: GCC 13+ or Clang 18+ (verified: see below). MSVC is configured but unverified.
- CMake 3.25+
- Ninja (the presets use it; any generator works if you configure manually)
- Network access on first configure, to fetch Catch2 (unless Catch2 v3 is installed system-wide)

Nothing else is needed: no Docker, Node.js or Python.

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
| Linux | GCC 13 | `test`, `debug`, `release` | verified locally (build + 17/17 tests, Debug and Release) |
| Linux | Clang 18 | same | verified locally (Debug and Release, `-Werror`) |
| Windows | MSVC (VS 2022) | `msvc` + `msvc-debug`/`msvc-release` | **not verified**: configured, runs in CI only |
| macOS | Apple Clang | `debug`/`release` (needs `brew install ninja`) | **not verified**: runs in CI only |
| FreeBSD | base Clang | `debug`/`release` (needs `pkg install cmake ninja git`) | **not verified**: runs in CI only |
| OpenBSD, NetBSD | any | any | not covered by CI |

CI matrix: `.github/workflows/ci.yml`. A platform counts as verified only after its job passes.
Windows: run from a Developer Prompt or let the Visual Studio generator locate the toolchain:
`cmake --preset msvc`, `cmake --build --preset msvc-debug`, `ctest --preset msvc-debug`.
Without Ninja, configure manually: `cmake -S . -B build/make -G "Unix Makefiles"`.

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
