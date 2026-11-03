#
# Multi-stage image definition for Docker and Podman.
#
#   dev              interactive development shell (no source copied in)
#   build            compiles the Release executable and installs it to /opt/app
#   test             builds with warnings as errors and runs the test suite
#   coverage         builds with instrumentation and writes the coverage reports
#   coverage-report  scratch image holding only the reports, for `--output`
#   runtime          the default target: executable, runtime libraries, sample config
#
# Documentation: documentation/containers/. Decision: ADR 0013.

# Base image. The tag is pinned to the Ubuntu release; no digest is recorded
# (see documentation/containers/runtime.md#updating-images).
ARG BASE_IMAGE=ubuntu:24.04

# ---------------------------------------------------------------------------
# Toolchain: compiler and build tools shared by every build-time stage.
# ---------------------------------------------------------------------------
FROM ${BASE_IMAGE} AS toolchain
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
      build-essential cmake ninja-build libspdlog-dev \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src

# ---------------------------------------------------------------------------
# Development: debugging and quality tools. The source is mounted, not copied.
# ---------------------------------------------------------------------------
FROM toolchain AS dev
ARG DEV_UID=1000
ARG DEV_GID=1000
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
      catch2 gdb valgrind clang clang-format clang-tidy doxygen gcovr git ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && (userdel --remove ubuntu || true) \
 && (groupdel ubuntu || true) \
 && groupadd --gid "${DEV_GID}" dev \
 && useradd --uid "${DEV_UID}" --gid "${DEV_GID}" --create-home --shell /bin/bash dev
USER dev
WORKDIR /workspace
CMD ["bash"]

# ---------------------------------------------------------------------------
# Build: Release executable without the tests, installed under /opt/app.
# ---------------------------------------------------------------------------
FROM toolchain AS build
COPY CMakeLists.txt CMakePresets.json ./
COPY configuration ./configuration
COPY internal ./internal
COPY tool ./tool
RUN cmake --preset gamma -DBUILD_TESTING=OFF \
 && cmake --build --preset gamma \
 && cmake --install build/Linux/gamma --prefix /opt/app --strip

# ---------------------------------------------------------------------------
# Test dependencies, then the test stage: building the stage runs the tests,
# so `docker build --target test .` fails when a test fails.
# ---------------------------------------------------------------------------
FROM toolchain AS test-deps
RUN apt-get update \
 && apt-get install --yes --no-install-recommends catch2 \
 && rm -rf /var/lib/apt/lists/*

FROM test-deps AS test
COPY CMakeLists.txt CMakePresets.json ./
COPY configuration ./configuration
COPY internal ./internal
COPY test ./test
COPY tool ./tool
RUN cmake --preset beta \
 && cmake --build --preset beta \
 && ctest --preset beta
CMD ["ctest", "--preset", "beta"]

# ---------------------------------------------------------------------------
# Coverage: GCC with gcov and gcovr. Reports are in
# /src/build/Linux/coverage/coverage.
# ---------------------------------------------------------------------------
FROM test-deps AS coverage
RUN apt-get update \
 && apt-get install --yes --no-install-recommends gcovr \
 && rm -rf /var/lib/apt/lists/*
COPY CMakeLists.txt CMakePresets.json ./
COPY configuration ./configuration
COPY internal ./internal
COPY test ./test
COPY tool ./tool
RUN cmake --preset coverage \
 && cmake --build --preset coverage-report

FROM scratch AS coverage-report
COPY --from=coverage /src/build/Linux/coverage/coverage /

# ---------------------------------------------------------------------------
# Runtime: the executable, its shared libraries and the sample configuration.
# No compiler, CMake, test framework, coverage tool or source code.
# ---------------------------------------------------------------------------
FROM ${BASE_IMAGE} AS runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install --yes --no-install-recommends libspdlog1.12 \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --gid 10001 app \
 && useradd --uid 10001 --gid 10001 --no-create-home --home-dir /nonexistent \
      --shell /usr/sbin/nologin app
COPY --from=build /opt/app/ /usr/local/
USER app
ENTRYPOINT ["app"]
CMD ["/usr/local/share/cpp23_template/default.conf"]
