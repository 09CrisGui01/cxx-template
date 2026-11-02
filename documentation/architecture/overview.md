# Architecture overview

**Purpose:** describe the components, build targets, data flow and test architecture as implemented
today. Features from later milestones (containers, Jenkins, and so on) are not described
here because they do not exist yet.

## Components

| Component | Files | Responsibility |
|-----------|-------|----------------|
| Library `app_core` | `internal/config.cpp`, `internal/config.hpp`, `internal/result.hpp` | All logic: parsing and loading configuration, error types |
| Executable `app` | `internal/main.cpp` | Argument handling, printing, exit codes. No logic worth testing in isolation. |
| Tests `app_tests` | `test/config_test.cpp` | Catch2 unit tests against `app_core` |
| Integration tests | `test/CMakeLists.txt` | CTest tests that run the real `app` binary |
| CMake helpers | `tool/cmake/CompilerWarnings.cmake`, `tool/cmake/Portability.cmake`, `tool/cmake/ToolchainRequirements.cmake`, `tool/cmake/Version.cmake`, `tool/cmake/Coverage.cmake`, `tool/cmake/RunCoverage.cmake`, `tool/cmake/Format.cmake`, `tool/cmake/StaticAnalysis.cmake`, `tool/cmake/Sanitizers.cmake` | Per-target warning and platform settings; soft compiler minimum check; version tag and metadata; optional coverage, formatting, clang-tidy and sanitizers |

Dependency direction: `app` and `app_tests` depend on `app_core`. `app_core` depends only on the C++
standard library. Nothing depends on `app` or on test code.

## CMake targets

Defined in `CMakeLists.txt` and `test/CMakeLists.txt`.

| Target | Type | Sources | Notes |
|--------|------|---------|-------|
| `app_core` (alias `cpp23_template::core`) | static library | `internal/config.cpp` | Public include directory `internal/`; `cxx_std_23` is a public compile feature |
| `app` | executable | `internal/main.cpp` | Links `app_core`; defines `APP_VERSION` (from `project(VERSION)`), `APP_VERSION_TAG`, `APP_VERSION_METADATA` and `APP_VERSION_FULL` (from `tool/cmake/Version.cmake`); `--version` prints the last |
| `app_tests` | executable | `test/config_test.cpp` | Links `app_core` and `Catch2::Catch2WithMain`; only exists when `BUILD_TESTING=ON` |

Every target calls `project_set_warnings()`, `project_set_portability()`, `project_set_coverage()`, `project_set_static_analysis()` and `project_set_sanitizers()`; the last three are no-ops unless their option is ON. They apply flags
`PRIVATE` to the one target; no flags are set globally. Language settings (`CXX_STANDARD 23`,
required, extensions off) are set once at the top of `CMakeLists.txt`.

The `ALIAS` name is derived from `${PROJECT_NAME}`; renaming the project changes it.

## Example application

`app [--version | config-file]` loads a `key=value` file and prints each entry; `--version` prints the version (see [Conventions](../development/conventions.md#versions)).

Format rules:

- One `key=value` pair per line. Whitespace around key and value is trimmed.
- Blank lines and lines starting with `#` are ignored.
- Keys may contain `A-Z a-z 0-9 _ . -`. Duplicate keys are rejected.
- A leading UTF-8 byte order mark is skipped. `\r\n` line endings are accepted.

Limits for untrusted input, defined in `internal/config.hpp`:

| Limit | Value |
|-------|-------|
| File or text size | 1 MiB (`max_config_bytes`) |
| Line length | 4096 bytes (`max_line_bytes`) |
| Entries | 1024 (`max_entries`) |

Data flow:

1. `main` passes `argv[1]` to `load_config_file`.
2. `load_config_file` checks the path exists, is a regular file (symlinks are followed) and is within the size limit, then reads at most that many bytes.
3. `parse_config` strips a BOM, splits lines, enforces limits and rules, and returns the entries.
4. Both functions return `Result<Config, Error>`. `main` prints the entries or the error and sets the exit status. An unexpected exception is caught in `main`, reported, and gives exit status 1.

Error handling convention: expected failures are values (`Result`, `ErrorCode`), not exceptions. See
[coding standards](../development/coding-standards.md#error-handling).

## Test architecture

- **Unit tests:** Catch2 cases in `test/config_test.cpp`, discovered by `catch_discover_tests`, so each case is one CTest test. They cover normal input, invalid input, boundaries of every limit, file failures and platform behaviors (tag `[portability]`).
- **Integration tests:** six CTest tests run the built `app`: no arguments, `--version` (checks the `X.Y.Z[-TAG]+METADATA` shape), the sample file `configuration/default.conf` (expects `loaded 2 entries`), a missing file (must fail), a file with a parse error (the message must name line 2) and too many arguments (must fail).
- **Isolation:** tests that need files create them in a unique temporary directory (`TempDir` helper) and remove it afterwards. They use no external services and no files outside the repository's `configuration/` sample.
- **Dependency:** Catch2 is used only by `test/`; production targets do not link it. See [ADR 0002](decisions/0002-catch2-test-framework.md).

- **Coverage:** optional. `PROJECT_ENABLE_COVERAGE=ON` instruments the targets, and the `coverage` target runs `ctest` and writes reports to `<build dir>/coverage/`. See [Coverage](../testing/coverage.md) and [ADR 0008](decisions/0008-coverage-with-gcovr-and-llvm-cov.md).
- **Quality tools:** optional and per target: clang-format (`format`, `format-check`), clang-tidy (`PROJECT_ENABLE_CLANG_TIDY`) and sanitizers (`PROJECT_SANITIZERS`). See [ADR 0009](decisions/0009-optional-quality-tools-as-cmake-modules.md), [Static analysis](../tooling/static-analysis.md) and [Sanitizers](../testing/sanitizers.md).

## Adding a target

A new library or executable in `CMakeLists.txt` follows the existing ones:

1. Define it with `add_library` or `add_executable`, link `app_core` if it needs the library, and give it `cxx_std_23` through `app_core` or `target_compile_features`.
2. Call the five helpers, in this order: `project_set_warnings`, `project_set_portability`, `project_set_coverage`, `project_set_static_analysis`, `project_set_sanitizers`. Without them the target is built without warnings, coverage, tidy and sanitizers.
3. If tests run the new executable, add it to the `OBJECTS` list of `project_add_coverage_target(...)`.
4. Sources under `internal/` and `test/` are picked up by `format-check` and by the coverage report; sources in a new directory are not (the globs are in `tool/cmake/Format.cmake` and `tool/cmake/RunCoverage.cmake`).

## Replacing the example application

Not yet validated end-to-end; a full rename check is part of Milestone 10.

1. Replace `internal/config.*` with your sources and update the file list in `add_library(app_core ...)` in `CMakeLists.txt`.
2. Replace `internal/main.cpp` (keep the `app` target, or rename it everywhere it appears in both `CMakeLists.txt` files).
3. Replace `test/config_test.cpp` and update `add_executable(app_tests ...)` in `test/CMakeLists.txt`.
4. Update or delete the six `app.*` integration tests in `test/CMakeLists.txt`; they reference `configuration/default.conf` and the text `loaded 2 entries`.
5. Remove `configuration/default.conf` and `internal/result.hpp` if unused.
6. Change `project(cpp23_template ...)` and `VERSION` in `CMakeLists.txt` to your name and version. If you rename the `app` and `app_tests` targets, also change the `OBJECTS` list of `project_add_coverage_target(...)`.
7. Rebuild with a clean directory: `cmake --preset beta`, `cmake --build --preset beta`, `ctest --preset beta`.

## Related

[Repository structure](repository-structure.md), [Build and run](../development/build-and-run.md),
[ADR 0001](decisions/0001-result-type-instead-of-std-expected.md)
