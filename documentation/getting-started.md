# Getting started

**Purpose:** take a developer from a fresh clone to a built, tested and running example application.

## Prerequisites

See the dependency table in the [README](../README.md#dependencies). Install the tools first:
[Environment setup](development/environment-setup.md). The repository uses Git submodules for
spdlog and Catch2, so clone it with `git clone --recurse-submodules <url>`.

## Procedure

From the repository root:

```sh
cmake --preset beta
cmake --build --preset beta
ctest --preset beta
./build/Linux/beta/app configuration/default.conf
```

The path is for Linux; on other systems replace `Linux` with your host system name (see [Build and run](development/build-and-run.md#build-directories)).

On Windows, run the same steps from an "x64 Native Tools Command Prompt" with the `msvc` presets:

```bat
cmake --preset msvc
cmake --build --preset msvc-debug
ctest --preset msvc-debug
```

## Expected results

- Configure ends with `Build files have been written to: .../build/Linux/beta`.
- Build finishes with no warnings (the `beta` preset treats warnings as errors).
- `ctest` ends with `100% tests passed, 0 tests failed out of 28` (the count grows as tests are added).
- The application prints:

```text
app 0.1.0
loaded 2 entries
log.level=info
name=cpp23-template
```

The sample file sets `log.level=info`, so `configuration loaded: 2 entries` also appears on standard error ([Logging](development/logging.md)). Running `./build/Linux/beta/app` with no argument prints only `app 0.1.0`. `./build/Linux/beta/app --version`
prints the full version, such as `0.1.0-alpha+20261101.beta.Linux.x86-64.GNU-13-3-0`. A missing file
prints `error: file not found` and exits with status 1.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| `spdlog was not found` or `Catch2 was not found` at configure | The submodules are not checked out. Run `git submodule update --init --recursive`, or install spdlog 1.12+ and Catch2 3.3+ system-wide. |
| `CMake Error: ... Ninja` or generator not found | Install Ninja. See [Environment setup](development/environment-setup.md). |
| `Unknown preset "msvc"` or preset not listed on Linux/macOS | The `msvc` preset is only available when the host is Windows. |
| `no template named 'expected' in namespace 'std'` after you add code | Clang 18 with libstdc++ 13 has no `std::expected`. Use `app::Result`. See [ADR 0001](architecture/decisions/0001-result-type-instead-of-std-expected.md). |

## Next steps

1. Read the [architecture overview](architecture/overview.md) and [repository structure](architecture/repository-structure.md).
2. Replace the example: see [Replacing the example application](architecture/overview.md#replacing-the-example-application).
3. Follow the [coding standards](development/coding-standards.md) and see [Logging](development/logging.md).
4. Optional checks: [coverage](testing/coverage.md), [sanitizers](testing/sanitizers.md) and [formatting and static analysis](tooling/static-analysis.md).

## Related

[Build and run](development/build-and-run.md), [README](../README.md)
