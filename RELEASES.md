# Releases

This file lists released versions and describes how a release is made. The detailed list of
changes for each version is in [CHANGELOG.md](CHANGELOG.md).

## Released versions

No version has been released yet. Each release is added here with its Git tag and date.

| Version | Git tag | Date | Notes |
|---------|---------|------|-------|
| none yet | | | |

## How a release is made

The rules are in [Conventions](documentation/development/conventions.md#versions). In short:

1. Changes reach `release` from `development` by a merge commit.
2. The version in `CMakeLists.txt` and the heading in `CHANGELOG.md` are updated to the same
   `X.Y.Z-TAG`, or to `X.Y.Z` for a final release.
3. The merge commit is tagged `X.Y.Z-TAG` (no `v` prefix). The tag does not contain build metadata.
4. A row is added to the table above.
