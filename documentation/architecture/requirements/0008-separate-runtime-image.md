# ASR 0008: Separate runtime image

- **Status:** Accepted
- **Date:** 2026-11-03
- **Verification status:** Partially met

## Context

The specification requires development and runtime containers to be separate, so that compilers,
test frameworks, debugging tools and coverage tools stay out of the final image, and requires the
image to run as a non-root user where practical. A larger image has more software that can contain
vulnerabilities.

## Requirement

Quality attribute: security and maintainability. The runtime image MUST contain only the executable,
its shared libraries and the sample configuration. It MUST NOT contain a compiler, CMake, a test
framework, a coverage tool, a debugger or the source code. It MUST run as a user other than root
and MUST work with a read-only root filesystem and no Linux capabilities.

## Verification

- Inspection of the built image on Linux with Docker 29.9.2: `g++`, `gcc`, `cmake`, `ninja`, `gdb`,
  `valgrind` and `git` are not found; `/usr/local` holds only `bin/app` and the sample
  configuration; `id` prints `uid=10001(app)`.
- The runtime image ran with `--read-only --cap-drop ALL --security-opt no-new-privileges` and
  printed the expected output, with both Docker and Podman 4.9.3.
- Not verified: the official `ubuntu:24.04` base image (it was not reachable; a locally built
  Ubuntu 24.04 image was used); a vulnerability scan of the image; rootless Podman.

## Alternatives considered

- **One image for building and running:** simpler, but ships the compiler and tools. Not chosen.
- **A distroless or scratch runtime image:** smaller, but needs a static executable or copied
  libraries, and the current build links spdlog dynamically. Not evaluated further.

## Consequences and trade-offs

- The runtime image needs its libraries installed by name (`libspdlog1.12`). When a library
  dependency is added to the application, the `runtime` stage of the `Dockerfile` MUST be updated.
- Debugging in the runtime image is not possible; use the development container.

## Related decisions

[ADR 0013](../decisions/0013-multi-stage-container-image.md),
[ASR 0002](0002-minimal-core-toolchain.md)
