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
