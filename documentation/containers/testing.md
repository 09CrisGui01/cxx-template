# Test and coverage containers

**Purpose:** run the test suite and produce coverage reports in a clean container, with Docker or
Podman. Containers are optional; the same checks run on the host with the presets.

## How it works

The test stage uses the packages of Ubuntu 24.04: GCC 13, CMake, Ninja, spdlog 1.12 and Catch2 3.4.
Nothing is downloaded from GitHub during the build, and `external/` is not copied into the image,
because the system packages satisfy the version checks in `CMakeLists.txt` and
`test/CMakeLists.txt` ([ADR 0014](../architecture/decisions/0014-third-party-libraries-as-submodules.md)). Building the `test` stage configures
the `beta` preset (warnings are errors), builds, and runs `ctest`. If a test fails, the image build
fails.

## Run the tests

```sh
docker build --target test -t cpp23-template:test .
```

or `docker compose build test`, or with Podman:

```sh
podman build --target test -t cpp23-template:test .
```

A successful build ends with the CTest line `100% tests passed, 0 tests failed out of 28`. To run
the tests again from the finished image, run `docker run --rm cpp23-template:test`.

## Coverage

The `coverage` stage adds gcovr (the Ubuntu package, version 7.0), builds the `coverage` preset and
runs the `coverage-report` target ([Coverage](../testing/coverage.md)). The `coverage-report` stage
holds only the report files, so they can be written to a directory on the host:

```sh
docker build --target coverage-report --output type=local,dest=./coverage-out .
podman build --target coverage-report --output type=local,dest=./coverage-out .
```

The result is `coverage-out/html/index.html` and `coverage-out/cobertura.xml`. `coverage-out/` is
not ignored by Git; delete it or add it to your own ignore file. The ignore rules in `.gitignore`
cover `/coverage/`, so using `./coverage` as the destination keeps the repository clean.

## Verified results

Checked with Docker 29.9.2 and Podman 4.9.3: the `test` stage passes 28 of 28 tests, and the
`coverage-report` stage writes `html/` and `cobertura.xml` with both engines. In the container, the
line coverage of `internal/` is 93.3% (167 of 179 lines) with gcovr 7.0. This differs from the
figures in [Coverage](../testing/coverage.md#what-is-measured) because the toolchain and the gcovr version
differ, and the code has changed since. Sanitizers and clang-tidy are not run in these containers;
use the `dev` container for them.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| The build fails at the test step | A test failed. The CTest output above the error names it. Fix the test or the code and build again. |
| `--output` is not recognized | The engine is too old. Podman 4.9.3 and Docker with BuildKit support it. Run the stage and copy the files out with `podman cp` or `docker cp` instead. |
| Packages cannot be downloaded | The build needs network access to the Ubuntu package archive. |

## Related

[Development container](development.md), [Runtime container](runtime.md),
[Testing strategy](../testing/strategy.md), [Coverage](../testing/coverage.md)
