# Coding standards

**Purpose:** conventions for code in this repository. They describe the existing code. Automated
formatting (`clang-format`) and static analysis (`clang-tidy`) are not configured yet (Milestone 4),
so reviewers enforce these rules by hand until then.

Requirement keywords (MUST, SHOULD, MAY and their negations) have the meaning given in
[Conventions](conventions.md#normative-language). Tool, Git, version and documentation conventions
are in that page, not here.

## Language and build

- Code MUST be C++23: `CXX_STANDARD 23`, required, compiler extensions off.
- Code MUST compile with GCC, Clang and MSVC. It MUST NOT assume every C++23 library feature exists on every toolchain; `std::expected` is the known example ([ADR 0001](../architecture/decisions/0001-result-type-instead-of-std-expected.md)).
- C++23 features SHOULD NOT be used where a simpler construct works.
- Code MUST build without warnings under the `test` preset (`PROJECT_WARNINGS_AS_ERRORS=ON`). A warning MUST NOT be silenced to get a build through; the cause is fixed or the matter is discussed in review.

## Layout and naming

| Item | Convention | Example |
|------|------------|---------|
| Files | `snake_case`; `.hpp` and `.cpp` | `config.cpp` |
| Namespace | `app` (renamed with the project) | `app::parse_config` |
| Types | `PascalCase` | `Config`, `Error`, `ErrorCode` |
| Functions, variables | `snake_case` | `load_config_file` |
| Enumerators | `snake_case` | `ErrorCode::file_not_found` |
| Constants | `snake_case`, `inline constexpr` | `max_config_bytes` |
| Private data members | trailing underscore | `entries_` |
| Headers | `#pragma once` | |
| Indentation | 2 spaces, LF, UTF-8 (see `.editorconfig`) | |

- Headers MUST include what they use.
- Project headers MUST be included with quotes and standard headers with angle brackets, in separate groups.

## Resource ownership

- Code MUST use RAII and standard containers. Raw owning pointers and manual `new` or `delete` MUST NOT be used.
- Read-only parameters SHOULD be passed as `const T&`, or as `std::string_view` for text and `const std::filesystem::path&` for paths.
- Code MUST NOT return references or views to local objects. A `std::string_view` returned from `Config::get` refers to the `Config`, so it is valid only while that object lives.
- Accessors and queries MUST be `const`. Functions whose result must not be ignored SHOULD be `[[nodiscard]]`.

## Error handling

- Expected failures (bad input, missing files) MUST be returned as values: `Result<T, Error>` with an `ErrorCode` and, where useful, a 1-based line number.
- Exceptions MUST NOT be used for control flow. Code in this repository does not throw on invalid input.
- Every `ErrorCode` MUST have text in `to_string`; a test checks that none is missing.
- `Result::operator*`, `operator->` and `error()` require the matching state. Callers MUST check `has_value()` first.

## Handling untrusted input

- Input MUST be validated at the boundary (`parse_config`, `load_config_file`), and size limits MUST be enforced before allocating or looping over input.
- Reads MUST be bounded by the checked size, not by trusting the file.
- Each limit MUST have a test at its boundary: exactly at the limit passes, one past fails.

## Dependencies

- The C++ standard library SHOULD be preferred.
- A third-party dependency MUST NOT be added without a stated reason, a pinned version and a row in the README [dependency table](../../README.md#dependencies).
- Production targets MUST NOT link test-only dependencies.

## Testing expectations

- Every behavior change MUST come with a test. Every bug fix MUST come with a regression test that fails without the fix.
- Tests MUST be deterministic and MUST NOT need the network, an external service or a pre-existing local file. They create files in a temporary directory and clean up.
- Tests MUST cover normal input, invalid input, boundaries and failures.
- Catch2 cases SHOULD be tagged (`[config]`, `[file]`, `[limits]`, `[portability]`).
- A failing test MUST produce a nonzero exit status. A test MUST NOT be disabled to make CI pass.

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| Build passes locally, fails in CI on macOS or FreeBSD | libc++ differs from libstdc++; avoid relying on implementation-specific types such as the clock `rep` type. A past failure: `std::to_string` on a clock tick count was ambiguous on libc++. |
| Warning appears only on one compiler | Warning flags differ per compiler in `CompilerWarnings.cmake`. Fix it for that compiler; do not remove the flag. |

## Related

[Conventions](conventions.md), [Architecture overview](../architecture/overview.md),
[Build and run](build-and-run.md)
