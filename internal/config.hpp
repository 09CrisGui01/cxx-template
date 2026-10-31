#pragma once

#include <cstddef>
#include <filesystem>
#include <map>
#include <optional>
#include <string>
#include <string_view>

#include "result.hpp"

namespace app {

// Hard limits applied to untrusted configuration input.
inline constexpr std::size_t max_config_bytes = 1024 * 1024;
inline constexpr std::size_t max_line_bytes = 4096;
inline constexpr std::size_t max_entries = 1024;

enum class ErrorCode {
  file_not_found,
  not_a_regular_file,
  read_failed,
  too_large,
  line_too_long,
  too_many_entries,
  missing_separator,
  empty_key,
  invalid_key,
  duplicate_key,
};

struct Error {
  ErrorCode code;
  std::size_t line = 0;  // 1-based; 0 when not tied to a line.
};

[[nodiscard]] std::string_view to_string(ErrorCode code) noexcept;

// Immutable set of key/value pairs.
class Config {
 public:
  [[nodiscard]] std::optional<std::string_view> get(std::string_view key) const;
  [[nodiscard]] std::size_t size() const noexcept { return entries_.size(); }
  [[nodiscard]] const std::map<std::string, std::string, std::less<>>& entries() const noexcept {
    return entries_;
  }

 private:
  friend Result<Config, Error> parse_config(std::string_view text);
  std::map<std::string, std::string, std::less<>> entries_;
};

// Format: one `key=value` per line. Blank lines and lines starting with '#'
// are ignored. Whitespace around key and value is trimmed. Keys may contain
// [A-Za-z0-9_.-]. Duplicate keys are rejected.
[[nodiscard]] Result<Config, Error> parse_config(std::string_view text);

// Reads a regular file (at most max_config_bytes) and parses it.
[[nodiscard]] Result<Config, Error> load_config_file(const std::filesystem::path& path);

}  // namespace app
