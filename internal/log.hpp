#pragma once

#include <cstdint>
#include <optional>
#include <string_view>

/// Logging for the application, built on spdlog (ADR 0010).
///
/// Library and application code log with spdlog directly, for example
/// `spdlog::debug("read {} bytes", n)`. This header only covers what the project
/// decides itself: the set of level names, and where log output goes.
namespace app::log {

/// Severity, lowest to highest. `off` disables all output.
enum class Level : std::uint8_t { trace, debug, info, warn, error, critical, off };

/// Accepts exactly the lowercase names `trace`, `debug`, `info`, `warn`,
/// `error`, `critical` and `off`. Returns an empty value for anything else.
[[nodiscard]] std::optional<Level> parse_level(std::string_view name) noexcept;

/// Name of a level, as accepted by parse_level.
[[nodiscard]] std::string_view to_string(Level level) noexcept;

/// Makes a logger that writes to standard error (never standard output, which is
/// reserved for program results) the default logger, and sets its level.
/// Calling it again replaces the logger.
void init(Level level);

/// Changes the level of the default logger.
void set_level(Level level);

/// Level used when nothing else is set.
inline constexpr Level default_level = Level::warn;

/// Name of the environment variable that gives the initial level.
inline constexpr std::string_view level_environment_variable = "APP_LOG_LEVEL";

/// Calls init() with the level in the environment variable, or default_level when
/// it is unset. An invalid value is reported with a warning and default_level is
/// used. Returns true only when the environment gave a valid level, so the caller
/// can let it take precedence over a configuration file.
bool init_from_environment();

/// Name of the configuration key that gives the level once a file is loaded.
inline constexpr std::string_view level_config_key = "log.level";

}  // namespace app::log
