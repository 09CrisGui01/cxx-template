#pragma once

#include <utility>
#include <variant>

namespace app {

/// Minimal value-or-error type.
///
/// Why not std::expected: Clang 18 with libstdc++ 13 (the Ubuntu 24.04
/// toolchain, also used by clang-tidy 18) does not provide it. Replace this
/// type with std::expected<T, E> once every supported toolchain has it; the
/// interface below is a deliberate subset of it.
template <typename E>
struct Failure {
  E error;
};

template <typename E>
Failure(E) -> Failure<E>;

template <typename T, typename E>
class [[nodiscard]] Result {
 public:
  Result(T value) : data_(std::in_place_index<0>, std::move(value)) {}
  Result(Failure<E> failure) : data_(std::in_place_index<1>, std::move(failure.error)) {}

  [[nodiscard]] bool has_value() const noexcept { return data_.index() == 0; }
  [[nodiscard]] explicit operator bool() const noexcept { return has_value(); }

  /// Precondition for the accessors below: has_value() (value) or
  /// !has_value() (error). std::get throws std::bad_variant_access otherwise.
  [[nodiscard]] const T& operator*() const { return std::get<0>(data_); }
  [[nodiscard]] const T* operator->() const { return &std::get<0>(data_); }
  [[nodiscard]] const E& error() const { return std::get<1>(data_); }

 private:
  std::variant<T, E> data_;
};

}  // namespace app
