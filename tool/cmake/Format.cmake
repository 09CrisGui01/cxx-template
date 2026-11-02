# Optional formatting targets (clang-format). Nothing here changes a normal
# build; the targets exist only when clang-format is found.
#
#   format        rewrites the C++ sources in place
#   format-check  fails if any source differs from the style in .clang-format
#
# Usage in CMakeLists.txt: include(Format); project_add_format_targets()
# The files are the tracked C++ sources under internal/ and test/.

function(project_add_format_targets)
  find_program(PROJECT_CLANG_FORMAT NAMES clang-format)
  if(NOT PROJECT_CLANG_FORMAT)
    message(STATUS "clang-format not found: targets 'format' and 'format-check' are not created")
    return()
  endif()

  file(GLOB _sources CONFIGURE_DEPENDS
    "${PROJECT_SOURCE_DIR}/internal/*.cpp" "${PROJECT_SOURCE_DIR}/internal/*.hpp"
    "${PROJECT_SOURCE_DIR}/test/*.cpp" "${PROJECT_SOURCE_DIR}/test/*.hpp")

  add_custom_target(format
    COMMAND "${PROJECT_CLANG_FORMAT}" -i --style=file ${_sources}
    COMMENT "Formatting sources with clang-format"
    VERBATIM)
  add_custom_target(format-check
    COMMAND "${PROJECT_CLANG_FORMAT}" --dry-run --Werror --style=file ${_sources}
    COMMENT "Checking source formatting with clang-format"
    VERBATIM)
endfunction()
