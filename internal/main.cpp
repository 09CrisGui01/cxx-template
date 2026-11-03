#include <spdlog/spdlog.h>

#include <cstdlib>
#include <exception>
#include <iostream>
#include <string_view>

#include "config.hpp"
#include "log.hpp"

#ifndef APP_VERSION
#define APP_VERSION "unknown"
#endif

// Full version: X.Y.Z-TAG+METADATA (see documentation/development/conventions.md).
#ifndef APP_VERSION_FULL
#define APP_VERSION_FULL APP_VERSION
#endif

namespace {
constexpr int exit_ok = EXIT_SUCCESS;
constexpr int exit_failure = EXIT_FAILURE;
constexpr int exit_usage = 2;

// Does the work. Expected failures are returned as exit codes, never thrown.
int run(int argc, char** argv) {
  if (argc > 2) {
    std::cerr << "usage: app [--version | config-file]\n";
    return exit_usage;
  }

  if (argc == 2 && std::string_view{argv[1]} == "--version") {
    std::cout << APP_VERSION_FULL << '\n';
    return exit_ok;
  }

  std::cout << "app " << APP_VERSION << '\n';
  if (argc == 1) {
    return exit_ok;
  }

  const bool level_from_environment = app::log::init_from_environment();
  spdlog::debug("version {}", APP_VERSION_FULL);

  const auto config = app::load_config_file(argv[1]);
  if (!config) {
    std::cerr << "error: " << app::to_string(config.error().code);
    if (config.error().line != 0) {
      std::cerr << " (line " << config.error().line << ')';
    }
    std::cerr << '\n';
    return exit_failure;
  }

  // The environment variable takes precedence over the configuration file.
  if (const auto name = config->get(app::log::level_config_key); name && !level_from_environment) {
    const auto level = app::log::parse_level(*name);
    if (!level) {
      std::cerr << "error: invalid " << app::log::level_config_key << " '" << *name << "'\n";
      return exit_failure;
    }
    app::log::set_level(*level);
  }
  spdlog::info("configuration loaded: {} entries", config->size());

  std::cout << "loaded " << config->size() << " entries\n";
  for (const auto& [key, value] : config->entries()) {
    std::cout << key << '=' << value << '\n';
  }
  return exit_ok;
}

}  // namespace

// Last resort: an unexpected exception (for example std::bad_alloc) becomes an
// error message and a failure exit code instead of std::terminate.
int main(int argc, char* argv[]) {
  try {
    return run(argc, argv);
  } catch (const std::exception& error) {
    std::cerr << "error: unexpected exception: " << error.what() << '\n';
  } catch (...) {
    std::cerr << "error: unexpected unknown exception\n";
  }
  return exit_failure;
}
