# ADR 0001: Result type instead of std::expected

- **Status:** Accepted
- **Date:** 2026-10-31

## Context

Error handling returns values, not exceptions. `std::expected` (C++23) is the natural fit. The
first implementation used it. Building with Clang 18.1.3 and libstdc++ 13 (the Ubuntu 24.04
toolchain) failed on Linux with `no template named 'expected' in namespace 'std'`; the same code
built with GCC 13.3. `clang-tidy` 18 uses the same headers and is expected to fail the same way;
that was not tested.

## Decision

We use `app::Result<T, E>` (`internal/result.hpp`), a minimal value-or-error type built on
`std::variant`. Its interface (`has_value`, `operator bool`, `operator*`, `operator->`, `error`) is
a subset of `std::expected`, so call sites can switch back with small edits.

## Alternatives considered

- **`std::expected` only, require newer Clang or libc++:** excludes the default Ubuntu 24.04 Clang and clang-tidy.
- **`std::expected` with a fallback chosen by `#if`:** two code paths to maintain and test.
- **Third-party `expected` library:** a new dependency for one small type.
- **Exceptions:** conflicts with the error-handling convention.

## Consequences and trade-offs

- One extra 40-line header to maintain.
- Fewer features than `std::expected` (no monadic operations, no `void` value type).
- Revisit when every supported toolchain provides `std::expected`; then replace `Result` and delete the header.
