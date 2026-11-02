# ADR 0009: Optional quality tools as per-target CMake modules

- **Status:** Accepted
- **Date:** 2026-11-01

## Context

The specification asks for clang-format, clang-tidy, compiler warnings and sanitizers that are
optional, documented, not mandatory for the basic build, and without unnecessary global compiler
flags ([ASR 0002](../requirements/0002-minimal-core-toolchain.md)). Facts checked locally: clang-format
18.1.3 and clang-tidy 18.1.3 are available; CMake's `CXX_CLANG_TIDY` target property runs clang-tidy
during compilation; the GCC and Clang sanitizer runtimes for address, undefined and thread exist;
a clang-analyzer check fires inside Catch2's own header when a test is analyzed.

## Decision

- Each tool is a CMake module in `tool/cmake/` with a per-target function, like the existing warning and portability helpers: `Format.cmake` (targets `format` and `format-check`), `StaticAnalysis.cmake` (`project_set_static_analysis`, option `PROJECT_ENABLE_CLANG_TIDY`) and `Sanitizers.cmake` (`project_set_sanitizers`, option `PROJECT_SANITIZERS`).
- All are off by default. Presets `tidy`, `sanitize` and `tsan` turn them on. Their names are not stage names, like `coverage` and `msvc`.
- clang-tidy findings are errors (`WarningsAsErrors: '*'`) because the tool is opt-in; a project that wants warnings only can change that line.
- UndefinedBehaviorSanitizer is built with `-fno-sanitize-recover=undefined`, so a finding fails the test.
- The clang-format style is Google's with a 100-column limit, the closest match to the existing code (nine deviations were reformatted).
- Checks disabled in `.clang-tidy` and `test/.clang-tidy` each carry a written reason.

## Alternatives considered

- **Global flags in `CMAKE_CXX_FLAGS` or `CMAKE_CXX_CLANG_TIDY`:** simpler, but apply to fetched dependencies such as Catch2. Not chosen.
- **A `run-clang-tidy` script over the compile database:** also analyzes dependency sources unless filtered, and needs a script per platform. Not chosen.
- **Making the formatting check part of every build:** slows builds and requires clang-format everywhere. Not chosen.
- **Treating clang-tidy findings as warnings:** findings scroll by and accumulate. Not chosen.

## Consequences and trade-offs

- With the option on, clang-tidy runs on every compile, which slows the build (about 20 s for a full build here).
- Tidy and formatting results depend on the tool version; the observed version is 18.1.3.
- The `test/` directory disables two checks because of Catch2; a different test framework may not need that.
- A new executable MUST call the three helpers (`project_set_coverage`, `project_set_static_analysis`, `project_set_sanitizers`).
- Sanitizers need the compiler's runtime libraries, an optional prerequisite.
