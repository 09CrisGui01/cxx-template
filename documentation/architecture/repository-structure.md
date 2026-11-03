# Repository structure

**Purpose:** explain what every tracked directory and file is for. Checked against `git ls-files`;
each milestone that adds files updates it.

## Directory tree

```text
.
├── .clang-format
├── .clang-tidy
├── .commitlintrc.json
├── .dockerignore
├── .editorconfig
├── .gitignore
├── .husky/
│   ├── commit-msg
│   └── pre-commit
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── config.yml
│   │   └── feature_request.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/ci.yml
├── AUTHORS.md
├── CMakeLists.txt
├── CHANGELOG.md
├── CMakePresets.json
├── CODE-OF-CONDUCT.md
├── CONTRIBUTORS.md
├── Dockerfile
├── README.md
├── RELEASES.md
├── compose.yaml
├── package-lock.json
├── package.json
├── configuration/default.conf
├── data/
│   ├── README.md
│   ├── input/.gitkeep
│   ├── midput/.gitkeep
│   └── output/.gitkeep
├── documentation/    (see the documentation index)
├── external/
│   ├── Catch2/    (submodule)
│   ├── README.md
│   └── spdlog/    (submodule)
├── internal/
│   ├── config.cpp
│   ├── config.hpp
│   ├── log.cpp
│   ├── log.hpp
│   ├── main.cpp
│   └── result.hpp
├── script/.gitkeep
├── test/
│   ├── .clang-tidy
│   ├── CMakeLists.txt
│   ├── config_test.cpp
│   └── log_test.cpp
└── tool/cmake/
    ├── CompilerWarnings.cmake
    ├── Coverage.cmake
    ├── Documentation.cmake
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
| `external/` | Third-party libraries as Git submodules: `spdlog/`, `Catch2/` | Do not edit inside a submodule. See its `README.md` and [ADR 0014](decisions/0014-third-party-libraries-as-submodules.md). |
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
| `package.json`, `package-lock.json` | Optional Node.js developer tools: Husky and Commitlint, pinned. Not read by CMake ([ADR 0011](decisions/0011-optional-node-tooling-for-git-hooks.md)) |
| `.commitlintrc.json` | Commit message rules: allowed types and scopes, length warnings |
| `.husky/commit-msg`, `.husky/pre-commit` | Git hooks installed by `npm install`: commit message check; format, secret and shell script checks |
| `tool/cmake/Documentation.cmake` | `project_add_doxygen_target()`: the optional `doxygen` target ([ADR 0012](decisions/0012-doxygen-for-api-documentation.md)) |
| `Dockerfile` | Multi-stage image definition: `dev`, `build`, `test`, `coverage`, `coverage-report`, `runtime` ([ADR 0013](decisions/0013-multi-stage-container-image.md)) |
| `compose.yaml` | Optional Compose services `dev`, `test` and `app` |
| `.dockerignore` | Keeps `.git`, `build/`, secrets, reports and documentation out of the image build context |
| `RELEASES.md` | Released versions with Git tag and date, and how a release is made |
| `AUTHORS.md`, `CONTRIBUTORS.md` | Project owners; everyone else who contributed. Both are empty lists to fill in when a project is created from the template |
| `CODE-OF-CONDUCT.md` | Expected behavior and enforcement. Contains the placeholder `{{contact-email}}` to replace |
| `.github/PULL_REQUEST_TEMPLATE.md` | Text GitHub pre-fills in a new pull request: what, how checked, checklist |
| `.github/ISSUE_TEMPLATE/` | Bug report and feature request forms; `config.yml` disables blank issues |
| `internal/config.hpp`, `internal/config.cpp` | Configuration parser and loader, error codes, input limits |
| `internal/log.hpp`, `internal/log.cpp` | Log level names, standard-error sink, level from `APP_LOG_LEVEL` ([ADR 0010](decisions/0010-logging-with-spdlog.md)) |
| `internal/main.cpp` | The `app` executable: arguments, output, exit codes, `--version` |
| `test/CMakeLists.txt` | Test executable, Catch2 acquisition, CTest integration tests |
| `test/config_test.cpp`, `test/log_test.cpp` | Catch2 unit tests |
| `configuration/default.conf` | Sample configuration read by an integration test |
| `data/README.md` | Explains the empty `data/` directory |
| `external/README.md` | Lists the submodules and how to clone and update them |
| `.gitmodules` | Locations and URLs of the two submodules; the commits are recorded in the repository |
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

The original specification lists further files (`Jenkinsfile`, `AGENTS.md`,
`CONTRIBUTING.md`,
`SECURITY.md`, `LICENSE.md`, `CMakeUserPresets.json.example`, and others). They are
added by the milestone that needs them, not created empty.

## Related

[Architecture overview](overview.md), [Documentation index](../index.md)
