# ADR 0013: One multi-stage image definition for Docker and Podman

- **Status:** Accepted; partly amended by [ADR 0014](0014-third-party-libraries-as-submodules.md)
- **Date:** 2026-11-03

## Context

The specification asks for development, testing, coverage and runtime containers, defined by one
`Dockerfile` that works with Docker and Podman, plus an optional Compose file and a
`.dockerignore`. [ASR 0002](../requirements/0002-minimal-core-toolchain.md) requires that the
default build does not need containers, and [ASR 0008](../requirements/0008-separate-runtime-image.md)
requires a separate runtime image.

Verified on Linux with Docker 29.9.2, Docker Compose 5.6.1 and Podman 4.9.3 (as root). Docker Hub
and `public.ecr.aws` were not reachable from the verification environment, so the stages were built
from a locally bootstrapped Ubuntu 24.04 image. The official image was never pulled.

## Decision

We use one `Dockerfile` with these stages:

- `toolchain`: Ubuntu 24.04 with GCC, CMake, Ninja and spdlog, shared by the build stages.
- `dev`: adds debugging, quality and documentation tools; runs as `dev`; the source is mounted.
- `build`: builds the `gamma` (Release) preset without tests and installs it to `/opt/app`.
- `test-deps`, `test`: add Catch2; building `test` runs `ctest` on the `beta` preset.
- `coverage`, `coverage-report`: add gcovr and build the `coverage-report` target; the second stage
  contains only the reports, so `--output type=local` can export them.
- `runtime` (the last stage, so the default target): Ubuntu 24.04, `libspdlog1.12`, the installed
  files, user `app` (UID 10001).

Decisions that follow from this:

- **Distribution packages instead of downloads.** The images install spdlog and Catch2 from Ubuntu,
  so building does not fetch anything from GitHub and the `FetchContent` fallback is not used.
  Ubuntu 24.04 ships spdlog 1.12 and Catch2 3.4, which satisfy the minimums in the README.
- **An install rule.** `CMakeLists.txt` gets `install()` rules for the executable and the sample
  configuration, so the runtime stage copies an install tree and not build-tree files.
- **No `# syntax=` line.** It would make Docker download a frontend image, and Podman ignores it.
- **Base image by tag.** `ubuntu:24.04` is passed as the build argument `BASE_IMAGE`. No digest is
  recorded, because none could be looked up. The policy to pin one is in
  [Runtime container](../../containers/runtime.md#updating-images).
- **Compose is optional** and only names common workflows. The `Dockerfile` is the source of truth.
- **Test and coverage use GCC only.** Clang coverage and the sanitizers run in the development
  container or on the host.

## Alternatives considered

- **Separate Dockerfiles per purpose:** would duplicate the toolchain installation. Not chosen.
- **Fetching spdlog and Catch2 with `FetchContent` in the image:** works, but needs GitHub access
  during the build and makes the image depend on network state. Not chosen.
- **Building the runtime binary statically:** removes the library install, but the project links the
  system spdlog dynamically. Not evaluated.
- **A Podman-specific `Containerfile`:** not needed; the same file built with Podman 4.9.3.

## Consequences and trade-offs

- The containers use GCC 13.3, spdlog 1.12.0 and Catch2 3.4.0 from Ubuntu, which are older than the
  versions CI fetches (spdlog 1.17.0, Catch2 3.7.1). A change can therefore pass in one place and
  fail in the other.
- Package versions float within Ubuntu 24.04, so two builds can differ.
- The `runtime` stage lists the runtime libraries by hand.
- The `dev` image is large (2.28 GB in the verified build).

## Related decisions

[ADR 0002](0002-catch2-test-framework.md), [ADR 0010](0010-logging-with-spdlog.md),
[ASR 0002](../requirements/0002-minimal-core-toolchain.md),
[ASR 0008](../requirements/0008-separate-runtime-image.md)
