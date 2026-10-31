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
| Commit message format | Commitlint | not configured yet (Milestone 5); manual |
| Branch names, merge method, review flow | Host repository settings, review | manual; settings are not stored in the repository |
| Tag and version format | none | manual; no version variables in CMake yet |
| Changelog entries | Review | manual |
| Build presets and `build/<os>/<preset>/` | `CMakePresets.json` | in place |
| Warnings-as-errors | `test` preset, Linux CI jobs | in place |
| Compiler minimum versions | CMake configure warning | in place |
| Formatting (`.editorconfig`) | Editors | in place; `clang-format` arrives in Milestone 4 |
| Markdown style and link checks | Markdown linter, link checker | not configured yet (Milestone 9); manual |

## Git

### Branches

Two long-lived branches exist:

| Branch | Role |
|--------|------|
| `development` | The mainstream branch. All work integrates here. It SHOULD be the repository's default branch so pull requests target it. |
| `release` | Released code only. Tags are created on it. |

- Work happens on topic branches created from `development`.
- A topic branch name MUST be `<type>/<short-description>`: lowercase, words separated by hyphens, `<type>` one of the commit types below. Example: `docs/add-changelog`.
- Topic branches MUST reach `development` through a pull request. CI MUST pass first. A failing check is fixed, not skipped or disabled.
- `development` is merged into `release` only to make a release; the tag is then created on the resulting `release` commit.
- `development` and `release` MUST NOT be force-pushed or have their history rewritten. Branch protection on the host SHOULD enforce this; it is a repository setting, not a file in the repository.
- CI MUST run on pushes to `development` and `release` and on every pull request.
- How a fix to an already released version is made is not defined yet.

Recorded in [ADR 0005](../architecture/decisions/0005-branching-and-merge-strategy.md).

### Merging

- The merge method is a merge commit using Git's default strategy. That strategy is `ort`; `recursive` was the default before Git 2.34 and is now an alias for `ort`.
- A local merge MUST use `git merge --no-ff <branch>`, so a merge commit is always created.
- Squash merges and rebase merges MUST NOT be used to integrate pull requests. The host's repository settings SHOULD disable them.
- An octopus merge (`git merge <branch1> <branch2> <branch3>`) MAY be used to integrate several branches at once. Git's octopus strategy refuses merges that need manual conflict resolution, so branches that conflict MUST be merged one at a time. Hosts' pull request buttons do not create octopus merges; it is done locally.
- How merge commit messages fit the commit message convention under Commitlint is decided in Milestone 5.

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

These eight types come from the project specification. The final list is fixed when Commitlint is
configured in Milestone 5.

Scopes name the area touched. The proposed set, to be confirmed in Milestone 5, is `core` (library),
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
- The tests the change touches MUST pass. For code changes, the `test` preset MUST pass: `cmake --preset test`, `cmake --build --preset test`, `ctest --preset test`.

### What is never committed

Secrets, credentials and private keys; `build/`; coverage and report output; machine-specific
paths; `CMakeUserPresets.json` (ignored by `.gitignore`). These MUST NOT be committed. The source of
a generated file MUST be edited, never the generated file.

### Versions

Versions follow [Semantic Versioning 2.0.0](https://semver.org/). Every version MUST have a
pre-release tag and build metadata, in the form:

```text
X.Y.Z-TAG+METADATA
```

- `X.Y.Z` follow Semantic Versioning: MAJOR for incompatible API changes, MINOR for backward-compatible functionality, PATCH for backward-compatible fixes.
- `TAG` MUST be one of the values below. No other tag is accepted.
- `METADATA` follows Semantic Versioning build metadata syntax: dot-separated identifiers of `0-9A-Za-z-`. Its content is not yet defined (open item). It does not affect version precedence.
- A version without a tag or without metadata, such as `1.0.0`, MUST NOT be used.

| Tag | Meaning |
|-----|---------|
| `alpha` | Under heavy development |
| `beta` | Under testing, bug fixing, coverage analysis and similar work |
| `gamma` | Pre-release |
| `delta` | Final release |

The project's own order of stages is `alpha`, `beta`, `gamma`, `delta`. Moving to the next stage
keeps `X.Y.Z` and changes the tag, unless the numbers also change.

Known limitations, accepted by the repository owner ([ADR 0004](../architecture/decisions/0004-semver-versioning-with-greek-stage-tags.md)):

- Semantic Versioning orders pre-release identifiers by comparing them as ASCII text, so `delta` sorts before `gamma`. A tool that sorts by Semantic Versioning precedence ranks `X.Y.Z-gamma` above `X.Y.Z-delta`. Tooling MUST NOT use Semantic Versioning precedence to order stages; use the order in this section.
- Under Semantic Versioning, `X.Y.Z-delta` has lower precedence than `X.Y.Z`. External tools therefore see every release, including `delta`, as a pre-release.
- A tag has no counter, so each `X.Y.Z` has at most one version per stage. Another build in the same stage needs a new `X.Y.Z`.
- CMake's `project(VERSION)` accepts numbers only, so the tag and metadata need separate variables. These are not implemented yet; the current `0.1.0` in `CMakeLists.txt` and in the application's output does not follow this format.

### Tags

- Each release MUST have a Git tag named `X.Y.Z-TAG`: the version and its tag, with no metadata and no other text (no `v` prefix).
- Tags MUST be created on a commit of the `release` branch.
- Tags SHOULD be annotated (`git tag -a`).
- A tag that has been pushed MUST NOT be moved, deleted or reused.

### Changelog

The changelog is `CHANGELOG.md` in the repository root and follows
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

- It is written by hand for people. It MUST NOT be generated from the commit log.
- Every notable user-visible change MUST add an entry under `## [Unreleased]` in the same pull request.
- Entries MUST be grouped under `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`.
- At release, `[Unreleased]` becomes `## [X.Y.Z-TAG] - YYYY-MM-DD` (the version without metadata, an ISO 8601 date) and a new empty `[Unreleased]` section is added above it.
- A release that is withdrawn MUST be marked `[YANKED]` and MUST NOT be deleted from the file.
- Comparison links at the bottom of the file are added once the first tag exists.

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

- A change MUST build without warnings under the `test` preset and its tests MUST pass.
- A warning flag MUST NOT be weakened, a test deleted or a failure marked as expected to make a check pass. The cause is fixed or the matter is discussed in the pull request.
- The report of a change MUST state what was actually run and its result. A check that was not run MUST be reported as not run.

### Continuous integration

- CI MUST run the same presets and commands the documentation shows. Build logic MUST NOT exist only in the workflow file.
- Third-party actions are pinned by tag at present. Changing a pin is a `ci` change and MUST be reviewed.
- Secrets MUST NOT be printed in logs. Workflow permissions MUST stay at the minimum the job needs (currently `contents: read`).
- Results observed by someone other than the author MUST be labelled as reported.

### Dependencies

- Adding or upgrading a dependency MUST come with a stated reason, a pinned version and an updated row in the README dependency table, in the same change.
- A significant choice SHOULD be recorded as an [ADR](../adr-template.md).
- The C++ standard library SHOULD be preferred when it is sufficient.

### Editors

Editors MUST honor `.editorconfig` (UTF-8, LF line endings, 2-space indent, final newline).

## Documentation writing

### Files and structure

- Documentation lives in `documentation/`. The top-level `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md` and `AGENTS.md` stay in the repository root.
- File and directory names MUST be lowercase, with words separated by hyphens, and end in `.md`. ADRs and ASRs are `NNNN-short-title.md` with a four-digit number, using the next unused number.
- Every page MUST have one H1 title and MUST NOT skip heading levels. Headings use sentence case.
- A substantive page SHOULD open with a **Purpose** line and, as they apply, cover prerequisites, procedure, commands, expected results, troubleshooting and related pages. Short reference pages MAY omit sections that do not apply.
- A new page MUST be added to the [documentation index](../index.md) in the same change. A page for a feature that does not exist yet MUST NOT be written; the index lists it under "Not yet written".

### Language and style

- Documentation is written in English, with American spelling, present tense and active voice, in short sentences. It says what a thing does, not that it is "simple" or "easy".
- One term MUST be used for one thing, spelled as the repository spells it: `documentation/` (not `docs/`), `midput`, `build/<os>/<preset>/`.
- Dates MUST be ISO 8601 (`2026-10-31`). Versions MUST be written exactly.
- Prose SHOULD be wrapped at about 100 columns. Tables MUST NOT be wrapped.

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
- The decision in an accepted record MUST NOT be rewritten. A new record supersedes it, and the old status becomes "Superseded by ...". The verification status of an ASR is updated as evidence arrives.

### Checking documentation

Until the Markdown linter and link checker exist (Milestone 9), a contributor MUST check by hand that
internal links and anchors resolve, that commands match the repository and that the index lists the
page.

## Related

[Coding standards](coding-standards.md), [Build and run](build-and-run.md),
[Documentation index](../index.md)
