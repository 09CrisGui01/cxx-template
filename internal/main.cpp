#include <cstdlib>
#include <iostream>
#include <string_view>

#include "config.hpp"

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
}  // namespace

int main(int argc, char* argv[]) {
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

  const auto config = app::load_config_file(argv[1]);
  if (!config) {
    std::cerr << "error: " << app::to_string(config.error().code);
    if (config.error().line != 0) {
      std::cerr << " (line " << config.error().line << ')';
    }
    std::cerr << '\n';
    return exit_failure;
  }

  std::cout << "loaded " << config->size() << " entries\n";
  for (const auto& [key, value] : config->entries()) {
    std::cout << key << '=' << value << '\n';
  }
  return exit_ok;
}
