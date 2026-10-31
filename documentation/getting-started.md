# Getting started

**Purpose:** take a developer from a fresh clone to a built, tested and running example application.

## Prerequisites

See the dependency table in the [README](../README.md#dependencies). Install the tools first:
[Environment setup](development/environment-setup.md). Network access to github.com is needed on
the first configure to fetch Catch2.

## Procedure

From the repository root:

```sh
cmake --preset test
cmake --build --preset test
ctest --preset test
./build/test/app configuration/default.conf
```

On Windows, run the same steps from an "x64 Native Tools Command Prompt" with the `msvc` presets:

```bat
cmake --preset msvc
cmake --build --preset msvc-debug
ctest --preset msvc-debug
```

## Expected results

- Configure ends with `Build files have been written to: .../build/test`.
- Build finishes with no warnings (the `test` preset treats warnings as errors).
- `ctest` ends with `100% tests passed, 0 tests failed out of 17` (the count grows as tests are added).
- The application prints:

```text
app 0.1.0
loaded 2 entries
log.level=info
name=cpp23-template
```

Running `./build/test/app` with no argument prints only `app 0.1.0`. A missing file prints
`error: file not found` and exits with status 1.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| Configure fails while cloning Catch2 | No network access to github.com. Install Catch2 3.3+ system-wide, or configure from a networked machine. |
| `CMake Error: ... Ninja` or generator not found | Install Ninja. See [Environment setup](development/environment-setup.md). |
| `Unknown preset "msvc"` or preset not listed on Linux/macOS | The `msvc` preset is only available when the host is Windows. |
| `no template named 'expected' in namespace 'std'` after you add code | Clang 18 with libstdc++ 13 has no `std::expected`. Use `app::Result`. See [ADR 0001](architecture/decisions/0001-result-type-instead-of-std-expected.md). |

## Next steps

1. Read the [architecture overview](architecture/overview.md) and [repository structure](architecture/repository-structure.md).
2. Replace the example: see [Replacing the example application](architecture/overview.md#replacing-the-example-application).
3. Follow the [coding standards](development/coding-standards.md).

## Related

[Build and run](development/build-and-run.md), [README](../README.md)
