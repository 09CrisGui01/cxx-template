# ASR 0003: Bounded untrusted input

- **Status:** Accepted
- **Date:** 2026-10-31
- **Verification status:** Partially met

## Context

The specification asks for validation of untrusted input at boundaries, resource and size limits,
and safe handling of malformed external data. The example application reads a configuration file,
which is the only untrusted input it has.

## Requirement

Quality attribute: security and reliability. Input read from a file MUST be size-checked before it
is processed, and every limit MUST be enforced at its exact boundary: total size at most 1 MiB,
line length at most 4096 bytes, at most 1024 entries. Violations and malformed lines MUST be
returned as error values with a code (and a line number where applicable); they MUST NOT crash,
throw or exhibit undefined behavior.

## Verification

- Unit tests in `test/config_test.cpp` check each limit at the boundary (the limit passes, one past fails) and each malformed-line error code with its line number. They passed on Linux (GCC and Clang) locally and, as reported by the repository owner, in CI.
- The unit and integration tests also passed under AddressSanitizer plus UndefinedBehaviorSanitizer (the `sanitize` preset) with GCC 13.3 and Clang 18.1 on Linux, on 2026-11-01. Whether LeakSanitizer was active was not checked.
- Not verified: fuzzing (not planned), behavior on files that change while being read beyond the bounded read in `load_config_file`.

## Alternatives considered

- **No limits, rely on the filesystem:** a large or hostile file would exhaust memory. Rejected.
- **Throw exceptions on bad input:** conflicts with the value-based error convention in the [coding standards](../../development/coding-standards.md#error-handling).

## Consequences and trade-offs

- Legitimate configuration files larger than 1 MiB are rejected; the limits are constants in `internal/config.hpp` and can be changed with their tests.
- Every new input boundary needs its own limits and boundary tests.

## Related decisions

[ADR 0001](../decisions/0001-result-type-instead-of-std-expected.md)
