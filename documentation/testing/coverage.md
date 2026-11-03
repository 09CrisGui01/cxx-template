# Coverage

**Purpose:** measure which lines of `internal/` the tests execute, and produce terminal, HTML and
machine-readable reports. Coverage is **optional**: no normal configure, build or test step needs it.
The design is recorded in [ADR 0008](../architecture/decisions/0008-coverage-with-gcovr-and-llvm-cov.md) and
[ASR 0006](../architecture/requirements/0006-optional-coverage-measurement.md).

Coverage measures what the tests execute. It does not show that the code is correct, that the
assertions are meaningful or that the code is secure.

## Supported toolchains

| Compiler | Instrumentation | Report tools | Reports |
|----------|----------------|--------------|---------|
| GCC | `--coverage` | `gcov` (from GCC) and [gcovr](https://gcovr.com) | terminal, HTML, Cobertura XML |
| Clang | source-based (`-fprofile-instr-generate -fcoverage-mapping`) | `llvm-profdata` and `llvm-cov`, same major version as Clang | terminal, HTML, LCOV |
| MSVC | not supported | none | configuring with coverage enabled stops with an error |
| Apple Clang | uses the Clang path; **untested** | `xcrun llvm-cov` is not searched for; **untested** | |

Verified locally on Linux only: GCC 13.3.0 with gcov 13.3.0 and gcovr 8.8, and Clang 18.1.3 with
llvm-cov and llvm-profdata 18.1.3. Cobertura output exists for GCC only because `llvm-cov` does not
write it.

## Prerequisites

| Tool | Needed for | Install (Debian/Ubuntu, **untested** unless noted) |
|------|-----------|------------------------------------|
| gcovr | GCC reports | `pipx install gcovr==8.8` (version observed locally; installed there with `pip`) |
| llvm-cov, llvm-profdata | Clang reports | `apt install llvm` (the versioned `llvm-cov-18` is preferred when it matches Clang) |
| Clang profile runtime | linking Clang-instrumented programs | `apt install libclang-rt-18-dev`. Without it the link fails with `cannot find .../libclang_rt.profile-x86_64.a`. Installing it this way was done locally. |

gcovr needs Python. That is why coverage is optional: the default build needs no Python
([ASR 0002](../architecture/requirements/0002-minimal-core-toolchain.md)). If a report tool is missing,
CMake warns at configure time, still instruments the targets and does not create the `coverage` target.

## Run it (GCC)

```sh
cmake --preset coverage
cmake --build --preset coverage-report
```

The second command builds, runs `ctest` and writes the reports. Expected: all 28 tests pass, a
per-file table, then `-- Coverage reports written to .../build/Linux/coverage/coverage`.

## Run it (Clang)

The coverage build directory records its compiler, so use a separate directory:

```sh
CXX=clang++ cmake --preset coverage -B build/Linux/coverage-clang
cmake --build build/Linux/coverage-clang --target coverage
```

## Report locations

Reports are under the build directory, which Git ignores:

| File | Compiler | Content |
|------|----------|---------|
| `<build dir>/coverage/html/index.html` | both | HTML report |
| `<build dir>/coverage/cobertura.xml` | GCC | Cobertura XML for CI tools |
| `<build dir>/coverage/lcov.info` | Clang | LCOV |
| `<build dir>/coverage/coverage.profdata`, `raw/` | Clang | merged and raw profile data |

For the preset above `<build dir>` is `build/Linux/coverage`. Every run deletes the previous
`coverage/` directory and, for GCC, stale `.gcda` counter files, so a report never mixes runs.

## What is measured

Lines of `internal/`. Test code (`test/`), third-party code (`_deps/`) and system headers are
excluded. The `app` executable is included, because the integration tests run it.

Observed on 2026-11-02, Linux, one run each (the tools count lines differently, so the figures
differ):

| Toolchain | Line coverage | Branch coverage |
|-----------|---------------|-----------------|
| GCC 13.3 + gcovr 8.8 | 93.3% (167 of 179 lines) | 63.9% (191 of 299) |
| Clang 18.1 + llvm-cov 18 | 94.02% (220 of 234 lines) | 91.80% (112 of 122) |

Lines that no test executes, as reported by GCC: `internal/config.cpp` lines 46 (the fallback
return of `to_string` for an invalid `ErrorCode`) and 120, 128 and 135 (the three `read_failed`
returns for I/O errors while reading a file), `internal/log.cpp` lines 39 and 79 (the fallbacks for
an invalid `Level` value) and `internal/main.cpp` lines 80 to 85 (the handlers
for unexpected exceptions). The I/O error paths need a failing read, which cannot be produced
deterministically on every platform, and the exception handlers need an exception such as
`std::bad_alloc`, so no test covers them. Do not treat the percentages as
a quality score.

## Threshold

`PROJECT_COVERAGE_MIN_LINE` is the minimum line coverage in percent that the `coverage` target
enforces. The default is `0`, which disables the check, so the template passes untouched.

```sh
cmake --preset coverage -DPROJECT_COVERAGE_MIN_LINE=90
cmake --build --preset coverage-report
```

Below the minimum the target fails (verified: with 90 it passed and with 99 it failed, on both
toolchains) and the reports are still written. Choose a value that your project keeps; raising it
only when coverage rises avoids a threshold that tests are written to satisfy.

## CMake options

| Option | Default | Effect |
|--------|---------|--------|
| `PROJECT_ENABLE_COVERAGE` | `OFF` | Instruments targets that call `project_set_coverage()` and creates the `coverage` target. Needs `BUILD_TESTING=ON` and GCC or Clang. The `coverage` preset turns it on. |
| `PROJECT_COVERAGE_MIN_LINE` | `0` | Minimum line coverage in percent; `0` disables the check |

Use a Debug build: optimization merges and removes lines, and CMake warns otherwise.

## Add a new target to coverage

Call `project_set_coverage(<target>)` after the target is defined, and add the target to the
`OBJECTS` list of `project_add_coverage_target(...)` at the end of `CMakeLists.txt` if it is an
executable that tests run.

## Troubleshooting

| Symptom | Cause and fix |
|---------|--------------|
| `unknown target 'coverage'` | A report tool was not found; read the warning printed at configure time. |
| `cannot find .../libclang_rt.profile-x86_64.a` | Install the Clang profile runtime (see Prerequisites). |
| `warning: 1 functions have mismatched data` (Clang) | Printed by `llvm-cov` for the unit-test binary when merged with the `app` profile. Observed with one profile whose function had hash `0`, and only for a standard-library `std::filesystem::path` constructor, which the report excludes. Cause not fully confirmed. The reported figures for `internal/` were not affected as far as inspected. |
| Report shows 0% or no files | Tests did not run, or the build directory belongs to another compiler. Delete it and configure again. |
| `PROJECT_ENABLE_COVERAGE requires BUILD_TESTING=ON` | Configure with `-DBUILD_TESTING=ON`. |
| gcov version warnings or empty report | gcov must match the GCC version; CMake looks for `gcov-<major>` first. |

## CI

The GitHub workflow has a `coverage` job (Linux, GCC) that uploads the report directory as an
artifact (details in [GitHub Actions](../ci-cd/github-actions.md)). It was **not run on GitHub** by
the author; check its first run. Jenkins coverage publication arrives in Milestone 8.

## Related

[Testing strategy](strategy.md), [Unit and integration tests](unit-and-integration-tests.md),
[Build and run](../development/build-and-run.md)
