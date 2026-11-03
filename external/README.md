# external/

Third-party libraries, as Git submodules ([ADR 0014](../documentation/architecture/decisions/0014-third-party-libraries-as-submodules.md)).

| Directory | Library | Version | Used by |
|-----------|---------|---------|---------|
| `spdlog/` | [spdlog](https://github.com/gabime/spdlog) | v1.17.0 | the library `app_core` (logging) |
| `Catch2/` | [Catch2](https://github.com/catchorg/Catch2) | v3.7.1 | the tests only |

Clone with the submodules:

```sh
git clone --recurse-submodules <url>
```

In a clone that already exists, run `git submodule update --init --recursive`. To change a version,
check out the new tag inside the submodule, then commit the changed submodule in the main repository.
Do not edit files inside a submodule.
