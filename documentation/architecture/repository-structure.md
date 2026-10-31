# Repository structure

**Purpose:** explain what every tracked directory and file is for. Generated with `git ls-files` at
Milestone 2; later milestones extend it.

## Directory tree

```text
.
├── .editorconfig
├── .gitignore
├── .github/workflows/ci.yml
├── CMakeLists.txt
├── CMakePresets.json
├── README.md
├── configuration/default.conf
├── data/
│   ├── README.md
│   ├── input/.gitkeep
│   ├── midput/.gitkeep
│   └── output/.gitkeep
├── documentation/
├── external/README.md
├── internal/
│   ├── config.cpp
│   ├── config.hpp
│   ├── main.cpp
│   └── result.hpp
├── test/
│   ├── CMakeLists.txt
│   └── config_test.cpp
└── tool/cmake/
    ├── CompilerWarnings.cmake
    └── Portability.cmake
```

`build/` appears after configuring and is not tracked.

## Directories

| Directory | Purpose | Rules |
|-----------|---------|-------|
| `internal/` | Implementation (`.cpp`) and declarations (`.hpp`) | Flat: no subdirectories. Included as `"config.hpp"` through the target include path. |
| `test/` | Automated tests and their CMake | Test-only dependencies stay here. |
| `tool/cmake/` | Reusable CMake modules | Added to `CMAKE_MODULE_PATH` by `CMakeLists.txt`. |
| `configuration/` | Program configuration files | Sample file used by an integration test. |
| `data/` | Program input (`input/`), intermediate (`midput/`) and output (`output/`) data | Contents of `midput/` and `output/` are ignored by Git. Unused by the example. |
| `external/` | Vendored third-party source | Empty; the `README.md` explains this. |
| `documentation/` | Project documentation | Start at [index](../index.md). |
| `.github/workflows/` | GitHub Actions workflow | See below. |

## Files

| File | Purpose |
|------|---------|
| `CMakeLists.txt` | Project definition, targets, language standard, option `PROJECT_WARNINGS_AS_ERRORS`, includes `test/` |
| `CMakePresets.json` | Presets `debug`, `release`, `test`, `msvc` and matching build and test presets |
| `.github/workflows/ci.yml` | CI: Linux GCC and Clang, macOS, Windows MSVC (via `build-test` job) and FreeBSD (`freebsd` job); all Debug |
| `.editorconfig` | Editor settings: UTF-8, LF, 2-space indent, final newline |
| `.gitignore` | Ignores `build/`, coverage output, runtime data, editor files, common secret file names |
| `README.md` | Overview, dependencies, quick start, platform support |
| `internal/result.hpp` | `Result<T, E>`: value-or-error type used instead of `std::expected` ([ADR 0001](decisions/0001-result-type-instead-of-std-expected.md)) |
| `tool/cmake/CompilerWarnings.cmake` | `project_set_warnings(target)`: GCC, Clang and MSVC warning flags |
| `tool/cmake/Portability.cmake` | `project_set_portability(target)`: MSVC-only flags `/utf-8`, `/Zc:__cplusplus`, `NOMINMAX` |
| `data/*/.gitkeep` | Keeps empty directories in Git |

## Files that do not exist yet

The original specification lists further files (`Dockerfile`, `Jenkinsfile`, `AGENTS.md`,
`.clang-format`, `.clang-tidy`, `.commitlintrc.json`, `package.json`, `CONTRIBUTING.md`,
`SECURITY.md`, `CHANGELOG.md`, `LICENSE.md`, `CMakeUserPresets.json.example`, and others). They are
added by the milestone that needs them, not created empty.

## Related

[Architecture overview](overview.md), [Documentation index](../index.md)
