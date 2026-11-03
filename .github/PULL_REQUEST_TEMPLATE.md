## What and why

<!-- What does this change do, and why is it needed? Link the issue if there is one. -->

## How it was checked

<!-- List the commands you ran and their results. State plainly what was not run. -->

- [ ] `cmake --preset beta`, `cmake --build --preset beta`, `ctest --preset beta`
- [ ] `format-check` (if clang-format is installed)
- [ ] Other checks (`tidy`, `sanitize`, `coverage`):

## Checklist

- [ ] The commit messages follow [Conventional Commits](../documentation/development/conventions.md#commit-messages)
- [ ] The branch name follows the [convention](../documentation/development/conventions.md#branches)
- [ ] Tests are added or updated
- [ ] Documentation is updated (and the index, for a new page)
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]` for a user-visible change
- [ ] No secrets, machine-specific paths or generated files are committed
