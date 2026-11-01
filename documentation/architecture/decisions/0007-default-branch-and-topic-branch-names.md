# ADR 0007: Default branch and topic branch names

- **Status:** Accepted
- **Date:** 2026-11-01
- **Amends:** [ADR 0005](0005-branching-and-merge-strategy.md)

## Context

[ADR 0005](0005-branching-and-merge-strategy.md) named the long-lived branches `development` and
`release` and said topic branches are `<type>/<short-description>`, without a precise grammar and
without saying which branch is the default. The repository owner decided that `development` is the
default branch, that topic branch names must be easy to select with regular expressions or `grep`,
and that merging uses Git's current default strategy.

## Decision

- `development` is the repository's default branch.
- A topic branch name matches `^(feat|fix|test|docs|build|ci|refactor|chore)/[a-z0-9]+(-[a-z0-9]+)*$`: a commit type, a slash, and lowercase words or digits separated by single hyphens. The name should be 50 characters or fewer.
- Merges do not select a strategy with `-s`; they use whatever Git's default is (`ort` at Git 2.34 and later).

## Alternatives considered

- **Names with an issue number (`fix/123-null-path`):** easy to link to an issue tracker, but the project has no tracker convention yet. Not chosen.
- **Free-form descriptive names:** cannot be selected mechanically. Not chosen.
- **Naming the strategy `ort` in the rules:** would pin the project to one strategy. Not chosen; the owner asked for the current default.

## Consequences and trade-offs

- The type prefix matches the commit types, so `git branch --list 'docs/*'` and `grep -E` select by type.
- Underscores, dots, uppercase letters and nested slashes are rejected, which excludes some habits (`feature/Foo_Bar`).
- The default branch is a host setting. A repository made from this template MUST set it by hand; commands are in [Conventions](../../development/conventions.md#repository-setup).
- The convention is not enforced by a tool. A host rule or a hook could enforce it later.
