# Conventions

**Purpose:** the conventions for using the project's tools and for writing its documentation: Git
branches, merges, commits, tags, versions, the changelog, CMake and build usage, CI, dependencies,
and how documents are written. This page is deliberately separate from
[Coding standards](coding-standards.md), which covers the C++ code itself (naming, ownership, error
handling). Nothing about source code style belongs here.

**Audience:** every contributor, human or AI assistant.

## Normative language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "MAY" and "OPTIONAL" in this documentation are to be interpreted as described in
[RFC 2119](https://www.rfc-editor.org/info/rfc2119/).

- Keywords are written in capitals only. The same words in lowercase have their ordinary meaning (the clarification later made by RFC 8174).
- Keywords appear only in normative statements: rules, requirements and conventions. Descriptions and step-by-step procedures use plain language.
- Documents written before this convention are converted when they are next changed. [Coding standards](coding-standards.md) and the ASRs are already converted.

## Enforcement status

A convention marked "manual" is checked by reviewers until the tool that enforces it exists.

| Convention | Enforced by | Status |
|------------|-------------|--------|
| Commit message format | Commitlint, in the `commit-msg` hook and in the CI job `hygiene` | in place; the hook is optional and needs Node.js ([Git hooks](../tooling/git-hooks.md)); the CI job has not been run on GitHub yet |
| Branch names | The pattern in [Branches](#branches), checked by hand or by a host rule | manual |
| Default branch, merge method, review flow | Host repository settings, review | manual; settings are not stored in the repository ([Repository setup](#repository-setup)) |
| Tag and version format | `tool/cmake/Version.cmake` validates the stage tag and metadata; tag names by review | partly in place; Git tags manual |
| Changelog entries | Review | manual |
| Build presets and `build/<os>/<preset>/` | `CMakePresets.json` | in place |
| Warnings-as-errors | `beta` preset, Linux CI jobs | in place |
| Compiler minimum versions | CMake configure warning | in place |
| Formatting (`.editorconfig`, `.clang-format`) | Editors; `format-check` target | in place; the `format-check` target is optional locally and runs in the CI `quality` job (not yet run on GitHub) |
| Static analysis and sanitizers | `tidy`, `sanitize`, `tsan` presets | in place; optional; findings fail the run |
| Markdown style and link checks | Markdown linter, link checker | not configured yet (Milestone 9); manual |

## Git

### Branches

Two long-lived branches exist:

| Branch | Role |
|--------|------|
| `development` | The mainstream branch. All work integrates here. It MUST be the repository's default branch, so pull requests target it. |
| `release` | Released code only. Tags are created on it. |

- Work happens on topic branches created from `development`.
- A topic branch name MUST match this regular expression (POSIX extended, as used by `grep -E`):

  ```text
  ^(feat|fix|test|docs|build|ci|refactor|chore)/[a-z0-9]+(-[a-z0-9]+)*$
  ```

  That is `<type>/<description>`: `<type>` is one of the commit types below; `<description>` is lowercase words and digits separated by single hyphens, with no underscore, slash, dot or uppercase letter. The name SHOULD be 50 characters or fewer. Examples: `docs/add-changelog`, `fix/null-config-path`.
- Because the pattern is fixed, branch names can be selected mechanically:

  ```sh
  git branch --list 'docs/*'                                   # all branches of one type
  git branch --format='%(refname:short)' | grep -E '^(feat|fix)/'  # several types
  git branch --format='%(refname:short)' | grep -vE '^(development|release|(feat|fix|test|docs|build|ci|refactor|chore)/[a-z0-9]+(-[a-z0-9]+)*)$'   # names that break the convention
  ```
- Topic branches MUST reach `development` through a pull request. CI MUST pass first. A failing check is fixed, not skipped or disabled.
- `development` is merged into `release` only to make a release; the tag is then created on the resulting `release` commit.
- `development` and `release` MUST NOT be force-pushed or have their history rewritten. Branch protection on the host SHOULD enforce this; it is a repository setting, not a file in the repository.
- CI MUST run on pushes to `development` and `release` and on every pull request.
- How a fix to an already released version is made is not defined yet.

Recorded in [ADR 0005](../architecture/decisions/0005-branching-and-merge-strategy.md) and [ADR 0007](../architecture/decisions/0007-default-branch-and-topic-branch-names.md).

### Merging

- The merge method is a merge commit made with Git's current default strategy. A merge MUST NOT pass `-s` or `-X` to select another strategy, so the project follows whatever default the installed Git has. At Git 2.34 and later (the project requires 2.43) that default is `ort`; `recursive` was the default before and is now an alias for `ort`.
- A local merge MUST use `git merge --no-ff <branch>`, so a merge commit is always created.
- Squash merges and rebase merges MUST NOT be used to integrate pull requests. The host's repository settings SHOULD disable them.
- An octopus merge (`git merge <branch1> <branch2> <branch3>`) MAY be used to integrate several branches at once. Git's octopus strategy refuses merges that need manual conflict resolution, so branches that conflict MUST be merged one at a time. Hosts' pull request buttons do not create octopus merges; it is done locally.
- Merge commit messages are not checked by Commitlint, which ignores messages that start with `Merge ` ([ADR 0011](../architecture/decisions/0011-optional-node-tooling-for-git-hooks.md)).

### Commit messages

Commit messages MUST follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

```text
<type>(<scope>)<!>: <subject>

<body>

<footers>
```

Scope, `!`, body and footers are optional.

| Type | Use for |
|------|---------|
| `feat` | A new capability |
| `fix` | A bug fix |
| `test` | Adding or changing tests only |
| `docs` | Documentation only |
| `build` | Build system, presets, CMake, dependencies |
| `ci` | CI configuration (GitHub Actions now; Jenkins later) |
| `refactor` | Code change that alters neither behavior nor the public interface |
| `chore` | Maintenance that fits no other type |

These eight types come from the project specification and are enforced by `.commitlintrc.json`.

Scopes name the area touched. The allowed set, enforced by `.commitlintrc.json`, is `core` (library),
`cli` (executable), `cmake`, `presets`, `test`, `docs`, `ci` and `deps`. The scope SHOULD be omitted
when a change spans areas.

Subject:

- MUST use the imperative mood and present tense: "add", not "added" or "adds".
- MUST start with a lowercase letter and MUST NOT end with a period.
- SHOULD keep the whole first line at 72 characters or fewer.
- SHOULD say what changed; the body says why.

Body and footers:

- The body MUST be separated from the subject by one blank line. Lines SHOULD be wrapped at 72 characters.
- The body SHOULD give the reason and the effect, not a list of files (Git already records those).
- A breaking change MUST be marked with `!` after the type or scope and MUST have a `BREAKING CHANGE: <description>` footer.
- A commit made with AI assistance MUST end with the `Co-Authored-By` trailer for the assistant, as the existing history does.

Conventional Commits relates types to Semantic Versioning: `fix` corresponds to a patch change,
`feat` to a minor change and a breaking change to a major change. The maintainer decides the actual
version at release time.

Examples:

```text
feat: add reusable application target
fix: handle invalid configuration safely
test: add boundary condition coverage
docs: clarify clean checkout workflow
build: configure C++23 requirements
ci: add Jenkins coverage stage
refactor: simplify error handling
chore: update development tooling
```

One commit MUST be one logical change. A commit that mixes unrelated changes MUST be split before it
is shared. A change SHOULD include its tests and its documentation updates in the same commit.

### Before committing

```sh
git status                 # what changed, and what is untracked
git diff                   # unstaged changes
git add <files>            # stage by name, not by "git add ."
git diff --staged          # exactly what will be committed
```

- The staged diff MUST be checked for secrets, machine-specific paths, anything from `build/` and generated files.
- Formatting SHOULD be checked with `cmake --build --preset alpha --target format-check` when clang-format is installed.
- With the optional hooks installed ([Git hooks](../tooling/git-hooks.md)), Git runs the formatting, secret and shell script checks and the message check for you.
- The tests the change touches MUST pass. For code changes, the `beta` preset MUST pass: `cmake --preset beta`, `cmake --build --preset beta`, `ctest --preset beta`.

### What is never committed

Secrets, credentials and private keys; `build/`; coverage and report output; machine-specific
paths; `CMakeUserPresets.json` (ignored by `.gitignore`). These MUST NOT be committed. The source of
a generated file MUST be edited, never the generated file.

### Versions

Versions follow [Semantic Versioning 2.0.0](https://semver.org/). Version tags and version metadata
are information for people: they appear in documentation, the changelog and commit messages. No
program logic depends on them. The build still makes them available (see
[Reading the version](#reading-the-version)).

A version has three forms:

| Form | Pattern | Use |
|------|---------|-----|
| Numeric | `X.Y.Z` | A final release. Also the numeric part of every other form. |
| Tagged | `X.Y.Z-TAG` | A version in a stage before final release. Used for Git tags. |
| Full | `X.Y.Z-TAG+METADATA`, or `X.Y.Z+METADATA` for a final release | Identifies one build. |

- `X.Y.Z` follow Semantic Versioning: MAJOR for incompatible API changes, MINOR for backward-compatible functionality, PATCH for backward-compatible fixes.
- A final release has no tag. A version with a tag is not a final release.
- `TAG` MUST be one of the stage tags below. No other tag is accepted.

| Tag | Meaning |
|-----|---------|
| `alpha` | Development |
| `beta` | Testing and debugging |
| `gamma` | Pre-release |

The configure presets use the same three names (`alpha`, `beta`, `gamma`; see [Build and run](build-and-run.md)), so the build-preset field of the metadata normally reads as a stage name. A preset does not select the stage tag; `-DPROJECT_VERSION_TAG` does.

The order of stages is `alpha`, `beta`, `gamma`, final release. This is also the order Semantic
Versioning gives: identifiers made of letters compare as ASCII text, and a version with a tag has
lower precedence than the same version without one. Moving to the next stage keeps `X.Y.Z` and
changes the tag, unless the numbers also change.

#### Metadata

`METADATA` is Semantic Versioning build metadata. It has exactly five dot-separated fields, in this
order, and it does not affect version precedence:

```text
<timestamp>.<build-preset>.<os>.<architecture>.<toolchain>
```

| Field | Content | Source in CMake | Example |
|-------|---------|-----------------|---------|
| `timestamp` | UTC date of the CMake configure, `YYYYMMDD` (year, month, day) | `string(TIMESTAMP)`; honors `SOURCE_DATE_EPOCH` | `20261101` |
| `build-preset` | Name of the configure preset; `none` when no preset was used | `PROJECT_BUILD_PRESET`, set by `CMakePresets.json` | `beta` |
| `os` | Target operating system | `CMAKE_SYSTEM_NAME` | `Linux` |
| `architecture` | Target processor | `CMAKE_SYSTEM_PROCESSOR` | `x86-64` |
| `toolchain` | C++ compiler id and version | `CMAKE_CXX_COMPILER_ID`, `CMAKE_CXX_COMPILER_VERSION` | `GNU-13-3-0` |

Characters outside `0-9A-Za-z-` in a field become `-`, because Semantic Versioning does not allow
them (`x86_64` becomes `x86-64`, `13.3.0` becomes `13-3-0`).

Example of a full version: `0.1.0-alpha+20261101.beta.Linux.x86-64.GNU-13-3-0`.

#### Where versions MUST appear

- **Changelog:** every release heading carries the full version (see [Changelog](#changelog)).
- **Documentation:** a page that names a specific version of the project MUST write it in the form that identifies it: the tagged form for a stage, the full form when it refers to one build.
- **Commit messages:** a commit that refers directly to a project version MUST write that version with its tag, and with its metadata when it refers to one build. A commit that does not refer to a version needs neither.
- **Git tags:** the tagged form only (see [Tags](#tags)).

#### Reading the version

| Mechanism | Gives | Notes |
|-----------|-------|-------|
| CMake variables `PROJECT_VERSION`, `PROJECT_VERSION_TAG`, `PROJECT_VERSION_TAGGED`, `PROJECT_VERSION_METADATA`, `PROJECT_VERSION_FULL` | Each part and the combinations | Set by `tool/cmake/Version.cmake`; `PROJECT_VERSION_TAGGED` is `X.Y.Z-TAG` or `X.Y.Z` |
| Configure flag `-DPROJECT_VERSION_TAG=<tag>` | Selects the stage; empty means final release | Default is `alpha`. An invalid tag stops the configure with an error. |
| Compile definitions on the `app` target: `APP_VERSION`, `APP_VERSION_TAG`, `APP_VERSION_METADATA`, `APP_VERSION_FULL` | The same values as C++ string literals | Available to code that needs them; no code has to use them |
| Execution flag `app --version` | The full version on standard output | Exit status 0 |
| Run without arguments | `app X.Y.Z` (numeric only) | Unchanged |

The default stage tag is set in `CMakeLists.txt`. Changing the stage is a one-line change there,
or a `-DPROJECT_VERSION_TAG=` override for a single build; `X.Y.Z` is the `VERSION` in `project()`.

Known limitations, accepted by the repository owner ([ADR 0006](../architecture/decisions/0006-versioning-without-final-release-tag.md)):

- A tag has no counter, so each `X.Y.Z` has at most one version per stage. Another build in the same stage differs only in its metadata, or needs a new `X.Y.Z`.
- The date is part of the binary's `--version` output, so builds of the same source made on different days differ unless `SOURCE_DATE_EPOCH` is set. A build that must be bit-for-bit reproducible MUST set it.
- Metadata describes a build, but a release can be built many times on many platforms. The changelog records the metadata of one build; see [Changelog](#changelog).

### Tags

- Each release MUST have a Git tag named `X.Y.Z-TAG`, or `X.Y.Z` for a final release: the tagged form of the version, with no metadata and no other text (no `v` prefix).
- Tags MUST be created on a commit of the `release` branch.
- Tags SHOULD be annotated (`git tag -a`).
- A tag that has been pushed MUST NOT be moved, deleted or reused.

### Changelog

The changelog is `CHANGELOG.md` in the repository root and follows
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

- It is written by hand for people. It MUST NOT be generated from the commit log.
- Every notable user-visible change MUST add an entry under `## [Unreleased]` in the same pull request.
- Entries MUST be grouped under `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`.
- At release, `[Unreleased]` becomes `## [X.Y.Z-TAG+METADATA] - YYYY-MM-DD` (the full version, or `X.Y.Z+METADATA` for a final release, and an ISO 8601 date) and a new empty `[Unreleased]` section is added above it.
- The metadata in a heading MUST be copied from `app --version` of the build that the maintainer designates as the release build. It is not computed from the tag.
- A release that is withdrawn MUST be marked `[YANKED]` and MUST NOT be deleted from the file.
- Comparison links at the bottom of the file are added once the first tag exists. A link target is a Git tag, so it uses the tagged form without metadata.

### Repository setup

These settings live on the host, not in the repository, so a new repository made from this template
MUST be configured by hand:

- The default branch MUST be `development`.
- Merge commits MUST be allowed; squash merges and rebase merges SHOULD be disabled.
- `development` and `release` SHOULD be protected: no force push, no deletion, pull request and passing CI required.

For GitHub, with the `gh` command line tool (**untested**; check the flags against `gh repo edit --help`):

```sh
git branch -m master development          # only if the local branch has another name
git push -u origin development
gh repo edit --default-branch development
gh repo edit --enable-merge-commit --enable-squash-merge=false --enable-rebase-merge=false
```

## Tools

### CMake and builds

- Documentation, scripts and CI MUST use the presets in `CMakePresets.json`. A manual `cmake -S . -B ...` appears only to explain a preset.
- Build trees MUST live in `build/<os>/<preset>/`. A build MUST NOT be made inside the source tree.
- Local variations go in a `CMakeUserPresets.json`, which MUST NOT be committed. Shared presets MUST NOT contain developer-specific paths or settings.
- Compile options MUST be set per target through the helper modules in `tool/cmake/`. Global compiler flags MUST NOT be added.
- A new CMake option MUST be documented in [Build and run](build-and-run.md#cmake-options) in the same change.
- Optional tooling MUST stay optional: the default configure, build and test MUST NOT require Docker, Podman, Node.js, Python, Jenkins or a documentation generator ([ASR 0002](../architecture/requirements/0002-minimal-core-toolchain.md)).

### Toolchain versions

- The soft minimum versions are in the README [dependency table](../../README.md#dependencies). A toolchain SHOULD be at or above them. Reports from older toolchains are best effort.
- A change that raises or lowers a minimum MUST update that table and `tool/cmake/ToolchainRequirements.cmake` together.
- Versions MUST be stated exactly (`13.3.0`, not "recent"), and the text MUST say whether they were observed or reported.

### Checks before a change is ready

- A change MUST build without warnings under the `beta` preset and its tests MUST pass.
- A change SHOULD pass `format-check`, the `tidy` build and the `sanitize` tests when those tools are installed ([Formatting, static analysis and warnings](../tooling/static-analysis.md)).
- A warning flag MUST NOT be weakened, a test deleted or a failure marked as expected to make a check pass. The cause is fixed or the matter is discussed in the pull request.
- The report of a change MUST state what was actually run and its result. A check that was not run MUST be reported as not run.

### Continuous integration

- CI MUST run the same presets and commands the documentation shows. Build logic MUST NOT exist only in the workflow file.
- Third-party actions are referenced by a floating major tag (for example `actions/checkout@v4`), not by commit hash. Changing a reference is a `ci` change and MUST be reviewed. The jobs and settings are described in [GitHub Actions](../ci-cd/github-actions.md).
- Secrets MUST NOT be printed in logs. Workflow permissions MUST stay at the minimum the job needs (currently `contents: read`).
- Results observed by someone other than the author MUST be labelled as reported.

### Dependencies

- Adding or upgrading a dependency MUST come with a stated reason, a pinned version and an updated row in the README dependency table, in the same change. A third-party library is added as a Git submodule in `external/`, pinned to a release tag, and the change is a `build(deps)` commit ([ADR 0014](../architecture/decisions/0014-third-party-libraries-as-submodules.md)).
- A significant choice SHOULD be recorded as an [ADR](../adr-template.md).
- The C++ standard library SHOULD be preferred when it is sufficient.

### Editors

Editors MUST honor `.editorconfig` (UTF-8, LF line endings, 2-space indent, final newline).

## Documentation writing

### Files and structure

- Documentation lives in `documentation/`. The top-level `README.md`, `CHANGELOG.md`, `RELEASES.md`, `AUTHORS.md`, `CONTRIBUTORS.md`, `CODE-OF-CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` and `AGENTS.md` stay in the repository root. GitHub templates stay in `.github/`.
- File and directory names MUST be lowercase, with words separated by hyphens, and end in `.md`. ADRs and ASRs are `NNNN-short-title.md` with a four-digit number, using the next unused number.
- Every page MUST have one H1 title and MUST NOT skip heading levels. Headings use sentence case. The ADR and ASR templates are the exception: they contain a second H1 (`# ADR NNNN: Title`) that belongs to the record being written.
- A substantive page SHOULD open with a **Purpose** line and, as they apply, cover prerequisites, procedure, commands, expected results, troubleshooting and related pages. Short reference pages MAY omit sections that do not apply.
- A new page MUST be added to the [documentation index](../index.md) in the same change. A page for a feature that does not exist yet MUST NOT be written; the index lists it under "Not yet written".

### Language and style

- Documentation is written in English, with American spelling, present tense and active voice, in short sentences. It says what a thing does, not that it is "simple" or "easy".
- One term MUST be used for one thing, spelled as the repository spells it: `documentation/` (not `docs/`), `midput`, `build/<os>/<preset>/`.
- Dates MUST be ISO 8601 (`2026-10-31`). Versions MUST be written exactly.
- Paragraphs SHOULD be wrapped at about 100 columns. A list item MAY be a single long line. Tables MUST NOT be wrapped.

### Formatting

- Commands, file paths, targets, options, environment variables and code identifiers go in backticks.
- Code is fenced with a language tag: `sh`, `bat`, `text`, `json`, `cmake`.
- Links use relative paths and descriptive text, not "here". A link to a section SHOULD use the heading anchor.
- Tables are for comparisons and reference data; lists are for steps and short sets.
- Platform-specific commands SHOULD be shown for each platform that has them, or shown for one with a note on how to adapt them.

### Accuracy

- Every command, path, target, option and report location in a page MUST match the repository. A change to one MUST update the page in the same change.
- A command MUST be run before it is documented. A command that was not run MUST be marked **untested**.
- Verified results, reported results and unverified claims MUST be distinguished, as MUST required and optional tools.
- A result, version or coverage figure that was not observed MUST NOT be stated.
- Each workflow MUST have one canonical explanation. Other pages link to it instead of copying it. For example, versions live only in the README dependency table.
- Template placeholders use `{{name}}` and MUST be listed in the README note about placeholders.

### Records: ADRs and ASRs

- An [ADR](../adr-template.md) SHOULD be written for a significant architectural decision and an [ASR](../asr-template.md) for an architecturally significant requirement. They MUST NOT be used for routine details.
- An ASR states what MUST hold and how it is verified; an ADR states the design choice that satisfies it. They SHOULD link to each other.
- The decision in an accepted record MUST NOT be rewritten. A new record supersedes or amends it. The old status then becomes "Superseded by ...", or an "Amends" line on the new record plus a pointer in the old status ("Accepted; amended by ..."). The verification status of an ASR is updated as evidence arrives.

### Checking documentation

Until the Markdown linter and link checker exist (Milestone 9), a contributor MUST check by hand that
internal links and anchors resolve, that commands match the repository and that the index lists the
page.

## Related

[Coding standards](coding-standards.md), [Build and run](build-and-run.md),
[Documentation index](../index.md)
