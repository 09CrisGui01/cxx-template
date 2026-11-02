# Sanitizers

**Purpose:** find memory errors, undefined behavior and data races at run time by running the tests
under AddressSanitizer, UndefinedBehaviorSanitizer and ThreadSanitizer. Sanitizers are **optional**:
a normal build does not use them. Design: [ADR 0009](../architecture/decisions/0009-optional-quality-tools-as-cmake-modules.md),
requirement: [ASR 0007](../architecture/requirements/0007-findings-fail-the-run.md).

## Supported toolchains

| Compiler | Supported | Notes |
|----------|-----------|-------|
| GCC | yes (Linux, verified 13.3) | needs the libasan, libubsan and libtsan runtime packages that come with GCC on most distributions |
| Clang | yes (Linux, verified 18.1) | needs the Clang runtime package, `libclang-rt-18-dev` on Debian and Ubuntu. Installed locally for coverage. |
| MSVC | no | configuring with sanitizers enabled stops with an error |
| macOS, FreeBSD | **untested** | |

## Run them

```sh
cmake --preset sanitize        # AddressSanitizer + UndefinedBehaviorSanitizer, Debug
cmake --build --preset sanitize
ctest --preset sanitize

cmake --preset tsan            # ThreadSanitizer, Debug
cmake --build --preset tsan
ctest --preset tsan
```

For Clang, use a separate build directory, because the directory remembers its compiler:

```sh
CXX=clang++ cmake --preset sanitize -B build/Linux/sanitize-clang
cmake --build build/Linux/sanitize-clang
(cd build/Linux/sanitize-clang && ctest --output-on-failure)
```

Expected: `100% tests passed, 0 tests failed out of 19`. Verified on Linux: both presets with GCC
13.3 and with Clang 18.1.

## Options

| Option | Default | Effect |
|--------|---------|--------|
| `PROJECT_SANITIZERS` | empty (off) | Semicolon-separated list of `address`, `undefined`, `thread`. `thread` cannot be combined with `address`. Any other value is a configure error. |

UndefinedBehaviorSanitizer is built with `-fno-sanitize-recover=undefined`, so a finding aborts the
program and fails the test. Without that flag it would only print a message and the test would still
pass ([ASR 0007](../architecture/requirements/0007-findings-fail-the-run.md)).

The `sanitize` test preset also sets `ASAN_OPTIONS=detect_stack_use_after_return=1:strict_string_checks=1`
and `UBSAN_OPTIONS=print_stacktrace=1`.

## Evidence that they detect problems

On 2026-11-01 three deliberately faulty Catch2 cases were added to the test file, run, and removed:

| Fault | `sanitize` (GCC and Clang) | `tsan` (GCC and Clang) |
|-------|---------------------------|------------------------|
| Read one element past a `std::vector` | reported `heap-buffer-overflow`; exit status 1 | not detected (not its job) |
| `INT_MAX + 1` | reported `runtime error: signed integer overflow`; exit status 1 | not detected (not its job) |
| Two threads incrementing one `int` | not detected (not its job) | reported a data race; exit status 66 |

## What is not covered

- The example application starts no threads, so ThreadSanitizer finds nothing to check in it. It is provided because a project built from this template may add threads. [likely]
- Catch2 is not instrumented; only this project's targets are.
- Leak detection (LeakSanitizer, part of AddressSanitizer on Linux) was not checked separately; whether it was active in the build environment is unknown.
- MemorySanitizer is not supported.
- Sanitizers find only what the tests execute; they do not replace review, fuzzing or tests for invalid input.

## Troubleshooting

| Symptom | Cause and fix |
|---------|--------------|
| Link error `cannot find libclang_rt.asan...` | Install the Clang runtime package (see the table). |
| `Unknown sanitizer` | `PROJECT_SANITIZERS` holds a value other than `address`, `undefined`, `thread`. |
| `The thread and address sanitizers cannot be combined` | Use two build directories. |
| `LeakSanitizer does not work under ptrace` | Run outside a debugger, or set `ASAN_OPTIONS=detect_leaks=0` for that run. |
| Slow tests | Sanitizers slow programs by a factor of two to several; this is expected. |

## Related

[Testing strategy](strategy.md), [Formatting, static analysis and warnings](../tooling/static-analysis.md),
[Coverage](coverage.md)
