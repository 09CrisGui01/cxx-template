# Build and run

**Purpose:** canonical reference for configuring, building, testing and running the project.

**Prerequisites:** [Environment setup](environment-setup.md) done.

## Presets

Defined in `CMakePresets.json`. Binary directory is `build/<os>/<preset>`; `build/` is not tracked. See [Build directories](#build-directories).

| Configure preset | Stage | Generator | Build type | Notes |
|------------------|-------|-----------|------------|-------|
| `alpha` | development | Ninja | Debug | |
| `beta` | testing and debugging | Ninja | Debug | `PROJECT_WARNINGS_AS_ERRORS=ON` |
| `gamma` | pre-release | Ninja | Release | |
| `coverage` | none | Ninja | Debug | `PROJECT_ENABLE_COVERAGE=ON`; see [Coverage](../testing/coverage.md) |
| `tidy` | none | Ninja | Debug | `PROJECT_ENABLE_CLANG_TIDY=ON`; see [Static analysis](../tooling/static-analysis.md) |
| `sanitize` | none | Ninja | Debug | `PROJECT_SANITIZERS=address;undefined`; see [Sanitizers](../testing/sanitizers.md) |
| `tsan` | none | Ninja | Debug | `PROJECT_SANITIZERS=thread` |
| `msvc` | none | Ninja Multi-Config | per build preset | Windows hosts only; compiler `cl` |

The preset names follow the stage tags `alpha`, `beta` and `gamma` (see
[Conventions](conventions.md#versions)). The name of a preset does not set `PROJECT_VERSION_TAG`:
the stage tag and the preset are chosen separately, and the preset name is only recorded in the
version metadata.

Build and test presets are named after their configure preset. Exceptions:

| Configure preset | Build presets | Test presets |
|------------------|---------------|--------------|
| `coverage` | `coverage` (everything) and `coverage-report` (the `coverage` target) | `coverage` |
| `msvc` | `msvc-debug`, `msvc-release` (one per configuration of the multi-config generator) | `msvc-debug`, `msvc-release` |

`msvc` has no stage name because it is a platform preset, not a stage.

```sh
cmake --preset <name>
cmake --build --preset <name>
ctest --preset <name>
```

Test output is shown for failing tests (`outputOnFailure`).

## Targets

Besides `app`, `app_core` and `app_tests` ([Architecture overview](../architecture/overview.md#cmake-targets)),
these utility targets exist when their tool is available:

| Target | Created when | Effect |
|--------|--------------|--------|
| `coverage` | `PROJECT_ENABLE_COVERAGE=ON` and the report tools are found | Runs `ctest` and writes the coverage reports ([Coverage](../testing/coverage.md)) |
| `format` | `clang-format` is found | Rewrites `internal/*` and `test/*.cpp` in place |
| `format-check` | `clang-format` is found | Fails if any of those files differs from `.clang-format` ([Static analysis](../tooling/static-analysis.md)) |

Run one with `cmake --build --preset <name> --target <target>`.

## Build directories

Every preset builds into `build/<os>/<preset>/`, so one source tree can be built on several
operating systems without the build directories colliding. `<os>` is the CMake host system name
(`${hostSystemName}` in `CMakePresets.json`).

| Host | `<os>` | Status |
|------|--------|--------|
| Linux | `Linux` | verified (`build/Linux/beta`, `build/Linux/alpha`) |
| macOS | `Darwin` | from CMake's definition; not observed by the author |
| Windows | `Windows` | from CMake's definition; not observed by the author |
| FreeBSD | `FreeBSD` | from CMake's definition; not observed by the author |

## CMake options

| Option | Default | Effect |
|--------|---------|--------|
| `PROJECT_WARNINGS_AS_ERRORS` | `OFF` | Adds `-Werror` (GCC, Clang) or `/WX` (MSVC) |
| `BUILD_TESTING` | `ON` | Builds `app_tests` and registers CTest tests |
| `PROJECT_VERSION_TAG` | `alpha` | Stage tag: `alpha`, `beta`, `gamma`, or empty for a final release. Any other value stops the configure. |
| `PROJECT_BUILD_PRESET` | set by each preset; `none` without one | Preset name recorded in the version metadata. Not meant to be set by hand. |
| `PROJECT_ENABLE_COVERAGE` | `OFF` | Instrument for coverage and add the `coverage` target; see [Coverage](../testing/coverage.md) |
| `PROJECT_COVERAGE_MIN_LINE` | `0` | Minimum line coverage in percent; `0` disables the check |
| `PROJECT_ENABLE_CLANG_TIDY` | `OFF` | Run clang-tidy while compiling; findings are errors |
| `PROJECT_SANITIZERS` | empty | `address`, `undefined`, `thread` (semicolon-separated) |
| `CMAKE_BUILD_TYPE` | `Release` if unset (single-config generators only) | Standard CMake variable |
| `CMAKE_EXPORT_COMPILE_COMMANDS` | `ON` (set in `CMakeLists.txt`) | Writes `compile_commands.json` into the build directory for editors and tools; Git ignores it |
| `PROJECT_MIN_GNU_VERSION`, `PROJECT_MIN_CLANG_VERSION`, `PROJECT_MIN_APPLECLANG_VERSION`, `PROJECT_MIN_MSVC_VERSION` | see README | Soft compiler minimums; a compiler below its minimum only triggers a configure warning |
| `PROJECT_GCOVR`, `PROJECT_GCOV`, `PROJECT_LLVM_COV`, `PROJECT_LLVM_PROFDATA`, `PROJECT_CLANG_FORMAT`, `PROJECT_CLANG_TIDY` | found on `PATH` | Cache variables holding the path of each optional tool; set one to use a specific installation |

The soft compiler minimums are defined in `tool/cmake/ToolchainRequirements.cmake`; the values are
in the README [dependency table](../../README.md#dependencies).

Version tag and metadata are documented in [Conventions](conventions.md#versions). Set
`SOURCE_DATE_EPOCH` in the environment before configuring to make the timestamp in the metadata
reproducible. The configure step prints the full version (`-- Version: ...`).

Without presets:

```sh
cmake -S . -B build/Linux/manual -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/Linux/manual
ctest --test-dir build/Linux/manual
```

## Run the application

```sh
./build/<os>/<preset>/app [--version | config-file]
```

`--version` prints the full version, `X.Y.Z-TAG+METADATA` (for example
`0.1.0-alpha+20261101.beta.Linux.x86-64.GNU-13-3-0`), and exits with status 0. With no
argument the application prints `app X.Y.Z`.

| Exit status | Meaning |
|-------------|---------|
| 0 | Success |
| 1 | The config file could not be loaded or parsed, or an unexpected exception occurred (message on stderr) |
| 2 | Usage error (more than one argument) |

The config format and limits are described in [Architecture overview](../architecture/overview.md#example-application).
On the multi-config `msvc` preset the executable is expected under `build/Windows/msvc/<Config>/`; this path
is not verified.

## Select tests

```sh
ctest --preset beta -N                    # list tests without running
ctest --preset beta -R "byte order"       # run tests whose name matches a regex
./build/Linux/beta/test/app_tests "[portability]"   # run Catch2 tests by tag
```

Catch2 tags in use: `[config]`, `[file]`, `[limits]`, `[portability]`. CTest does not receive the
tags as labels, so `ctest -L` does not select by tag.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Target `format-check` fails | Run `cmake --build --preset alpha --target format` and review the diff. |
| Build error mentioning warnings only with the `beta` preset | That preset enables warnings-as-errors. Fix the warning; do not disable the flag. |
| `ctest` reports "No tests were found" | Configure was run with `BUILD_TESTING=OFF`, or you are in the wrong build directory. |

## Related

[Getting started](../getting-started.md), [Architecture overview](../architecture/overview.md)
