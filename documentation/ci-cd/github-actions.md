# GitHub Actions

**Purpose:** describe the CI workflow `.github/workflows/ci.yml`: when it runs, what each job does,
and what is known to work. Jenkins is added in Milestone 8; until then this is the only CI.
**Prerequisites:** a GitHub repository with Actions enabled. The workflow is a single file and has no
secrets.

## Triggers and settings

| Setting | Value |
|---------|-------|
| Runs on | pushes to `development` and `release`, and every pull request |
| Permissions | `contents: read` for the whole workflow |
| Timeouts | 30 minutes per job; 45 minutes for FreeBSD |
| Secrets | none are used |

A push to any other branch starts nothing until a pull request is opened; see
[Conventions](../development/conventions.md#branches). The workflow cannot be started by hand: it
has no `workflow_dispatch` trigger.

## Jobs

Every job uses presets from `CMakePresets.json`, the same commands as
[Build and run](../development/build-and-run.md).

| Job | Runner | Preset | What it does | Status |
|-----|--------|--------|--------------|--------|
| `linux-gcc` (in `build-test`) | `ubuntu-latest` | `beta` | configure, build, test with GCC | reported working |
| `linux-clang` (in `build-test`) | `ubuntu-latest` | `beta` | the same with `CC=clang`, `CXX=clang++` | reported working |
| `macos-clang` (in `build-test`) | `macos-latest` | `alpha` | installs Ninja with Homebrew, then configure, build, test | reported working |
| `windows-msvc` (in `build-test`) | `windows-latest` | `msvc`, `msvc-debug` | sets up the MSVC environment with `ilammy/msvc-dev-cmd`, then configure, build, test ([ADR 0003](../architecture/decisions/0003-msvc-with-ninja-multi-config.md)) | reported working |
| `freebsd-clang` (`freebsd`) | `ubuntu-latest` running a FreeBSD VM | `alpha` | installs CMake, Ninja and Git with `pkg`, then configure, build, test | reported working |
| `linux-gcc-coverage` (`coverage`) | `ubuntu-latest` | `coverage` | installs gcovr with `pipx`, builds the `coverage-report` target, uploads `build/Linux/coverage/coverage` as the artifact `coverage-report` | **not run on GitHub** |
| `linux-quality` (`quality`) | `ubuntu-latest` | `alpha`, `tidy`, `sanitize` | installs clang-format and clang-tidy with `apt`, then `format-check`, the `tidy` build, and the `sanitize` build and tests (GCC) | **not run on GitHub** |

"Reported working" means the repository owner reported the job passing; the author did not observe
it. Only Debug builds run on macOS, Windows and FreeBSD; Release is not run on them.

## Actions used

| Action | Reference | Used by |
|--------|-----------|---------|
| `actions/checkout` | `v4` | every job |
| `actions/upload-artifact` | `v4` | `coverage` |
| `ilammy/msvc-dev-cmd` | `v1` | `windows-msvc` |
| `vmactions/freebsd-vm` | `v1` | `freebsd` |

These are major-version tags, which the action authors can move. They are not pinned to commit
hashes. Pinning to hashes is a possible hardening step; changing any reference is a `ci` change
([Conventions](../development/conventions.md#continuous-integration)).

## Reproduce a job locally

Run the job's preset on your machine: for `linux-gcc`, `cmake --preset beta`,
`cmake --build --preset beta`, `ctest --preset beta`. Jobs on other operating systems need that
operating system. The `coverage` and `quality` jobs are described in
[Coverage](../testing/coverage.md) and [Formatting, static analysis and warnings](../tooling/static-analysis.md).

## Troubleshooting

| Symptom | Cause and fix |
|---------|--------------|
| Nothing appears after a push | The branch is neither `development` nor `release`, and no pull request exists. Actions may also be disabled in the repository settings. |
| The badge in the README is broken | The `{{username}}` and `{{project-name}}` placeholders are not replaced. |
| `Unknown preset` in a job | The preset name in the workflow does not exist in `CMakePresets.json`; presets were renamed to `alpha`, `beta` and `gamma`. |
| `quality` job fails at `format-check` | The runner's clang-format version formats differently from the version the style was written with. See [Static analysis](../tooling/static-analysis.md#troubleshooting). |

## Related

[Conventions](../development/conventions.md#continuous-integration),
[Build and run](../development/build-and-run.md),
[Repository structure](../architecture/repository-structure.md)
