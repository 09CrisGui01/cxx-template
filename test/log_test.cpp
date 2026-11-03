#include "log.hpp"

#include <array>
#include <catch2/catch_test_macros.hpp>
#include <string_view>

using app::log::Level;

TEST_CASE("parse_level accepts every level name", "[log]") {
  CHECK(app::log::parse_level("trace") == Level::trace);
  CHECK(app::log::parse_level("debug") == Level::debug);
  CHECK(app::log::parse_level("info") == Level::info);
  CHECK(app::log::parse_level("warn") == Level::warn);
  CHECK(app::log::parse_level("error") == Level::error);
  CHECK(app::log::parse_level("critical") == Level::critical);
  CHECK(app::log::parse_level("off") == Level::off);
}

TEST_CASE("parse_level rejects other text", "[log]") {
  for (const std::string_view text : {"", "INFO", "Info", "warning", "fatal", " info", "info "}) {
    CAPTURE(text);
    CHECK_FALSE(app::log::parse_level(text).has_value());
  }
}

TEST_CASE("to_string and parse_level round-trip", "[log]") {
  const std::array levels{Level::trace, Level::debug,    Level::info, Level::warn,
                          Level::error, Level::critical, Level::off};
  for (const Level level : levels) {
    CHECK(app::log::parse_level(app::log::to_string(level)) == level);
  }
}

TEST_CASE("init and set_level can be called repeatedly", "[log]") {
  app::log::init(Level::off);
  app::log::set_level(Level::debug);
  app::log::init(Level::off);
  SUCCEED();
}
