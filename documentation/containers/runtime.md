# Runtime container

**Purpose:** build and run the application image, and document its security properties. The design
is recorded in [ADR 0013](../architecture/decisions/0013-multi-stage-container-image.md) and the
requirement in [ASR 0008](../architecture/requirements/0008-separate-runtime-image.md).

## What the image contains

The `runtime` stage is the last stage of the `Dockerfile`, so a plain `docker build .` builds it.
It contains Ubuntu 24.04 (the base image), the package `libspdlog1.12` with its dependency
`libfmt9`, the executable `/usr/local/bin/app` and the sample configuration
`/usr/local/share/cpp23_template/default.conf`. It does not contain a compiler, CMake, Catch2,
coverage tools, Git or the source code. The executable is built in the `build` stage with the
`gamma` preset (Release), without tests, and installed with `cmake --install --strip`.

## Build and run

```sh
docker build -t cpp23-template:runtime .
docker run --rm cpp23-template:runtime
docker run --rm cpp23-template:runtime --version
```

`ENTRYPOINT` is `app` and the default argument is the sample configuration, so arguments after the
image name replace the sample file. To read your own file, mount it read-only:

```sh
docker run --rm -v "$PWD/my.conf":/etc/app.conf:ro cpp23-template:runtime /etc/app.conf
```

Set the log level with `-e APP_LOG_LEVEL=debug` ([Logging](../development/logging.md)). With Podman,
replace `docker` with `podman`; the commands are the same.

## Security properties

| Property | How |
|----------|-----|
| Non-root user | The image runs as `app`, UID and GID 10001, with no home directory and the shell `/usr/sbin/nologin`. |
| Read-only root filesystem | The application writes no files. It runs with `--read-only`. |
| No capabilities | It runs with `--cap-drop ALL`. |
| No privilege gain | It runs with `--security-opt no-new-privileges`. |
| No secrets | No build argument or layer holds a secret. `.dockerignore` excludes `.env`, `*.pem` and `*.key`. |
| Small attack surface | Only `libspdlog1.12` and its dependency are installed beyond the base image, without recommended packages. |
| No source or tools | The compiler, CMake, test framework and sources stay in earlier stages. |

The recommended command runs with all of these restrictions:

```sh
docker run --rm --read-only --cap-drop ALL --security-opt no-new-privileges cpp23-template:runtime
```

**Writable directories:** none. The application does not write to disk; its log goes to standard
error. If you add code that writes files, mount a volume and document the directory here.

A container is not a replacement for secure code, dependency updates or monitoring. The image has
not been scanned for vulnerabilities (planned for a later milestone).

## Updating images

- The base image is `ubuntu:24.04`, a tag for the Ubuntu 24.04 LTS release. The tag moves when
  Ubuntu publishes a new image of the same release. No digest is recorded in the repository,
  because the registry was not reachable when the image was written, and a digest that was not
  looked up would be invented. To pin one, read it with `docker buildx imagetools inspect ubuntu:24.04`
  (or `podman image inspect`) and build with `--build-arg BASE_IMAGE=ubuntu:24.04@sha256:<digest>`.
- The packages come from the Ubuntu archive at build time, so two builds on different days can
  contain different package versions. Pinned package versions are not used because Ubuntu removes
  old versions from its archive.
- Policy: rebuild the images whenever Ubuntu publishes a security update that affects an installed
  package, and at least once a month. Rebuild with `--pull` (Docker) or `--pull=always` (Podman) to
  fetch the newest base image.

## Docker and Podman differences

| Topic | Docker | Podman |
|-------|--------|--------|
| The same `Dockerfile` | yes | yes |
| `--output type=local` for the coverage report | works (BuildKit) | works in 4.9.3 |
| Compose | `docker compose` (Compose 5.6.1 was used) | needs `podman compose` with a provider such as podman-compose; not verified |
| Bind mounts and file ownership | the container user needs a matching UID | `--userns=keep-id` maps your user |
| SELinux | `:z` or `:Z` on volumes when SELinux is active | the same |
| Image names | `cpp23-template:runtime` is stored as `docker.io/library/cpp23-template:runtime` | stored as `localhost/cpp23-template:runtime` |

The `Dockerfile` has no `# syntax=` line. That line makes Docker download a build frontend image
from Docker Hub, and Podman ignores it.

## Cleanup

```sh
docker image rm cpp23-template:runtime cpp23-template:test cpp23-template:dev
docker builder prune
docker compose down --rmi local
```

With Podman: `podman image rm ...` and `podman system prune`.

## Verification status

All results are from one Linux machine on 2026-11-03.

- **Base image:** Docker Hub and `public.ecr.aws` were not reachable from the verification
  environment (the network policy refused the connection), so the official `ubuntu:24.04` image was
  **never pulled**. The stages were built from a local Ubuntu 24.04 image created with
  `debootstrap --variant=minbase noble` (with `main` and `universe`, updates and security),
  passed as `--build-arg BASE_IMAGE=localhost/ubuntu-bootstrap:24.04`. The official image differs:
  it is smaller, and it contains a user named `ubuntu` that the `dev` stage removes with
  `userdel`. That branch was not exercised.
- **Docker 29.9.2:** the `dev`, `test`, `coverage-report` and `runtime` targets built. The runtime
  container ran as UID 10001 with a read-only filesystem and no capabilities, printed the sample
  output and the version, exited with 1 for a missing file, and contained none of `g++`, `gcc`,
  `cmake`, `ninja`, `gdb`, `valgrind`, `git`. Image sizes: runtime 298 MB, test 1.32 GB, dev
  2.28 GB (these include the 147 MB local base image).
- **Docker Compose 5.6.1:** `docker compose config`, `docker compose build app test` and
  `docker compose run --rm app` worked.
- **Podman 4.9.3 (run as root):** the `runtime`, `test`, `coverage-report` and `dev` targets built,
  and the runtime image ran read-only with no capabilities as UID 10001.
- **Not verified:** rootless Podman, `podman compose`, the container job in GitHub Actions, the
  official base image, and any platform other than Linux x86-64.

## Related

[Development container](development.md), [Testing containers](testing.md),
[GitHub Actions](../ci-cd/github-actions.md)
