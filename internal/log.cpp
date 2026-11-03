#include "log.hpp"

#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

#include <array>
#include <cstdlib>
#include <memory>
#include <optional>
#include <string>
#include <utility>

namespace app::log {

namespace {

struct LevelName {
  std::string_view name;
  Level level;
  spdlog::level::level_enum backend;
};

constexpr std::array<LevelName, 7> level_names{{
    {.name = "trace", .level = Level::trace, .backend = spdlog::level::trace},
    {.name = "debug", .level = Level::debug, .backend = spdlog::level::debug},
    {.name = "info", .level = Level::info, .backend = spdlog::level::info},
    {.name = "warn", .level = Level::warn, .backend = spdlog::level::warn},
    {.name = "error", .level = Level::error, .backend = spdlog::level::err},
    {.name = "critical", .level = Level::critical, .backend = spdlog::level::critical},
    {.name = "off", .level = Level::off, .backend = spdlog::level::off},
}};

spdlog::level::level_enum backend_level(Level level) noexcept {
  for (const auto& entry : level_names) {
    if (entry.level == level) {
      return entry.backend;
    }
  }
  return spdlog::level::off;
}

// getenv is flagged as unsafe by MSVC, so Windows uses its own function.
std::optional<std::string> environment_value(const char* name) {
#ifdef _WIN32
  char* raw = nullptr;
  std::size_t size = 0;
  if (_dupenv_s(&raw, &size, name) != 0 || raw == nullptr) {
    return std::nullopt;
  }
  std::string value{raw};
  std::free(raw);
  return value;
#else
  const char* raw = std::getenv(name);
  if (raw == nullptr) {
    return std::nullopt;
  }
  return std::string{raw};
#endif
}

}  // namespace

std::optional<Level> parse_level(std::string_view name) noexcept {
  for (const auto& entry : level_names) {
    if (entry.name == name) {
      return entry.level;
    }
  }
  return std::nullopt;
}

std::string_view to_string(Level level) noexcept {
  for (const auto& entry : level_names) {
    if (entry.level == level) {
      return entry.name;
    }
  }
  return "off";
}

void init(Level level) {
  auto logger = std::make_shared<spdlog::logger>(
      "app", std::make_shared<spdlog::sinks::stderr_color_sink_mt>());
  logger->set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%^%l%$] %v");
  spdlog::set_default_logger(std::move(logger));
  set_level(level);
}

void set_level(Level level) { spdlog::set_level(backend_level(level)); }

bool init_from_environment() {
  const auto value = environment_value(std::string{level_environment_variable}.c_str());
  if (!value) {
    init(default_level);
    return false;
  }
  const auto level = parse_level(*value);
  if (!level) {
    init(default_level);
    spdlog::warn("ignoring invalid {}='{}'; using '{}'", level_environment_variable, *value,
                 to_string(default_level));
    return false;
  }
  init(*level);
  return true;
}

}  // namespace app::log
