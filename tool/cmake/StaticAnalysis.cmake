# Optional static analysis with clang-tidy. Nothing here changes a normal build.
#
# Option
#   PROJECT_ENABLE_CLANG_TIDY  OFF by default. When ON, clang-tidy runs on every
#                              target that calls project_set_static_analysis(),
#                              as part of compiling it. Configuration is in
#                              .clang-tidy (and test/.clang-tidy). Findings are
#                              errors, so a build with the option ON fails on
#                              any finding.
#
# Usage in CMakeLists.txt
#   include(StaticAnalysis)
#   project_set_static_analysis(<target>)
#
# Works with GCC and Clang as the compiler; clang-tidy parses the sources with
# its own Clang front end. Not supported with MSVC here (untested).

option(PROJECT_ENABLE_CLANG_TIDY "Run clang-tidy while compiling" OFF)

if(PROJECT_ENABLE_CLANG_TIDY)
  find_program(PROJECT_CLANG_TIDY NAMES clang-tidy)
  if(NOT PROJECT_CLANG_TIDY)
    message(FATAL_ERROR "PROJECT_ENABLE_CLANG_TIDY=ON but clang-tidy was not found.")
  endif()
endif()

function(project_set_static_analysis target)
  if(NOT PROJECT_ENABLE_CLANG_TIDY)
    return()
  endif()
  # --extra-arg: a GCC build passes GCC-only warning flags that clang-tidy
  # does not know; ignore them instead of failing on them.
  # --header-filter: report findings only in this project's own headers, not
  # in Catch2 or the standard library.
  set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY
    "${PROJECT_CLANG_TIDY};--header-filter=^${PROJECT_SOURCE_DIR}/internal/;--extra-arg=-Wno-unknown-warning-option;--extra-arg=-Wno-unused-command-line-argument")
endfunction()
