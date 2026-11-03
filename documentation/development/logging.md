# Logging

**Purpose:** explain how the application logs, how to change the level, and how to add log calls.
The decision is recorded in [ADR 0010](../architecture/decisions/0010-logging-with-spdlog.md).

## Behavior

- The library is [spdlog](https://github.com/gabime/spdlog). Output goes to **standard error**, so
  standard output carries only program results.
- Each line has the form `[2026-11-02 13:04:05.123] [info] configuration loaded: 2 entries`. The
  level name is colored when standard error is a terminal.
- Levels from lowest to highest: `trace`, `debug`, `info`, `warn`, `error`, `critical`, `off`. Only
  these lowercase names are accepted. A message is written when its level is at or above the
  threshold. `off` writes nothing.
- The default threshold is `warn`.

## Setting the level

| Source | Setting | Effect |
|--------|---------|--------|
| Environment | `APP_LOG_LEVEL=debug` | Sets the level from the start of the run. Takes precedence. |
| Configuration file | `log.level=debug` | Sets the level after the file is loaded. Ignored when `APP_LOG_LEVEL` holds a valid level. |
| Neither | | Level `warn` |

An invalid `APP_LOG_LEVEL` prints a warning and the default level is used. An invalid `log.level`
in the file is an error: the application prints `error: invalid log.level '<value>'` and exits
with status 1.

Because the configuration file is read before its level applies, messages from loading the file
itself (level `debug`) appear only when `APP_LOG_LEVEL` is set.

```sh
APP_LOG_LEVEL=debug ./build/Linux/beta/app configuration/default.conf
```

The sample file `configuration/default.conf` sets `log.level=info`, so a normal run prints the
line `configuration loaded: 2 entries` on standard error.

## Adding log calls

Include `<spdlog/spdlog.h>` and call the level function with a format string:

```cpp
spdlog::debug("read {} bytes from {}", size, path.string());
spdlog::warn("ignoring unknown key '{}'", key);
```

- Use `debug` and `trace` for diagnostic detail, `info` for normal milestones, `warn` for a problem the program recovers from, `error` for a failed operation, and `critical` for a failure the program cannot continue from.
- Log calls MUST NOT print secrets, and MUST NOT print untrusted input that has not been bounded.
- Errors that the caller handles are returned as `Result` values ([ADR 0001](../architecture/decisions/0001-result-type-instead-of-std-expected.md)); logging is not a substitute for returning an error.
- Code that starts the program calls `app::log::init_from_environment()` once, as `internal/main.cpp` does. Library code does not initialize logging.

## Tests

- `test/log_test.cpp`: level names and round trips (Catch2).
- `test/CMakeLists.txt`: CTest tests that run the real `app` and match the log lines on standard
  error (`app.logs_info_from_configuration`, `app.environment_level_overrides_configuration`,
  `app.environment_enables_debug_logging`, `app.warns_about_invalid_environment_level`,
  `app.rejects_invalid_configuration_level`).

## Related

[Build and run](build-and-run.md), [Architecture overview](../architecture/overview.md)
