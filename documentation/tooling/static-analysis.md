# Formatting, static analysis and warnings

**Purpose:** check and enforce code quality with compiler warnings, clang-format and clang-tidy.
All of it is **optional** except the compiler warnings, which are always on. The design is recorded
in [ADR 0009](../architecture/decisions/0009-optional-quality-tools-as-cmake-modules.md).

## Summary

| Tool | Configuration | Prerequisite | Command | Mandatory? |
|------|---------------|--------------|---------|------------|
| Compiler warnings | `tool/cmake/CompilerWarnings.cmake` | none | any build; `beta` preset makes them errors | yes (always on) |
| clang-format | `.clang-format` | clang-format | `cmake --build --preset alpha --target format-check` | no |
| clang-tidy | `.clang-tidy`, `test/.clang-tidy` | clang-tidy | `cmake --preset tidy`, `cmake --build --preset tidy` | no |

Observed locally: clang-format 18.1.3 and clang-tidy 18.1.3 (Ubuntu package `clang-format` and
`clang-tidy`), with GCC 13.3 and Clang 18.1 as the compiler.

## Compiler warnings

`project_set_warnings(target)` applies, per target and not globally:

- GCC and Clang: `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Woverloaded-virtual -Wnull-dereference -Wdouble-promotion -Wformat=2`; GCC also `-Wduplicated-cond -Wlogical-op -Wuseless-cast`.
- MSVC: `/W4 /permissive-`.
- With `PROJECT_WARNINGS_AS_ERRORS=ON` (the `beta` preset): `-Werror` or `/WX`.

A warning MUST NOT be silenced to get a build through; fix the cause. Build with the `beta` preset
before sending a change.

## clang-format

The style is Google's, with a 100-column limit, in `.clang-format`. The `format` and `format-check`
targets exist when `clang-format` is found; the files are `internal/*` and `test/*.cpp`.

```sh
cmake --preset alpha
cmake --build --preset alpha --target format-check   # fails if a file differs; changes nothing
cmake --build --preset alpha --target format         # rewrites the files in place
```

Expected: `format-check` exits 0 on the committed sources. Verified: after a deliberate extra space in
`internal/main.cpp`, `format-check` failed (exit 1) and `format` restored the file.

Include blocks are regrouped by clang-format (the file's own header first, then the others sorted),
so do not fight its order.

## clang-tidy

`PROJECT_ENABLE_CLANG_TIDY=ON` (the `tidy` preset) runs clang-tidy on every `.cpp` of the project as
part of compiling it. The configuration is `.clang-tidy`; `test/.clang-tidy` inherits it and turns
off two checks, with the reason written in the file. Every finding is an error
(`WarningsAsErrors: '*'`), so the build stops at the first.

```sh
cmake --preset tidy
cmake --build --preset tidy
ctest --preset tidy
```

To use Clang as the compiler: `CXX=clang++ cmake --preset tidy -B build/Linux/tidy-clang`, then
`cmake --build build/Linux/tidy-clang`.

Expected: the build finishes with no diagnostics; 19 tests pass. Verified on Linux, with GCC and with
Clang as the compiler. The whole GCC build with tidy took about 20 seconds.

### Checks

Enabled: `bugprone-*`, `clang-analyzer-*`, `misc-*`, `modernize-*`, `performance-*`, `portability-*`,
`readability-*`, and three `cppcoreguidelines-*` checks. Disabled, with reasons in `.clang-tidy`:
`modernize-use-trailing-return-type`, `readability-magic-numbers`,
`misc-non-private-member-variables-in-classes`, `misc-include-cleaner` and
`readability-identifier-length`.

### What the first run found, and what was done

| Finding | Action |
|---------|--------|
| `performance-enum-size`: `ErrorCode` uses an `int` | Fixed: `enum class ErrorCode : std::uint8_t` |
| `bugprone-implicit-widening-of-multiplication-result`: `1024 * 1024` computed as `int` | Fixed: `std::size_t{1024} * 1024` |
| `modernize-avoid-c-arrays`: a C array in a test and `char* argv[]` in `run` | Fixed: `std::array`, `char** argv` |
| `bugprone-exception-escape`: an exception could leave `main` | Fixed: `main` catches exceptions and exits with status 1 |
| `readability-function-cognitive-complexity` in a Catch2 test case | Check disabled for `test/`: the assertion macros inflate the score |
| `clang-analyzer-optin.core.EnumCastOutOfRange` inside Catch2's `catch_result_type.hpp` | Check disabled for `test/`: third-party header |

The header filter limits reports to this project's `internal/` headers. It is passed by
`tool/cmake/StaticAnalysis.cmake`, not by `.clang-tidy`, because a regular expression there would
also match Catch2's own `internal/` directory.

Verified that tidy catches a real defect: a deliberate use-after-move made the build fail with
`bugprone-use-after-move`.

### Limits

- Only the `.cpp` files that CMake compiles are analyzed; the headers are analyzed through them.
- The analysis uses the compile flags of the chosen compiler. GCC-only warning options are ignored through `--extra-arg=-Wno-unknown-warning-option`.
- MSVC and other platforms: **untested**.
- Static analysis finds some defects and not others; a clean run is not a proof of correctness.

## Troubleshooting

| Symptom | Cause and fix |
|---------|--------------|
| `format-check` is not a target | `clang-format` was not found; configure prints a status line. Install it. |
| `format-check` fails | Run the `format` target and review the diff. |
| `PROJECT_ENABLE_CLANG_TIDY=ON but clang-tidy was not found` | Install clang-tidy or put it on `PATH`. |
| A clang-tidy finding in a third-party header | Report it; do not widen the header filter. |
| `clang-format` and a different version disagree | The style was written with 18.1.3; other major versions may format some code differently. |

## CI

The `quality` job in the GitHub workflow (GCC as the compiler) runs `format-check`, the `tidy` build and the `sanitize`
build with tests. It was **not run on GitHub** by the author.

## Related

[Sanitizers](../testing/sanitizers.md), [Coding standards](../development/coding-standards.md),
[Build and run](../development/build-and-run.md)
