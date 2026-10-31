# Documentation index

**Purpose:** central navigation for all project documentation.
**Audience:** a developer who has never seen this repository.

Start with [Getting started](getting-started.md). The top-level [README](../README.md) holds the
canonical dependency table and platform support table; other pages link to it instead of copying it.

## Available pages

| Page | What it covers |
|------|----------------|
| [Getting started](getting-started.md) | Clone, configure, build, test and run for the first time |
| [Environment setup](development/environment-setup.md) | Installing the required tools |
| [Build and run](development/build-and-run.md) | Presets, CMake options, running the app, selecting tests |
| [Coding standards](development/coding-standards.md) | C++23 rules, naming, error handling, testing expectations |
| [Conventions](development/conventions.md) | Git commits and branches, tool usage, documentation writing (no code rules) |
| [Architecture overview](architecture/overview.md) | Components, CMake targets, data flow, test architecture |
| [Changelog](../CHANGELOG.md) | Notable changes per version (Keep a Changelog) |
| [Repository structure](architecture/repository-structure.md) | Every directory and tracked file, and why it exists |
| [ADR template](adr-template.md) | Template for architecture decision records |
| [ASR template](asr-template.md) | Template for architecturally significant requirements |
| [ADR 0001](architecture/decisions/0001-result-type-instead-of-std-expected.md) | `Result` type instead of `std::expected` |
| [ADR 0002](architecture/decisions/0002-catch2-test-framework.md) | Catch2 as the test framework |
| [ADR 0003](architecture/decisions/0003-msvc-with-ninja-multi-config.md) | MSVC built with Ninja Multi-Config and `cl` |
| [ADR 0004](architecture/decisions/0004-semver-versioning-with-greek-stage-tags.md) | Semantic Versioning with Greek stage tags |
| [ADR 0005](architecture/decisions/0005-branching-and-merge-strategy.md) | Branching and merge strategy |
| [ASR 0001](architecture/requirements/0001-clean-checkout-reproducibility.md) | Clean-checkout reproducibility |
| [ASR 0002](architecture/requirements/0002-minimal-core-toolchain.md) | Minimal core toolchain |
| [ASR 0003](architecture/requirements/0003-bounded-untrusted-input.md) | Bounded untrusted input |
| [ASR 0004](architecture/requirements/0004-multi-platform-portability.md) | Multi-platform portability |
| [ASR 0005](architecture/requirements/0005-deterministic-self-contained-tests.md) | Deterministic, self-contained tests |

## Not yet written

These topics have no page because the feature they describe does not exist yet. Each arrives with
its milestone and is added to the table above at that time.

| Topic | Milestone |
|-------|-----------|
| Coverage, sanitizers, testing strategy | 3, 4 |
| Formatting and static analysis | 4 |
| Git hooks, Commitlint setup, release workflow | 5 |
| Containers (development, testing, runtime) | 6 |
| AI-assisted development (`AGENTS.md`) | 7 |
| Jenkins | 8 |
| Dependency scanning, security, troubleshooting index | 9 |

## Requirements and decisions

ASRs (`architecture/requirements/`) record what the architecture must achieve and how that is
verified. ADRs (`architecture/decisions/`) record the design choices that satisfy them. Both use
numbered files and a template.

## Documentation conventions

- One canonical explanation per workflow; other pages link to it.
- Commands in these pages were run by the author unless marked **untested**.
- Required tools are distinguished from optional ones.
