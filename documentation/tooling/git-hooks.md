# Git hooks, commit linting and secret scanning

**Purpose:** explain the optional Git hooks, how commit messages are checked against the commit
convention, and how secrets and shell scripts are checked. The decision is recorded in
[ADR 0011](../architecture/decisions/0011-optional-node-tooling-for-git-hooks.md).

## What is optional

Everything on this page is optional for building and testing. The CMake build never calls Node.js,
Husky or Commitlint ([ASR 0002](../architecture/requirements/0002-minimal-core-toolchain.md)). A
contributor who installs nothing still has every rule enforced, because the CI job `hygiene` runs
the same checks ([GitHub Actions](../ci-cd/github-actions.md)). The hooks give the same answer
earlier, before the commit is made.

## Prerequisites

| Tool | Needed for | Notes |
|------|-----------|-------|
| Node.js 22.12 or newer, with npm | Husky and Commitlint | Commitlint 21 requires Node.js 22.12 or newer. |
| clang-format and `git-clang-format` | the format check in the pre-commit hook | Both come with the Ubuntu package `clang-format`. |
| gitleaks | the secret scan | Optional; the hook skips the scan when it is missing. |
| shellcheck | the shell script check | Optional; the hook skips the check when it is missing. |

The exact versions that were used are in the README [dependency table](../../README.md#dependencies).

## Installing the hooks

From the repository root:

```sh
npm install
```

The `prepare` script in `package.json` runs `husky`, which sets the Git setting `core.hooksPath` to
`.husky/_`. From then on Git runs the hooks in `.husky/`. Check the result with:

```sh
git config core.hooksPath
```

The command prints `.husky/_`. To remove the hooks, run `git config --unset core.hooksPath`.

## The hooks

| Hook | File | What it checks |
|------|------|----------------|
| `commit-msg` | `.husky/commit-msg` | The commit message, with Commitlint and `.commitlintrc.json` |
| `pre-commit` | `.husky/pre-commit` | Formatting of the staged C++ lines, secrets in the staged changes, and staged shell scripts |

Each check in `pre-commit` is skipped, with a notice, when its tool is not installed. A check that
finds a problem makes the commit fail.

### Commit messages

`.commitlintrc.json` extends `@commitlint/config-conventional` and applies the project rules from
[Conventions](../development/conventions.md#commit-messages):

| Rule | Level | Value |
|------|-------|-------|
| Allowed types | error | `feat`, `fix`, `test`, `docs`, `build`, `ci`, `refactor`, `chore` |
| Allowed scopes | error | `core`, `cli`, `cmake`, `presets`, `test`, `docs`, `ci`, `deps` |
| Header length | warning | 72 characters |
| Body line length | warning | 72 characters |

The remaining rules come from the shared configuration, for example a non-empty subject, no full
stop at the end of the subject and a blank line before the body. A warning does not fail a commit.
Commitlint ignores messages that start with `Merge `, so merge commits are not checked. Run it by
hand on a message or a range:

```sh
echo "feat(core): add thing" | npx commitlint
npx commitlint --from <first-commit> --to HEAD
```

### Formatting

The hook runs `git clang-format --staged --extensions cpp,hpp --diff`, which looks only at the
lines that the commit changes. When it prints a diff, run `git clang-format --extensions cpp,hpp`,
review the result and `git add` the files again. The restriction to `cpp` and `hpp` matches the
files that the `format` target covers; without it, `git-clang-format` also tries JSON files and
fails on them. The `format-check` target ([Static analysis](static-analysis.md)) checks whole
files.

### Secrets

The hook runs `gitleaks git --pre-commit --staged --redact --no-banner`, which scans the staged
changes with the default gitleaks rules and hides the secret value in the output. CI scans the
whole Git history. If a finding is a false positive, add a `.gitleaks.toml` with an allowlist and
explain the entry in the commit that adds it. A secret that was committed once MUST be treated as
leaked and revoked, even if the commit is removed later.

### Shell scripts

Staged files named `.husky/<name>` or `script/*.sh` are checked with `shellcheck --shell=sh`. The
Husky hook files have no `#!` line, so the shell is given on the command line.

## Bypassing the hooks

`git commit --no-verify` skips both hooks once. CI still runs the checks, so a bypassed problem is
found there.

## What CI runs

The `hygiene` job checks out the full history, then runs shellcheck on the two hook files, scans
the history with a pinned gitleaks release (the download is verified with a SHA-256 hash), and, for
pull requests, runs Commitlint on every commit between the base and the head of the pull request.
The job has not been run on GitHub yet.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| The hooks do not run | `core.hooksPath` is not set. Run `npm install` from the repository root. |
| `commitlint: not found` | Dependencies are not installed. Run `npm install`. |
| `The engine "node" is incompatible` | Node.js is older than 22.12. Install a newer version. |
| `Configuration file(s) do(es) not support Json` | The `.json` file was passed to clang-format. Use `--extensions cpp,hpp` as the hook does. |
| A commit is rejected for its scope | The scope is not in the list above. Use one of the listed scopes, or omit the scope. |
| `gitleaks` reports a finding that is not a secret | See [Secrets](#secrets). |

## Related

[Conventions](../development/conventions.md), [Static analysis](static-analysis.md),
[GitHub Actions](../ci-cd/github-actions.md), [Tool evaluation](tool-evaluation.md)
