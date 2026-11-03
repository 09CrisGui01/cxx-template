# Development container

**Purpose:** explain how to get a ready development environment in a container, with Docker or
Podman. The design is recorded in [ADR 0013](../architecture/decisions/0013-multi-stage-container-image.md).
A container is optional: [Getting started](../getting-started.md) works without one.

## What the image contains

The `dev` stage of the `Dockerfile` is Ubuntu 24.04 with GCC, CMake, Ninja, spdlog, Catch2, GDB,
Valgrind, Clang, clang-format, clang-tidy, Doxygen, gcovr and Git. It runs as the user `dev`
(UID and GID 1000 by default). The source code is **not** copied into the image; the repository is
mounted at `/workspace`. If the submodules in `external/` are checked out, the container build uses
them, and not the installed spdlog and Catch2. Node.js, Husky and Commitlint are not installed, so the Git hooks
([Git hooks](../tooling/git-hooks.md)) are used on the host, not in the container.

## Prerequisites

Docker (with BuildKit) or Podman. The versions that were used are in the README
[dependency table](../../README.md#dependencies).

## Procedure

Build the image and start a shell in the repository directory:

```sh
docker build --target dev -t cpp23-template:dev .
docker run --rm -it -v "$PWD":/workspace cpp23-template:dev
```

With Podman, map your user ID so that files created in the mounted directory belong to you, and
label the mount if SELinux is active:

```sh
podman build --target dev -t cpp23-template:dev .
podman run --rm -it --userns=keep-id -v "$PWD":/workspace:Z cpp23-template:dev
```

Inside the container, use the normal commands:

```sh
cmake --preset alpha
cmake --build --preset alpha
ctest --preset alpha
```

With Docker Compose the first command is `docker compose run --rm dev`.

## File ownership

The build directory is created in the mounted repository as the container user. The user is
UID 1000 by default, which matches the first user on most Linux systems. If your UID differs, build
the image with `--build-arg DEV_UID=$(id -u) --build-arg DEV_GID=$(id -g)`. The build directory
`build/Linux/<preset>/` is shared with the host, so a host build and a container build of the same
preset overwrite each other's CMake cache. Delete the directory when you switch.

## Verified results

Checked with Docker 29.9.2 and Podman 4.9.3: the image builds, and inside it the `alpha` preset
builds, 28 of 28 tests pass, `format-check` and the `doxygen` target succeed, and GDB 15.1 and
Valgrind 3.22.0 run. See [Verification status](runtime.md#verification-status) for what was not checked.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| `Permission denied` when creating `build/` | The container user's UID differs from the owner of the mounted directory. Rebuild with `--build-arg DEV_UID=...`, or with Podman use `--userns=keep-id`. |
| `Permission denied` on files in the mount with SELinux | Add `:Z` to the volume. |
| CMake complains that the cache is from another directory | The `build/` directory was created on the host. Delete `build/Linux/<preset>` and configure again. |

## Related

[Testing containers](testing.md), [Runtime container](runtime.md), [Build and run](../development/build-and-run.md)
