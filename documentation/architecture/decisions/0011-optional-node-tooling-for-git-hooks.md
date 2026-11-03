# ADR 0011: Optional Node.js tooling for Git hooks and commit linting

- **Status:** Accepted
- **Date:** 2026-11-02

## Context

[Conventions](../../development/conventions.md) require Conventional Commits, and the repository
owner asked for Husky, Commitlint and gitleaks, among other tools. Until now the commit format was
checked by review only. [ASR 0002](../requirements/0002-minimal-core-toolchain.md) requires that
configuring, building and testing need no Node.js or Python, so any Node.js tooling has to stay
optional.

Verified on Linux with Node.js 22.23.4 and npm 10.9.9: `npm install` installs Husky 9.1.7 and
Commitlint 21.2.4 with no vulnerabilities reported; in a clone, a commit with a bad message was
rejected, a commit with a valid message was accepted, and a commit with unformatted C++ was
rejected by the pre-commit hook. The full existing history passes Commitlint with warnings only (two
subjects longer than 72 characters, and one body line longer than 72). Not verified: Windows,
macOS and FreeBSD, and the CI job `hygiene` on GitHub.

## Decision

We add `package.json`, `package-lock.json`, `.commitlintrc.json` and a `.husky/` directory. The
`package.json` is private and holds only development tools; it is not used by CMake. `npm install`
sets up the hooks.

- The `commit-msg` hook runs Commitlint. Allowed types are the eight in Conventions, and allowed
  scopes are `core`, `cli`, `cmake`, `presets`, `test`, `docs`, `ci` and `deps`. Header and body
  length rules are warnings.
- The `pre-commit` hook runs `git clang-format` on the staged C++ lines, gitleaks on the staged
  changes and shellcheck on staged shell scripts. A missing tool is skipped with a notice.
- Merge commits are not checked (Commitlint ignores messages that start with `Merge `). This settles
  the question that [Conventions](../../development/conventions.md#git) left open.
- lint-staged is not used. `git clang-format --staged` formats only the lines a commit changes and
  needs no package.
- The CI job `hygiene` runs shellcheck, scans the history with gitleaks (a pinned release, verified
  by SHA-256) and, for pull requests, runs Commitlint on the pull request's commits. CI is the
  enforcement point; the hooks are a convenience.

## Alternatives considered

- **Plain shell hooks with `core.hooksPath`:** no Node.js, but the message check would be hand-written.
- **pre-commit or lefthook:** workable; not chosen because the owner named Husky, and pre-commit adds Python.
- **lint-staged:** see above.
- **Required hooks:** rejected by ASR 0002; contributors without Node.js must still be able to work.

## Consequences and trade-offs

- Contributors who want local checks need Node.js 22.12 or newer. Those who do not install it find problems in CI instead.
- The repository now contains a lock file for developer tools. Its packages are updated deliberately, as a `build(deps)` change.
- `git clang-format` formats only `.cpp` and `.hpp` files; other file types are not formatted by the hook.
- Hooks can be bypassed with `--no-verify`. This is intended; CI is the gate.

## Related decisions

[ASR 0002](../requirements/0002-minimal-core-toolchain.md), [ADR 0009](0009-optional-quality-tools-as-cmake-modules.md)
