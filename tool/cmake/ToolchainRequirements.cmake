# Soft minimum toolchain versions.
#
# A compiler older than its minimum is unsupported, not blocked: configure
# prints a warning and continues. The minimums are the lowest versions this
# project was verified with, rounded down to the minor release; see the
# dependency table in README.md. Override on the command line, for example
#   cmake --preset alpha -DPROJECT_MIN_GNU_VERSION=12.0
# The variable name is PROJECT_MIN_<COMPILER_ID>_VERSION.

set(PROJECT_MIN_GNU_VERSION "13.0" CACHE STRING
  "Soft minimum GCC version")
set(PROJECT_MIN_CLANG_VERSION "18.0" CACHE STRING
  "Soft minimum Clang version (also used for FreeBSD base Clang)")
set(PROJECT_MIN_APPLECLANG_VERSION "17.0" CACHE STRING
  "Soft minimum Apple Clang version (provisional)")
set(PROJECT_MIN_MSVC_VERSION "19.40" CACHE STRING
  "Soft minimum MSVC compiler version (provisional)")
mark_as_advanced(
  PROJECT_MIN_GNU_VERSION PROJECT_MIN_CLANG_VERSION
  PROJECT_MIN_APPLECLANG_VERSION PROJECT_MIN_MSVC_VERSION)

# Always logs the detected C++ compiler (so CI logs record versions), and
# warns when it is below its soft minimum.
function(project_check_toolchain)
  set(id "${CMAKE_CXX_COMPILER_ID}")
  set(version "${CMAKE_CXX_COMPILER_VERSION}")
  string(TOUPPER "${id}" key)

  if(NOT DEFINED PROJECT_MIN_${key}_VERSION)
    message(STATUS "C++ compiler: ${id} ${version} (no minimum defined for this compiler)")
    return()
  endif()

  set(minimum "${PROJECT_MIN_${key}_VERSION}")
  if(version VERSION_LESS minimum)
    message(WARNING
      "C++ compiler ${id} ${version} is below the soft minimum ${minimum}. "
      "The build continues, but this compiler is unsupported and untested. "
      "See the dependency table in README.md.")
  else()
    message(STATUS "C++ compiler: ${id} ${version} (soft minimum ${minimum})")
  endif()
endfunction()
