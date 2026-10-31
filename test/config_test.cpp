#include <catch2/catch_test_macros.hpp>

#include <filesystem>
#include <fstream>
#include <string>

#include "config.hpp"

using app::ErrorCode;

namespace {

// Creates a unique temp directory and removes it on destruction.
class TempDir {
 public:
  TempDir() {
    static int counter = 0;
    path_ = std::filesystem::temp_directory_path() /
            ("app_tests_" + std::to_string(::std::filesystem::file_time_type::clock::now()
                                               .time_since_epoch()
                                               .count()) +
             "_" + std::to_string(counter++));
    std::filesystem::create_directories(path_);
  }
  ~TempDir() {
    std::error_code ec;
    std::filesystem::remove_all(path_, ec);
  }
  TempDir(const TempDir&) = delete;
  TempDir& operator=(const TempDir&) = delete;
  [[nodiscard]] const std::filesystem::path& path() const { return path_; }

 private:
  std::filesystem::path path_;
};

}  // namespace

TEST_CASE("parse_config accepts valid input", "[config]") {
  const auto result = app::parse_config("a=1\n  b = two words  \n# comment\n\nc.d-e_f=\n");
  REQUIRE(result.has_value());
  CHECK(result->size() == 3);
  CHECK(result->get("a") == "1");
  CHECK(result->get("b") == "two words");
  CHECK(result->get("c.d-e_f") == "");
  CHECK_FALSE(result->get("missing").has_value());
}

TEST_CASE("parse_config handles empty and CRLF input", "[config]") {
  CHECK(app::parse_config("")->size() == 0);
  const auto crlf = app::parse_config("k=v\r\n");
  REQUIRE(crlf.has_value());
  CHECK(crlf->get("k") == "v");
}

TEST_CASE("parse_config keeps '=' inside values", "[config]") {
  const auto result = app::parse_config("url=a=b=c");
  REQUIRE(result.has_value());
  CHECK(result->get("url") == "a=b=c");
}

TEST_CASE("parse_config rejects malformed lines with line numbers", "[config]") {
  struct Case {
    const char* text;
    ErrorCode code;
    std::size_t line;
  };
  const Case cases[] = {
      {"novalue", ErrorCode::missing_separator, 1},
      {"ok=1\n=value", ErrorCode::empty_key, 2},
      {"bad key=1", ErrorCode::invalid_key, 1},
      {"a=1\nb=2\na=3", ErrorCode::duplicate_key, 3},
  };
  for (const auto& c : cases) {
    CAPTURE(c.text);
    const auto result = app::parse_config(c.text);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == c.code);
    CHECK(result.error().line == c.line);
  }
}

TEST_CASE("parse_config enforces size limits at the boundary", "[config][limits]") {
  SECTION("line length") {
    const std::string at_limit = "k=" + std::string(app::max_line_bytes - 2, 'x');
    CHECK(app::parse_config(at_limit).has_value());
    const auto over = app::parse_config(at_limit + "x");
    REQUIRE_FALSE(over.has_value());
    CHECK(over.error().code == ErrorCode::line_too_long);
  }
  SECTION("entry count") {
    std::string text;
    for (std::size_t i = 0; i < app::max_entries; ++i) {
      text += "k" + std::to_string(i) + "=v\n";
    }
    CHECK(app::parse_config(text).has_value());
    const auto over = app::parse_config(text + "extra=v\n");
    REQUIRE_FALSE(over.has_value());
    CHECK(over.error().code == ErrorCode::too_many_entries);
  }
  SECTION("total size") {
    const std::string big(app::max_config_bytes + 1, '#');
    const auto result = app::parse_config(big);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == ErrorCode::too_large);
  }
}

TEST_CASE("load_config_file reads a file", "[config][file]") {
  const TempDir dir;
  const auto file = dir.path() / "ok.conf";
  std::ofstream{file} << "x=1\n";
  const auto result = app::load_config_file(file);
  REQUIRE(result.has_value());
  CHECK(result->get("x") == "1");
}

TEST_CASE("load_config_file reports failures", "[config][file]") {
  const TempDir dir;

  SECTION("missing file") {
    const auto result = app::load_config_file(dir.path() / "nope.conf");
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == ErrorCode::file_not_found);
  }
  SECTION("directory instead of file") {
    const auto result = app::load_config_file(dir.path());
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == ErrorCode::not_a_regular_file);
  }
  SECTION("oversized file") {
    const auto file = dir.path() / "big.conf";
    std::ofstream{file} << std::string(app::max_config_bytes + 1, '#');
    const auto result = app::load_config_file(file);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == ErrorCode::too_large);
  }
  SECTION("parse error propagates") {
    const auto file = dir.path() / "bad.conf";
    std::ofstream{file} << "broken\n";
    const auto result = app::load_config_file(file);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == ErrorCode::missing_separator);
  }
}

TEST_CASE("to_string covers every error code", "[config]") {
  for (const auto code : {ErrorCode::file_not_found, ErrorCode::not_a_regular_file,
                          ErrorCode::read_failed, ErrorCode::too_large, ErrorCode::line_too_long,
                          ErrorCode::too_many_entries, ErrorCode::missing_separator,
                          ErrorCode::empty_key, ErrorCode::invalid_key, ErrorCode::duplicate_key}) {
    CHECK_FALSE(app::to_string(code).empty());
    CHECK(app::to_string(code) != "unknown error");
  }
}
