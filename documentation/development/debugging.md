# Debugging

**Purpose:** show how to debug the example application with GDB and how to check it with Valgrind.
These tools are optional and are not wired into the default build. For memory errors found while
tests run, the sanitizers are the first choice ([Sanitizers](../testing/sanitizers.md)).

## Prerequisites

GDB and Valgrind. The versions that were used are in the README
[dependency table](../../README.md#dependencies). Valgrind runs on Linux; this page does not cover
other systems.

## Debugging with GDB

Build with the `alpha` preset, which is a Debug build with debug information:

```sh
cmake --preset alpha
cmake --build --preset alpha
gdb --args ./build/Linux/alpha/app configuration/default.conf
```

A non-interactive example that stops in the parser and prints the call stack:

```sh
gdb -batch -ex "break app::parse_config" -ex run -ex bt -ex continue \
  --args ./build/Linux/alpha/app configuration/default.conf
```

To debug one unit test, run the test executable with a Catch2 test name:

```sh
gdb --args ./build/Linux/alpha/test/app_tests "parse_config rejects malformed lines with line numbers"
```

With a Release build (`gamma`) the compiler removes variables and reorders code, so GDB shows less.

## Memory checking with Valgrind

CTest has a memory check mode. It runs every selected test under Valgrind and reports errors:

```sh
cmake --preset alpha
cmake --build --preset alpha
ctest --test-dir build/Linux/alpha -T memcheck
```

`ctest --preset alpha -T memcheck` does not work, because CTest then looks for its configuration in
the source directory; give the build directory with `--test-dir`. Add `-R <pattern>` to select
tests and `-j <n>` to run tests in parallel. The log files are in
`build/Linux/alpha/Testing/Temporary/MemoryChecker.<test number>.log`. A run with no memory errors
ends with `Memory checking results:` followed by nothing.

Valgrind and the sanitizers MUST NOT be combined in one build. Use the `alpha` preset for Valgrind
and the `sanitize` preset for the sanitizers.

## Verified results

Checked on Linux with GCC 13.3: the GDB commands above stop at `app::parse_config` and print the
call stack, and `ctest -T memcheck` over all tests passes with no memory errors reported. Not
checked: Valgrind on Clang builds, and any other operating system.

## Related

[Sanitizers](../testing/sanitizers.md), [Build and run](build-and-run.md), [Tool evaluation](../tooling/tool-evaluation.md)
