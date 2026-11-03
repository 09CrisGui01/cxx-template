# Tool evaluation

**Purpose:** record which developer tools were considered for the template, what was decided, and
why. It compares them with the tools the project already uses, and prefers an existing tool unless
the new one does something the existing one cannot. Decided on 2026-11-02.

## Tools already in the project

CMake and CTest, Catch2, clang-format, clang-tidy, the compiler sanitizers, gcov with gcovr, llvm-cov,
spdlog, and GitHub Actions. Each new tool below is judged against these.

## Summary

| Tool | Decision | Where |
|------|----------|-------|
| Commitlint | Integrated (optional, Node.js) | [Git hooks](git-hooks.md), [ADR 0011](../architecture/decisions/0011-optional-node-tooling-for-git-hooks.md) |
| Husky | Integrated (optional, Node.js) | [Git hooks](git-hooks.md), ADR 0011 |
| lint-staged | Not adopted; `git clang-format` does the job | [lint-staged](#lint-staged) |
| gitleaks | Integrated (hook and CI) | [Git hooks](git-hooks.md#secrets) |
| shellcheck | Integrated (hook and CI) | [Git hooks](git-hooks.md#shell-scripts) |
| Doxygen | Integrated (optional CMake target) | [API documentation](api-documentation.md), [ADR 0012](../architecture/decisions/0012-doxygen-for-api-documentation.md) |
| GDB | Documented, no integration needed | [Debugging](../development/debugging.md) |
| Valgrind | Documented through CTest's memory check | [Debugging](../development/debugging.md) |
| Trivy | Deferred to the container milestone | [Trivy](#trivy) |
| Jenkins | Deferred to its own milestone (8) | [Jenkins](#jenkins) |
| Linux Containers (LXC, Incus) | Not adopted; Docker or Podman is planned | [Linux Containers](#linux-containers) |
| Devbox | Not adopted now | [Devbox](#devbox) |
| Jekyll | Not adopted | [Jekyll](#jekyll) |
| OCLint | Not adopted; clang-tidy covers the need | [OCLint](#oclint) |
| Bumblebee | Not adopted; it does not fit this project | [Bumblebee](#bumblebee) |

## Reasons

### Commitlint and Husky

The commit convention in [Conventions](../development/conventions.md#commit-messages) was enforced
by review only. Commitlint is the standard checker for Conventional Commits and its rules fit the
project's type, scope and length rules. Husky installs hooks with one command (`npm install`), so a
contributor does not have to copy hook files by hand. Both need Node.js, which the project treats as
optional ([ASR 0002](../architecture/requirements/0002-minimal-core-toolchain.md)). The cost is that
contributors need Node.js 22.12 or newer to get commit checking locally. CI checks commits too, so
nothing depends on a contributor installing them.

A plain alternative exists: a `.githooks/` directory and `git config core.hooksPath .githooks`
needs no Node.js, but then the commit message check would have to be written by hand as a shell
script, and it would duplicate what Commitlint already does well. Husky was adopted because the
repository owner listed it and the hook files themselves stay plain shell.

### lint-staged

lint-staged runs a command on the staged files. For C++ the useful command is clang-format, and
clang-format already ships `git clang-format --staged`, which formats only the lines a commit
changes and needs no extra dependency. Adding lint-staged would add one more Node.js package that
repeats this. It becomes useful when the project adds many other file types with their own
formatters.

### gitleaks

The repository has an ignore rule for common secret file names, but nothing that looks inside the
files. gitleaks scans staged changes and the whole history. It is a single binary without a
runtime. It was run over the current history and working tree: no findings.

### shellcheck

The hooks and later scripts in `script/` are shell. shellcheck finds quoting and portability
errors. It is a single binary and is installed on GitHub's Ubuntu runners.

### Doxygen

The project had no API documentation. Doxygen is the established generator for C++, it needs no
changes to the code beyond the comment style, and CMake supports it directly through
`doxygen_add_docs`. It follows the same pattern as the other optional tools: a CMake module
that creates a target only when the tool is found.

### GDB and Valgrind

GDB needs no integration: a Debug build already carries debug information. Valgrind is integrated
into CTest by CTest itself (`ctest -T memcheck`), so the only work needed was to verify it and
explain it. The sanitizers remain the first choice for memory errors in tests because they are
faster and run in CI; Valgrind is for cases where the program cannot be rebuilt with a sanitizer.

### Trivy

Trivy scans dependencies, container images and infrastructure files. The project has no lock file
that Trivy reads for C++ (dependencies are Git submodules) and no container yet, so it
would currently find nothing. It becomes useful when the container milestone adds a Dockerfile.
Decision: add it then, with the container work (milestone 6 or 9).

### Jenkins

Jenkins is part of the planned work (milestone 8) and was not part of this change. GitHub Actions
already runs every check, so a Jenkins pipeline would duplicate it. It will be added as an
alternative for teams that use Jenkins.

### Linux Containers

LXC and Incus run full system containers. Docker and Podman run application containers from OCI
images, which is what CI systems, Dev Containers and registries use. The container milestone will
use Docker and Podman. Incus remains possible for someone who wants a full-system environment, but
the template does not need it.

### Devbox

Devbox gives a reproducible shell with pinned tools, built on Nix. Nix does not run natively on
Windows, and the template supports Windows with MSVC, so Devbox cannot be the main way to set up the
environment. It may be offered later as an optional extra next to the containers.

### Jekyll

Jekyll builds a website from Markdown, and needs Ruby. The documentation is Markdown that GitHub
already renders, with relative links between pages. A site generator would add a Ruby dependency
and require link and front-matter changes without improving the daily work of a developer.
Decision: not adopted. If a site is wanted later, MkDocs or Doxygen's HTML output are lighter
options (not evaluated here).

### OCLint

OCLint is a static analyzer for C++. Its releases page lists version 26.02, based on LLVM 21, so it
is maintained. clang-tidy is already integrated and covers the same area, and OCLint would add a
second analyzer tied to a specific LLVM version that must be built or downloaded separately (it
was not installed and not run here). Two analyzers with overlapping rules produce duplicate
findings. Decision: not adopted.

### Bumblebee

Bumblebee, by Perplexity, is a read-only scanner of developer machines for packages, editor
extensions, browser extensions and MCP configurations that match published advisories. It runs
against a machine, not against a repository, it does not read source files, and it supports no C++
package ecosystem. It is a security tool for an organization's fleet of developer computers, not a
feature of a project template. Decision: not adopted. It would only matter for the npm packages in
`package.json`, which are developer tools and not shipped.

## Alternatives that were considered

| Alternative | Verdict |
|-------------|---------|
| `core.hooksPath` with plain shell hooks | The no-Node option. Possible, see the Husky section above. |
| pre-commit (Python framework) | Not adopted: it would add Python instead of Node.js, and the project already treats both as optional. |
| lefthook (single binary) | A fair choice if Node.js is unwanted. Not adopted because the owner named Husky. |
| cppcheck | A complementary analyzer with a different rule set. Worth a trial if clang-tidy misses a class of defect. Not evaluated here. |
| ccache | Speeds up repeated builds. Not needed at this project's size. |
| Dev Containers (`devcontainer.json`) | The likely choice for the container milestone. |
| markdownlint, link checker | Planned for the documentation work in milestone 9; today links are checked by hand. |
| CodeQL | GitHub's analysis for C++. Deferred to milestone 9 with the other security checks. |

## Related

[Git hooks](git-hooks.md), [API documentation](api-documentation.md), [Debugging](../development/debugging.md),
[Static analysis](static-analysis.md)
