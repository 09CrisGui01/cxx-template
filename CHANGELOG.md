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
- Integration test that a parse error names its line.
- Documentation: index, getting started, environment setup, build and run, coding standards, conventions, architecture overview, repository structure, ADRs and ASRs.
