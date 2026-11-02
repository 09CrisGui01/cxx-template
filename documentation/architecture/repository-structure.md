# Repository structure

**Purpose:** explain what every tracked directory and file is for. Checked against `git ls-files`;
each milestone that adds files updates it.

## Directory tree

```text
.
├── .clang-format
├── .clang-tidy
├── .editorconfig
├── .gitignore
├── .github/workflows/ci.yml
├── CMakeLists.txt
├── CHANGELOG.md
├── CMakePresets.json
├── README.md
├── configuration/default.conf
├── data/
│   ├── README.md
│   ├── input/.gitkeep
│   ├── midput/.gitkeep
│   └── output/.gitkeep
├── documentation/    (see the documentation index)
├── external/README.md
├── internal/
│   ├── config.cpp
│   ├── config.hpp
│   ├── main.cpp
│   └── result.hpp
├── script/.gitkeep
├── test/
│   ├── .clang-tidy
│   ├── CMakeLists.txt
│   └── config_test.cpp
└── tool/cmake/
    ├── CompilerWarnings.cmake
    ├── Coverage.cmake
    ├── Format.cmake
    ├── Portability.cmake
    ├── RunCoverage.cmake
    ├── Sanitizers.cmake
    ├── StaticAnalysis.cmake
    ├── ToolchainRequirements.cmake
    └── Version.cmake
```

`build/<os>/<preset>/` appears after configuring and is not tracked.

## Directories

| Directory | Purpose | Rules |
|-----------|---------|-------|
| `internal/` | Implementation (`.cpp`) and declarations (`.hpp`) | Flat: no subdirectories. Included as `"config.hpp"` through the target include path. |
| `test/` | Automated tests and their CMake | Test-only dependencies stay here. |
| `tool/cmake/` | Reusable CMake modules | Added to `CMAKE_MODULE_PATH` by `CMakeLists.txt`. |
| `configuration/` | Program configuration files | Sample file used by an integration test. |
| `data/` | Program input (`input/`), intermediate (`midput/`) and output (`output/`) data | Contents of `midput/` and `output/` are ignored by Git. Unused by the example. |
| `script/` | Developer automation scripts | Empty placeholder (`.gitkeep`); scripts are added when a workflow needs one. |
| `external/` | Vendored third-party source | Empty; the `README.md` explains this. |
| `documentation/` | Project documentation | Start at the [index](../index.md). Subdirectories: `architecture/` (overview, structure, `decisions/` ADRs, `requirements/` ASRs), `development/`, `testing/`, `tooling/`, `ci-cd/`. |
| `.github/workflows/` | GitHub Actions workflow | [GitHub Actions](../ci-cd/github-actions.md) |

## Files

| File | Purpose |
|------|---------|
| `CMakeLists.txt` | Project definition, targets, language standard, option `PROJECT_WARNINGS_AS_ERRORS`, includes `test/` |
| `CMakePresets.json` | Presets `alpha`, `beta`, `gamma`, `coverage`, `tidy`, `sanitize`, `tsan`, `msvc` and matching build and test presets |
| `.github/workflows/ci.yml` | CI: jobs `build-test` (Linux GCC and Clang, macOS, Windows MSVC), `coverage`, `quality` and `freebsd`; see [GitHub Actions](../ci-cd/github-actions.md) |
| `.editorconfig` | Editor settings: UTF-8, LF, 2-space indent, final newline |
| `.gitignore` | Ignores `build/`, `CMakeUserPresets.json`, `compile_commands.json`, coverage and profile data files, runtime data, editor files, common secret file names |
| `CHANGELOG.md` | Notable changes, Keep a Changelog format |
| `README.md` | Overview, dependencies, quick start, platform support |
| `internal/config.hpp`, `internal/config.cpp` | Configuration parser and loader, error codes, input limits |
| `internal/main.cpp` | The `app` executable: arguments, output, exit codes, `--version` |
| `test/CMakeLists.txt` | Test executable, Catch2 acquisition, CTest integration tests |
| `test/config_test.cpp` | Catch2 unit tests |
| `configuration/default.conf` | Sample configuration read by an integration test |
| `data/README.md`, `external/README.md` | Explain the empty `data/` and `external/` directories |
| `script/.gitkeep` | Keeps the empty `script/` directory in Git |
| `internal/result.hpp` | `Result<T, E>`: value-or-error type used instead of `std::expected` ([ADR 0001](decisions/0001-result-type-instead-of-std-expected.md)) |
| `tool/cmake/CompilerWarnings.cmake` | `project_set_warnings(target)`: GCC, Clang and MSVC warning flags |
| `tool/cmake/ToolchainRequirements.cmake` | Soft minimum compiler versions and `project_check_toolchain()`, which logs the compiler and warns below the minimum |
| `tool/cmake/Coverage.cmake` | Option `PROJECT_ENABLE_COVERAGE`, `project_set_coverage(target)` and the `coverage` target ([ADR 0008](decisions/0008-coverage-with-gcovr-and-llvm-cov.md)) |
| `.clang-format` | clang-format style: Google, 100 columns |
| `.clang-tidy`, `test/.clang-tidy` | clang-tidy checks; the test one inherits and disables two checks, with reasons |
| `tool/cmake/Format.cmake` | Targets `format` and `format-check` |
| `tool/cmake/StaticAnalysis.cmake` | Option `PROJECT_ENABLE_CLANG_TIDY` and `project_set_static_analysis(target)` |
| `tool/cmake/Sanitizers.cmake` | Option `PROJECT_SANITIZERS` and `project_set_sanitizers(target)` |
| `tool/cmake/RunCoverage.cmake` | CMake script run by the `coverage` target: runs `ctest`, writes the reports |
| `tool/cmake/Version.cmake` | Validates `PROJECT_VERSION_TAG` and builds `PROJECT_VERSION_TAGGED`, `PROJECT_VERSION_METADATA` and `PROJECT_VERSION_FULL` ([ADR 0006](decisions/0006-versioning-without-final-release-tag.md)) |
| `tool/cmake/Portability.cmake` | `project_set_portability(target)`: MSVC-only flags `/utf-8`, `/Zc:__cplusplus`, `NOMINMAX` |
| `data/*/.gitkeep` | Keeps empty directories in Git |

## Files that do not exist yet

The original specification lists further files (`Dockerfile`, `Jenkinsfile`, `AGENTS.md`,
`.commitlintrc.json`, `package.json`, `CONTRIBUTING.md`,
`SECURITY.md`, `LICENSE.md`, `CMakeUserPresets.json.example`, and others). They are
added by the milestone that needs them, not created empty.

## Related

[Architecture overview](overview.md), [Documentation index](../index.md)
