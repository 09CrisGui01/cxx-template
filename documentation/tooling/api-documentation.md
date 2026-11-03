# API documentation with Doxygen

**Purpose:** explain how to generate HTML API documentation from the header comments. The decision
is recorded in [ADR 0012](../architecture/decisions/0012-doxygen-for-api-documentation.md).

## Prerequisites

Doxygen. The version that was used is in the README [dependency table](../../README.md#dependencies).
Doxygen is optional. When it is not found, CMake prints `Doxygen not found: target 'doxygen' is not
created` and the build is unaffected.

## Procedure

```sh
cmake --preset alpha
cmake --build --preset alpha --target doxygen
```

The result is `build/Linux/alpha/doxygen/html/index.html`. On other systems, replace `Linux` with
your host system name ([Build and run](../development/build-and-run.md#build-directories)).

## What is documented

- The target reads the headers in `internal/` (`*.hpp`) and nothing else. Test code and `.cpp` files
  are not read.
- Every entity is listed, with or without a comment (`EXTRACT_ALL`), so the output is useful for a
  project that has little documentation yet.
- A Doxygen warning, such as a `\param` name that does not exist, fails the target. A missing comment
  does not.

## Writing comments

Doxygen reads comments that start with `///`. The headers in `internal/` use that form. A plain
`//` comment is not read.

```cpp
/// Reads a regular file and parses it.
/// \param path file to read
[[nodiscard]] Result<Config, Error> load_config_file(const std::filesystem::path& path);
```

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| `No rule to make target 'doxygen'` or target not found | Doxygen is not installed, or CMake was configured before it was installed. Install it and configure again. |
| The build fails with `warning treated as error` | Read the file and line in the message and fix the comment. |
| An entity has no description | Its comment starts with `//` instead of `///`. |

## Related

[Build and run](../development/build-and-run.md#targets), [Tool evaluation](tool-evaluation.md)
