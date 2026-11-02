# ADR 0005: Branching and merge strategy

- **Status:** Accepted; amended by [ADR 0007](0007-default-branch-and-topic-branch-names.md)
- **Date:** 2026-10-31

## Context

The repository owner decided on two long-lived branches, `development` (mainstream) and `release`,
with merge commits as the merge method and the option of octopus merges. The initial CI workflow
triggered on a branch named `main`, which does not exist in this strategy.

Facts about Git: since version 2.34 the default merge strategy is `ort`, and `recursive` is an alias
for it. The octopus strategy refuses merges that need manual conflict resolution. The project
requires Git 2.43 or newer in its dependency table, so `ort` applies.

## Decision

- Topic branches (`<type>/<short-description>`) are created from `development` and merged into it by pull request.
- `development` is merged into `release` to make a release, and the release tag is created on `release`.
- Merges use a merge commit (`git merge --no-ff`) with Git's default strategy. Squash and rebase merges are not used. Octopus merges are allowed locally for several non-conflicting branches.
- CI runs on pushes to `development` and `release` and on all pull requests.

## Alternatives considered

- **A single `main` branch with tags (trunk-based):** fewer branches. Not chosen by the repository owner.
- **Squash merges:** one commit per change and a linear history, but commits on topic branches are lost. Not chosen.
- **Rebase merges:** linear history, but rewrites commits and their hashes. Not chosen.

## Consequences and trade-offs

- Branch protection, the default branch and the allowed merge methods are repository settings on the host. They are not stored in the repository and must be configured by hand.
- Host pull request buttons do not create octopus merges.
- The default merge commit message ("Merge pull request ...") does not follow Conventional Commits; how Commitlint treats merge commits is decided in Milestone 5.
- A process for fixing an already released version is not defined yet.
- Two long-lived branches require a deliberate merge step for every release.
