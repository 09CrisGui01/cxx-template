# ADR 0010: Logging with spdlog

- **Status:** Accepted; amended by [ADR 0014](0014-third-party-libraries-as-submodules.md)
- **Date:** 2026-11-02

## Context

The template had no logging: the example application printed results to standard output and errors
to standard error, with no severity levels and no way to get diagnostic detail. A template for real
applications needs levels, a configurable threshold and thread-safe output. The repository owner
asked for a well-known, well-established library instead of a home-made one.

The following was verified on Linux. Building and running 28 tests passed with the system
packages spdlog 1.12.0 and fmt 9.1.0 (GCC 13.3 and Clang 18.1), and with the fetched tag v1.17.0
(GCC 13.3, together with a fetched Catch2 3.7.1). Not verified: macOS, Windows (MSVC) and FreeBSD.
The CI results for those platforms decide this.

## Decision

We use spdlog. `CMakeLists.txt` prefers a system install (`find_package(spdlog 1.12)`) and otherwise
fetches tag v1.17.0 with `FetchContent`, the same pattern as Catch2 ([ADR 0002](0002-catch2-test-framework.md)).
`app_core` links `spdlog::spdlog` publicly, so library code can call `spdlog::debug(...)` and
similar functions directly.

The project adds only what it must decide itself, in `internal/log.hpp` and `internal/log.cpp`
(namespace `app::log`):

- the level names `trace`, `debug`, `info`, `warn`, `error`, `critical` and `off`, in lowercase only;
- the output destination: standard error, never standard output, because standard output is
  reserved for program results;
- the source of the level: the environment variable `APP_LOG_LEVEL`, then the configuration key
  `log.level`, then the default `warn`. The environment variable wins over the configuration file.

An invalid `APP_LOG_LEVEL` produces a warning and the default level. An invalid `log.level` is a
configuration error: the application exits with status 1.

## Alternatives considered

- **Boost.Log:** well established and very configurable, but it needs Boost, a much larger dependency than this template otherwise has.
- **glog:** established, but its configuration is mostly global flags and it has no per-instance logger objects.
- **Standard streams only:** no new dependency, but no levels, no threshold and no thread safety.
- **quill, plog and other smaller libraries:** not evaluated in this repository. They may be faster or lighter, but are less widely used than spdlog.
- **A project-owned logger:** rejected by the repository owner's request for an established library.

## Consequences and trade-offs

- The core build now has a third-party dependency. The first configure needs network access to github.com unless spdlog 1.12 or newer is installed ([ASR 0001](../requirements/0001-clean-checkout-reproducibility.md)). Before this decision only the tests needed it.
- The fetched tag is pinned by name, not by commit hash, as for Catch2.
- A system spdlog can be a shared library. A build that uses it needs that library at run time. A fetched spdlog is linked statically.
- spdlog bundles fmt when it is fetched; a system install uses the system fmt. The two builds can therefore use different fmt versions.
- The sink is a colored standard-error sink. Colors appear only when standard error is a terminal.
- Messages are not part of a stable interface. Tests check a few of them with regular expressions; renaming a message needs a test update.
- Log messages MUST NOT contain secrets. Values that come from untrusted input are logged only after the parser has bounded them ([ASR 0003](../requirements/0003-bounded-untrusted-input.md)).

## Related decisions

[ADR 0002](0002-catch2-test-framework.md), [ASR 0001](../requirements/0001-clean-checkout-reproducibility.md), [ASR 0002](../requirements/0002-minimal-core-toolchain.md)
