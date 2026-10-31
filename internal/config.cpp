#include "config.hpp"

#include <algorithm>
#include <fstream>
#include <iterator>
#include <system_error>

namespace app {

namespace {

constexpr std::string_view whitespace = " \t\r";

std::string_view trim(std::string_view s) noexcept {
  const auto first = s.find_first_not_of(whitespace);
  if (first == std::string_view::npos) {
    return {};
  }
  const auto last = s.find_last_not_of(whitespace);
  return s.substr(first, last - first + 1);
}

bool is_valid_key(std::string_view key) noexcept {
  return std::ranges::all_of(key, [](char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') ||
           c == '_' || c == '.' || c == '-';
  });
}

}  // namespace

std::string_view to_string(ErrorCode code) noexcept {
  switch (code) {
    case ErrorCode::file_not_found: return "file not found";
    case ErrorCode::not_a_regular_file: return "not a regular file";
    case ErrorCode::read_failed: return "read failed";
    case ErrorCode::too_large: return "input too large";
    case ErrorCode::line_too_long: return "line too long";
    case ErrorCode::too_many_entries: return "too many entries";
    case ErrorCode::missing_separator: return "missing '=' separator";
    case ErrorCode::empty_key: return "empty key";
    case ErrorCode::invalid_key: return "invalid character in key";
    case ErrorCode::duplicate_key: return "duplicate key";
  }
  return "unknown error";
}

std::optional<std::string_view> Config::get(std::string_view key) const {
  const auto it = entries_.find(key);
  if (it == entries_.end()) {
    return std::nullopt;
  }
  return std::string_view{it->second};
}

std::expected<Config, Error> parse_config(std::string_view text) {
  if (text.size() > max_config_bytes) {
    return std::unexpected(Error{ErrorCode::too_large, 0});
  }

  Config config;
  std::size_t line_number = 0;
  while (!text.empty()) {
    ++line_number;
    const auto newline = text.find('\n');
    const std::string_view raw = text.substr(0, newline);
    text = (newline == std::string_view::npos) ? std::string_view{} : text.substr(newline + 1);

    if (raw.size() > max_line_bytes) {
      return std::unexpected(Error{ErrorCode::line_too_long, line_number});
    }

    const std::string_view line = trim(raw);
    if (line.empty() || line.front() == '#') {
      continue;
    }

    const auto separator = line.find('=');
    if (separator == std::string_view::npos) {
      return std::unexpected(Error{ErrorCode::missing_separator, line_number});
    }

    const std::string_view key = trim(line.substr(0, separator));
    const std::string_view value = trim(line.substr(separator + 1));
    if (key.empty()) {
      return std::unexpected(Error{ErrorCode::empty_key, line_number});
    }
    if (!is_valid_key(key)) {
      return std::unexpected(Error{ErrorCode::invalid_key, line_number});
    }
    if (config.entries_.size() >= max_entries) {
      return std::unexpected(Error{ErrorCode::too_many_entries, line_number});
    }
    const auto [it, inserted] = config.entries_.try_emplace(std::string{key}, value);
    if (!inserted) {
      return std::unexpected(Error{ErrorCode::duplicate_key, line_number});
    }
  }
  return config;
}

std::expected<Config, Error> load_config_file(const std::filesystem::path& path) {
  std::error_code ec;
  const auto status = std::filesystem::status(path, ec);
  if (ec || !std::filesystem::exists(status)) {
    return std::unexpected(Error{ErrorCode::file_not_found, 0});
  }
  if (!std::filesystem::is_regular_file(status)) {
    return std::unexpected(Error{ErrorCode::not_a_regular_file, 0});
  }
  const auto size = std::filesystem::file_size(path, ec);
  if (ec) {
    return std::unexpected(Error{ErrorCode::read_failed, 0});
  }
  if (size > max_config_bytes) {
    return std::unexpected(Error{ErrorCode::too_large, 0});
  }

  std::ifstream in{path, std::ios::binary};
  if (!in) {
    return std::unexpected(Error{ErrorCode::read_failed, 0});
  }
  // The size check above can race with writers; the parser re-checks the
  // limit on the bytes actually read, so the bound holds regardless.
  std::string text{std::istreambuf_iterator<char>{in}, std::istreambuf_iterator<char>{}};
  if (in.bad()) {
    return std::unexpected(Error{ErrorCode::read_failed, 0});
  }
  return parse_config(text);
}

}  // namespace app
