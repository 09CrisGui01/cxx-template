# Build and run

**Purpose:** canonical reference for configuring, building, testing and running the project.

**Prerequisites:** [Environment setup](environment-setup.md) done.

## Presets

Defined in `CMakePresets.json`. Binary directory is `build/<os>/<preset>`; `build/` is not tracked. See [Build directories](#build-directories).

| Configure preset | Generator | Build type | Notes |
|------------------|-----------|------------|-------|
| `debug` | Ninja | Debug | |
| `release` | Ninja | Release | |
| `test` | Ninja | Debug | `PROJECT_WARNINGS_AS_ERRORS=ON` |
| `msvc` | Ninja Multi-Config | per build preset | Windows hosts only; compiler `cl` |

Build and test presets have the same names as the configure presets, plus `msvc-debug` and
`msvc-release` for the multi-config `msvc` preset.

```sh
cmake --preset <name>
cmake --build --preset <name>
ctest --preset <name>
```

Test output is shown for failing tests (`outputOnFailure`).

## Build directories

Every preset builds into `build/<os>/<preset>/`, so one source tree can be built on several
operating systems without the build directories colliding. `<os>` is the CMake host system name
(`${hostSystemName}` in `CMakePresets.json`).

| Host | `<os>` | Status |
|------|--------|--------|
| Linux | `Linux` | verified (`build/Linux/test`, `build/Linux/debug`) |
| macOS | `Darwin` | from CMake's definition; not observed by the author |
| Windows | `Windows` | from CMake's definition; not observed by the author |
| FreeBSD | `FreeBSD` | from CMake's definition; not observed by the author |

## CMake options

| Option | Default | Effect |
|--------|---------|--------|
| `PROJECT_WARNINGS_AS_ERRORS` | `OFF` | Adds `-Werror` (GCC, Clang) or `/WX` (MSVC) |
| `BUILD_TESTING` | `ON` | Builds `app_tests` and registers CTest tests |
| `CMAKE_BUILD_TYPE` | `Release` if unset (single-config generators only) | Standard CMake variable |

Without presets:

```sh
cmake -S . -B build/Linux/manual -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/Linux/manual
ctest --test-dir build/Linux/manual
```

## Run the application

```sh
./build/<os>/<preset>/app [config-file]
```

| Exit status | Meaning |
|-------------|---------|
| 0 | Success |
| 1 | The config file could not be loaded or parsed (message on stderr) |
| 2 | Usage error (more than one argument) |

The config format and limits are described in [Architecture overview](../architecture/overview.md#example-application).
On the multi-config `msvc` preset the executable is expected under `build/Windows/msvc/<Config>/`; this path
is not verified.

## Select tests

```sh
ctest --preset test -N                    # list tests without running
ctest --preset test -R "byte order"       # run tests whose name matches a regex
./build/Linux/test/test/app_tests "[portability]"   # run Catch2 tests by tag
```

Catch2 tags in use: `[config]`, `[file]`, `[limits]`, `[portability]`. CTest does not receive the
tags as labels, so `ctest -L` does not select by tag.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Build error mentioning warnings only with the `test` preset | That preset enables warnings-as-errors. Fix the warning; do not disable the flag. |
| `ctest` reports "No tests were found" | Configure was run with `BUILD_TESTING=OFF`, or you are in the wrong build directory. |

## Related

[Getting started](../getting-started.md), [Architecture overview](../architecture/overview.md)
