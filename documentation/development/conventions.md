# Conventions

**Purpose:** the expected conventions for using the project's tools and for writing its
documentation: Git commits, branches, CMake and build usage, CI, dependencies, and how documents
are written. This page is deliberately separate from [Coding standards](coding-standards.md), which
covers the C++ code itself (naming, ownership, error handling). Nothing about source code style
belongs here.

**Audience:** every contributor, human or AI assistant.

## Enforcement status

Conventions marked "manual" are checked by reviewers until the tool that enforces them exists.

| Convention | Enforced by | Status |
|------------|-------------|--------|
| Commit message format | Commitlint | not configured yet (Milestone 5); manual |
| Branch names, review flow | Review, CI | manual |
| Build presets and `build/<os>/<preset>/` | `CMakePresets.json` | in place |
| Warnings-as-errors | `test` preset, Linux CI jobs | in place |
| Compiler minimum versions | CMake configure warning | in place |
| Formatting (`.editorconfig`) | Editors | in place; `clang-format` arrives in Milestone 4 |
| Markdown style and link checks | Markdown linter, link checker | not configured yet (Milestone 9); manual |

## Git

### Commit messages

Format: [Conventional Commits](https://www.conventionalcommits.org/).

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

Scopes name the area touched. Proposed set, to be confirmed in Milestone 5: `core` (library),
`cli` (executable), `cmake`, `presets`, `test`, `docs`, `ci`, `deps`. Omit the scope when a change
spans areas.

Subject rules:

- Imperative mood and present tense: "add", not "added" or "adds".
- Lowercase first letter, no trailing period.
- 72 characters or fewer for the whole first line.
- Say what changed and, in the body, why.

Body and footers:

- Separate the body from the subject with one blank line. Wrap lines at 72 characters.
- Use the body for the reason and the effect, not for a list of files (Git already records those).
- Mark a breaking change with `!` after the type or scope and add a `BREAKING CHANGE: <description>` footer.
- A commit made with AI assistance ends with the `Co-Authored-By` trailer for the assistant, as the existing history does.

Examples (from the project specification):

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

One commit is one logical change. A commit that mixes unrelated changes is split before it is
shared. Code changes include their tests and their documentation updates in the same commit.

### Before committing

```sh
git status                 # what changed, and what is untracked
git diff                   # unstaged changes
git add <files>            # stage by name, not by "git add ."
git diff --staged          # exactly what will be committed
```

Check that the staged diff contains no secrets, no machine-specific paths, nothing from `build/`
and no generated files. Then run the tests the change touches, and for code changes the `test`
preset (`cmake --preset test`, `cmake --build --preset test`, `ctest --preset test`).

### What is never committed

Secrets, credentials and private keys; `build/`; coverage and report output; machine-specific
paths; `CMakeUserPresets.json` (ignored by `.gitignore`). Edit the source of a generated file, never
the generated file.

### Branches and review

- The default branch is `main`; the CI workflow runs on pushes to `main` and on pull requests.
- Work happens on short-lived branches named `<type>/<short-description>` in lowercase with hyphens, for example `docs/add-conventions-page`. The `<type>` is a commit type from the table above.
- Changes reach `main` through a pull request. CI must pass first. A failing check is fixed, not skipped or disabled.
- Do not rewrite history on shared branches and do not force-push to `main`.
- The merge method (merge commit, squash or rebase) is not decided yet. It is set in Milestone 5, with the Git workflow page.

### Versions, tags and releases

The project version has one source: `VERSION` in the `project()` call in `CMakeLists.txt`. Tagging
and release procedures are not defined yet and arrive with the release workflow.

## Tools

### CMake and builds

- Use the presets in `CMakePresets.json` in documentation, scripts and CI. Show a manual `cmake -S . -B ...` only to explain a preset.
- Build trees live in `build/<os>/<preset>/`. Never build inside the source tree.
- Local variations go in a `CMakeUserPresets.json`, which is not committed. Shared presets must not contain developer-specific paths or settings.
- Set compile options per target, through the helper modules in `tool/cmake/`. Do not add global compiler flags.
- A new CMake option is documented in [Build and run](build-and-run.md#cmake-options) in the same change.
- Optional tooling stays optional: the default configure, build and test must not require Docker, Podman, Node.js, Python, Jenkins or a documentation generator ([ASR 0002](../architecture/requirements/0002-minimal-core-toolchain.md)).

### Toolchain versions

- The soft minimum versions are in the README [dependency table](../../README.md#dependencies). Use a toolchain at or above them. Reports from older toolchains are best effort.
- When a change raises or lowers a minimum, update that table and `tool/cmake/ToolchainRequirements.cmake` together.
- State versions exactly (`13.3.0`, not "recent"), and say whether you observed them or someone reported them.

### Checks before a change is ready

- The change builds without warnings under the `test` preset, and its tests pass.
- Do not weaken a warning flag, delete a test or mark a failure as expected to make a check pass. Fix the cause or discuss it in the pull request.
- Report what was actually run and its result. If a check was not run, say so.

### Continuous integration

- CI runs the same presets and commands the documentation shows. Do not put build logic only in the workflow file.
- Third-party actions are pinned by tag at present; changing a pin is a `ci` change and is reviewed.
- Never print secrets in logs. Workflow permissions stay at the minimum the job needs (currently `contents: read`).
- Results observed by someone other than the author are labelled as reported.

### Dependencies

- Adding or upgrading a dependency needs a stated reason, a pinned version and an updated row in the README dependency table, in the same change.
- Record a significant choice as an [ADR](../adr-template.md).
- Prefer the C++ standard library when it is sufficient.

### Editors

Respect `.editorconfig` (UTF-8, LF line endings, 2-space indent, final newline).

## Documentation writing

### Files and structure

- Documentation lives in `documentation/`. The top-level `README.md`, `CONTRIBUTING.md`, `SECURITY.md` and `AGENTS.md` stay in the repository root.
- File and directory names: lowercase, words separated by hyphens, `.md` extension. ADRs and ASRs are `NNNN-short-title.md` with a four-digit number, using the next unused number.
- Every page has one H1 title and no skipped heading levels. Headings use sentence case.
- A substantive page opens with a **Purpose** line and, as they apply, covers prerequisites, procedure, commands, expected results, troubleshooting and related pages. Short reference pages may omit sections that do not apply.
- A new page is added to the [documentation index](../index.md) in the same change. A page for a feature that does not exist yet is not written; the index lists it under "Not yet written".

### Language and style

- English, American spelling, present tense, active voice. Short sentences. Say what a thing does, not that it is "simple" or "easy".
- Use one term for one thing, and the same spelling the repository uses: `documentation/` (not `docs/`), `midput`, `build/<os>/<preset>/`.
- Dates are ISO 8601 (`2026-10-31`). Versions are written exactly.
- Wrap prose at about 100 columns. Do not wrap tables.

### Formatting

- Put commands, file paths, targets, options, environment variables and code identifiers in backticks.
- Fence code with a language tag: `sh`, `bat`, `text`, `json`, `cmake`.
- Link with relative paths and descriptive link text, not "here". Link to a heading anchor when pointing at a section.
- Use tables for comparisons and reference data, lists for steps or short sets.
- Show platform-specific commands for each platform that has them, or show one and say how to adapt it.

### Accuracy

- Every command, path, target, option and report location in a page must match the repository. When one changes, the same change updates the page.
- Run a command before documenting it. A command that was not run is marked **untested**.
- Distinguish verified results from reported and unverified ones, and required tools from optional ones.
- Do not state a result, version or coverage figure that was not observed.
- One canonical explanation per workflow. Other pages link to it instead of copying it. For example, versions live only in the README dependency table.
- Template placeholders use `{{name}}` and are listed in the README note about placeholders.

### Records: ADRs and ASRs

- Write an [ADR](../adr-template.md) for a significant architectural decision and an [ASR](../asr-template.md) for an architecturally significant requirement. Do not use them for routine details.
- An ASR states what must hold and how it is verified; an ADR states the design choice that satisfies it. Link them to each other.
- Do not rewrite the decision in an accepted record. Supersede it with a new record and set the old status to "Superseded by ...". The verification status of an ASR is updated as evidence arrives.

### Checking documentation

Until the Markdown linter and link checker exist (Milestone 9), a contributor checks by hand that
internal links and anchors resolve, that commands match the repository and that the index lists the
page.

## Related

[Coding standards](coding-standards.md), [Build and run](build-and-run.md),
[Documentation index](../index.md)
