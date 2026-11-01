# Environment setup

**Purpose:** install the tools needed to build and test the project.

## Required tools

CMake, Ninja, Git and a C++23 compiler. Minimum (soft) and verified versions are in the README
[dependency table](../../README.md#dependencies); that table is the single source of truth. A
compiler below its minimum produces a CMake warning at configure time and the build continues.

Not required: Docker, Podman, Node.js, Python, Jenkins.

## Install commands

Only the macOS and FreeBSD commands are exactly what the CI jobs run. All others are **untested**
examples.

| Platform | Command | Status |
|----------|---------|--------|
| macOS | `brew install ninja` (CMake and Apple Clang came with the CI runner image) | used in CI |
| FreeBSD | `pkg install -y cmake ninja git` (base Clang is used) | used in CI |
| Debian/Ubuntu | `sudo apt install build-essential cmake ninja-build git` (add `clang` for Clang) | untested |
| Windows | Install Visual Studio with the C++ workload, plus CMake, Ninja and Git. Open an "x64 Native Tools Command Prompt". | untested locally; CI uses `ilammy/msvc-dev-cmd` |

## Verify the installation

```sh
cmake --version
ninja --version
git --version
c++ --version
```

On Windows: `cl` (prints the MSVC version to stderr).

Each command should print a version. Compare against the README dependency table.

## Choosing a compiler

The presets use CMake's default compiler. To select one on Linux, set it before the first configure:

```sh
CXX=clang++ cmake --preset beta
```

Use a fresh `build/<os>/<preset>` directory when switching compilers; CMake caches the first choice.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `cl` not found on Windows | You are not in a Developer Command Prompt. |
| Wrong compiler used after changing `CXX` | Delete `build/<os>/<preset>` and configure again. |

## Related

[Getting started](../getting-started.md), [Build and run](build-and-run.md)
