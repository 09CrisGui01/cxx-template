# Coding standards

**Purpose:** conventions for code in this repository. They describe the existing code. Automated
formatting (`clang-format`) and static analysis (`clang-tidy`) are not configured yet (Milestone 4),
so reviewers enforce these rules by hand until then.

## Language and build

- C++23: `CXX_STANDARD 23`, required, compiler extensions off.
- Code must compile with GCC, Clang and MSVC. Do not assume every C++23 library feature exists on every toolchain; `std::expected` is the known example ([ADR 0001](../architecture/decisions/0001-result-type-instead-of-std-expected.md)).
- Do not use C++23 features where a simpler construct works.
- Code must build without warnings under the `test` preset (`PROJECT_WARNINGS_AS_ERRORS=ON`). Do not silence a warning to get a build through; fix the cause or discuss it in review.

## Layout and naming

| Item | Convention | Example |
|------|------------|---------|
| Files | `snake_case`; `.hpp` and `.cpp` | `config.cpp` |
| Namespace | `app` (rename with the project) | `app::parse_config` |
| Types | `PascalCase` | `Config`, `Error`, `ErrorCode` |
| Functions, variables | `snake_case` | `load_config_file` |
| Enumerators | `snake_case` | `ErrorCode::file_not_found` |
| Constants | `snake_case`, `inline constexpr` | `max_config_bytes` |
| Private data members | trailing underscore | `entries_` |
| Headers | `#pragma once` | |
| Indentation | 2 spaces, LF, UTF-8 (see `.editorconfig`) | |

Headers include what they use. Include project headers with quotes, standard headers with angle
brackets, in separate groups.

## Resource ownership

- Use RAII and standard containers. No raw owning pointers, no manual `new` or `delete`.
- Pass read-only parameters as `const T&`, or `std::string_view` and `std::filesystem::path` const reference for text and paths.
- Do not return references or views to local objects. A `std::string_view` returned from `Config::get` refers to the `Config`, so it is valid only while that object lives.
- Mark accessors and queries `const`, and functions whose result must not be ignored `[[nodiscard]]`.

## Error handling

- Expected failures (bad input, missing files) are returned as values: `Result<T, Error>` with an `ErrorCode` and, where useful, a 1-based line number.
- Do not use exceptions for control flow. Code in this repository does not throw on invalid input.
- Every `ErrorCode` has text in `to_string`; a test checks that none is missing.
- `Result::operator*`, `operator->` and `error()` require the matching state. Check `has_value()` first.

## Handling untrusted input

- Validate at the boundary (`parse_config`, `load_config_file`) and enforce size limits before allocating or looping over input.
- Bound reads by the checked size, not by trusting the file.
- Add a test at each limit: exactly at the limit passes, one past fails.

## Dependencies

- Prefer the C++ standard library.
- Add a third-party dependency only with a stated reason, a pinned version, and a row in the README [dependency table](../../README.md#dependencies).
- Production targets must not link test-only dependencies.

## Testing expectations

- Every behavior change comes with a test; every bug fix comes with a regression test that fails without the fix.
- Tests are deterministic and need no network, no external service and no pre-existing local files. Create files in a temporary directory and clean up.
- Cover normal input, invalid input, boundaries and failures.
- Tag Catch2 cases (`[config]`, `[file]`, `[limits]`, `[portability]`).
- A failing test must produce a nonzero exit status. Do not disable a test to make CI pass.

## Commits

Commit message and other tool conventions are in [Conventions](conventions.md).

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| Build passes locally, fails in CI on macOS or FreeBSD | libc++ differs from libstdc++; avoid relying on implementation-specific types such as the clock `rep` type. A past failure: `std::to_string` on a clock tick count was ambiguous on libc++. |
| Warning appears only on one compiler | Warning flags differ per compiler in `CompilerWarnings.cmake`. Fix it for that compiler; do not remove the flag. |

## Related

[Architecture overview](../architecture/overview.md), [Build and run](build-and-run.md)
