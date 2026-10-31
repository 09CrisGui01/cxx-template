# ASR 0005: Deterministic, self-contained tests

- **Status:** Accepted
- **Date:** 2026-10-31
- **Verification status:** Met

## Context

The specification requires deterministic tests that do not depend on production data, undocumented
local files or external services, and that report failure through a nonzero exit status.

## Requirement

Quality attribute: testability. Every automated test shall produce the same result on every run,
shall need no network and no file other than those it creates or the tracked sample
`configuration/default.conf`, and shall run through CTest so that a failure makes `ctest` exit
nonzero.

## Verification

- Tests that need files create them in a uniquely named temporary directory (`TempDir` in `test/config_test.cpp`) and remove it afterwards.
- Integration tests that must fail use CTest's `WILL_FAIL` property, so the suite checks that the application exits nonzero.
- The suite was run many times locally across GCC and Clang, Debug and Release, with no intermittent failure observed. That is evidence, not proof, of determinism.
- Not verified: Catch2's own failure exit status was not tested by deliberately failing a case. Running with the network disabled was not tested; the first configure needs network access (see [ASR 0001](0001-clean-checkout-reproducibility.md)), but running tests does not.

## Alternatives considered

- **Shared fixture files under `data/`:** couples tests to tracked data that production runs may change. Not chosen.
- **Mocking the filesystem:** more code and less realism than real temporary files. Not chosen.

## Consequences and trade-offs

- Tests touch the real filesystem, so they depend on a writable temporary directory.
- The symlink test is skipped (`SKIP`) where symlinks cannot be created; a skipped test is not a pass for that platform.

## Related decisions

[ADR 0002](../decisions/0002-catch2-test-framework.md)
