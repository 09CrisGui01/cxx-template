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
| [Architecture overview](architecture/overview.md) | Components, CMake targets, data flow, test architecture |
| [Repository structure](architecture/repository-structure.md) | Every directory and tracked file, and why it exists |
| [ADR template](adr-template.md) | Template for architecture decision records |
| [ADR 0001](architecture/decisions/0001-result-type-instead-of-std-expected.md) | `Result` type instead of `std::expected` |
| [ADR 0002](architecture/decisions/0002-catch2-test-framework.md) | Catch2 as the test framework |
| [ADR 0003](architecture/decisions/0003-msvc-with-ninja-multi-config.md) | MSVC built with Ninja Multi-Config and `cl` |

## Not yet written

These topics have no page because the feature they describe does not exist yet. Each arrives with
its milestone and is added to the table above at that time.

| Topic | Milestone |
|-------|-----------|
| Coverage, sanitizers, testing strategy | 3, 4 |
| Formatting and static analysis | 4 |
| Git workflow, commit conventions, hooks | 5 |
| Containers (development, testing, runtime) | 6 |
| AI-assisted development (`AGENTS.md`) | 7 |
| Jenkins | 8 |
| Dependency scanning, security, troubleshooting index | 9 |

## Documentation conventions

- One canonical explanation per workflow; other pages link to it.
- Commands in these pages were run by the author unless marked **untested**.
- Required tools are distinguished from optional ones.
