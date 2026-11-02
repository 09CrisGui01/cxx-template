# Unit and integration tests

**Purpose:** run the tests, add new ones and diagnose failures.
**Prerequisites:** a configured build, see [Getting started](../getting-started.md). Which Catch2 is used and why: [ADR 0002](../architecture/decisions/0002-catch2-test-framework.md).

## Run the tests

```sh
cmake --preset beta
cmake --build --preset beta
ctest --preset beta
```

Expected: `100% tests passed, 0 tests failed out of 19` (13 unit tests and 6 integration tests, as
observed on Linux with GCC 13.3 and Clang 18.1). `ctest --preset beta -N` lists them. Selecting a
subset is described in [Build and run](../development/build-and-run.md#select-tests).

## Add a unit test

1. Add a `TEST_CASE` to `test/config_test.cpp`, or a new `*_test.cpp` file with its own test cases.
2. If you added a file, list it in `add_executable(app_tests ...)` in `test/CMakeLists.txt`.
3. Tag the case (`[config]`, `[file]`, `[limits]`, `[portability]`).
4. Cover normal input, invalid input, each boundary (the limit passes, one past it fails) and each failure that can happen.
5. A test that needs a file MUST create it with the `TempDir` helper in `test/config_test.cpp`, which makes a unique temporary directory and removes it afterwards.
6. Rebuild and run `ctest --preset beta`. `catch_discover_tests` turns each case into its own CTest test, so a new case needs a reconfigure only if you added a file.

A bug fix MUST add a regression test that fails before the fix and passes after it.

## Add an integration test

Integration tests are `add_test` calls in `test/CMakeLists.txt` that run the `app` target.

- Check the exit status with `WILL_FAIL TRUE` when the command must fail.
- Check output with `PASS_REGULAR_EXPRESSION`. CTest then ignores the exit status, so a test cannot check both.
- Do not anchor the regular expression at the end of the line: on Windows the output ends in `\r\n`.
- CMake regular expressions have no `{n}` repetition; write the class out.
- A file the test needs MAY be written at configure time with `file(WRITE ...)` into `${CMAKE_CURRENT_BINARY_DIR}`, as `app.reports_line_of_parse_error` does, so no fixture is tracked.

## Diagnose a failure

| Symptom | What to do |
|---------|-----------|
| A CTest test fails | `ctest --preset beta --output-on-failure` is already the preset default. Re-run one test: `ctest --preset beta -R "<name>"`. |
| A Catch2 assertion fails | Run the binary directly for Catch2's full message: `./build/Linux/beta/test/app_tests "<test name>"`. Add `-s` to see passing assertions too. |
| An integration test fails | Run the command by hand: `./build/Linux/beta/app configuration/default.conf`, and compare with the regular expression in `test/CMakeLists.txt`. |
| Fails only on one platform | See the troubleshooting table in [Coding standards](../development/coding-standards.md#troubleshooting). |
| `No tests were found` | Configured with `BUILD_TESTING=OFF`, or the wrong build directory. |

## A failing test fails the build

Verified on Linux with GCC 13.3: a deliberately failing Catch2 case made `app_tests` exit with
status 42 and `ctest` exit with status 8, and the case was listed as failed. The case was removed
afterwards. Other platforms were not checked.

## Related

[Testing strategy](strategy.md), [Coverage](coverage.md),
[Coding standards](../development/coding-standards.md#testing-expectations)
