# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Versions use the project's `X.Y.Z-TAG+METADATA` form (a final release is `X.Y.Z+METADATA`); see
[Conventions](documentation/development/conventions.md#versions).

## [Unreleased]

### Added

- C++23 example application: a bounded `key=value` configuration parser and loader, with a `Result` error type.
- CMake build with presets `alpha` (development), `beta` (testing and debugging), `gamma` (pre-release) and `msvc`, build trees in `build/<os>/<preset>/`, per-target warnings and MSVC portability flags.
- Catch2 unit tests, CTest integration tests and portability tests (UTF-8 BOM, CRLF, non-ASCII paths, symlinks).
- Soft minimum compiler versions with a configure-time warning.
- GitHub Actions workflow building and testing on Linux, macOS, Windows (MSVC) and FreeBSD, plus a `coverage` job and a `quality` job (format check, clang-tidy build, sanitizer tests). The last two have not been run on GitHub yet.
- Version stage tag (`alpha`, `beta`, `gamma`; none for a final release) and build metadata (`<timestamp>.<build-preset>.<os>.<architecture>.<toolchain>`), available as CMake variables, compile definitions and `app --version`.
- Optional code coverage: `coverage` preset and target, GCC (gcov and gcovr) and Clang (llvm-cov), terminal, HTML and Cobertura or LCOV reports, configurable minimum line coverage.
- Optional clang-format (`format`, `format-check` targets), clang-tidy (`tidy` preset) and sanitizers (`sanitize` and `tsan` presets), with checks that fail the run on a finding.
- Logging with spdlog: levels, output on standard error, level from `APP_LOG_LEVEL` or the `log.level` configuration key (ADR 0010).
- Optional Git hooks and commit linting: Husky, Commitlint (`.commitlintrc.json`), a `git clang-format` check, gitleaks and shellcheck, and a CI job `hygiene` that runs the same checks (ADR 0011).
- Optional `doxygen` target for API documentation (ADR 0012), debugging notes for GDB and Valgrind, and a tool evaluation page.
- Optional containers: a multi-stage `Dockerfile` (`dev`, `build`, `test`, `coverage`, `runtime`) for Docker and Podman, `compose.yaml`, `.dockerignore`, `install()` rules, a non-root read-only runtime image, a CI job `container`, and container documentation (ADR 0013, ASR 0008).
- spdlog and Catch2 as Git submodules in `external/`, pinned by commit (ADR 0014); the `FetchContent` fallback is removed.
- Integration test that a parse error names its line.
- Community files `RELEASES.md`, `AUTHORS.md`, `CONTRIBUTORS.md` and `CODE-OF-CONDUCT.md`, a pull request template and bug and feature issue templates.
- Documentation: index, getting started, environment setup, build and run, coding standards, conventions, architecture overview, repository structure, ADRs and ASRs.
