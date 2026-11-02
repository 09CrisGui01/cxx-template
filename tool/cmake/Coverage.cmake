# Optional code coverage. Nothing here changes a normal build.
#
# Option
#   PROJECT_ENABLE_COVERAGE    OFF by default. When ON, targets that call
#                              project_set_coverage() are instrumented and the
#                              `coverage` target is created.
#   PROJECT_COVERAGE_MIN_LINE  Minimum line coverage in percent that the
#                              `coverage` target enforces. 0 (the default)
#                              disables the check.
#
# Toolchains
#   GCC               --coverage instrumentation; report with gcov and gcovr
#                     (terminal summary, HTML, Cobertura XML).
#   Clang, AppleClang source-based instrumentation (-fprofile-instr-generate
#                     -fcoverage-mapping); report with llvm-profdata and llvm-cov
#                     (terminal summary, HTML, LCOV).
#   MSVC              not supported: configuring with coverage enabled fails.
#
# Usage in CMakeLists.txt
#   include(Coverage)
#   project_set_coverage(<target>)            for every instrumented target
#   project_add_coverage_target(OBJECTS <target>...)   once, after all targets
#
# The report is produced by tool/cmake/RunCoverage.cmake, run as a CMake script,
# so it works the same on every host that has the report tools.

option(PROJECT_ENABLE_COVERAGE "Instrument targets for code coverage" OFF)
set(PROJECT_COVERAGE_MIN_LINE "0" CACHE STRING
  "Minimum line coverage percent enforced by the coverage target; 0 disables the check")

set(_coverage_dir "${CMAKE_CURRENT_LIST_DIR}")

if(PROJECT_ENABLE_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(PROJECT_COVERAGE_MODE gcov)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(PROJECT_COVERAGE_MODE llvm)
  else()
    message(FATAL_ERROR
      "PROJECT_ENABLE_COVERAGE is supported with GCC and Clang only "
      "(compiler: ${CMAKE_CXX_COMPILER_ID}).")
  endif()
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(WARNING
      "Coverage is most accurate with CMAKE_BUILD_TYPE=Debug; "
      "got '${CMAKE_BUILD_TYPE}'. Optimization merges and removes lines.")
  endif()
endif()

# Per-target instrumentation. No-op unless PROJECT_ENABLE_COVERAGE is ON.
function(project_set_coverage target)
  if(NOT PROJECT_ENABLE_COVERAGE)
    return()
  endif()
  if(PROJECT_COVERAGE_MODE STREQUAL "gcov")
    target_compile_options(${target} PRIVATE --coverage -O0 -g)
    target_link_options(${target} PRIVATE --coverage)
  else()
    target_compile_options(${target} PRIVATE
      -fprofile-instr-generate -fcoverage-mapping -O0 -g)
    target_link_options(${target} PRIVATE -fprofile-instr-generate)
  endif()
endfunction()

# Creates the `coverage` target: run CTest, then write the reports to
# <build dir>/coverage/. OBJECTS are the instrumented executables.
function(project_add_coverage_target)
  cmake_parse_arguments(ARG "" "" "OBJECTS" ${ARGN})
  if(NOT PROJECT_ENABLE_COVERAGE)
    return()
  endif()
  # BUILD_TESTING is defined by include(CTest), which runs after this module.
  if(NOT BUILD_TESTING)
    message(FATAL_ERROR "PROJECT_ENABLE_COVERAGE requires BUILD_TESTING=ON.")
  endif()

  set(_missing "")
  if(PROJECT_COVERAGE_MODE STREQUAL "gcov")
    string(REGEX MATCH "^[0-9]+" _major "${CMAKE_CXX_COMPILER_VERSION}")
    find_program(PROJECT_GCOVR gcovr)
    find_program(PROJECT_GCOV NAMES gcov-${_major} gcov)
    if(NOT PROJECT_GCOVR)
      list(APPEND _missing gcovr)
    endif()
    if(NOT PROJECT_GCOV)
      list(APPEND _missing gcov)
    endif()
    set(_tool_args -DGCOVR=${PROJECT_GCOVR} -DGCOV=${PROJECT_GCOV})
  else()
    string(REGEX MATCH "^[0-9]+" _major "${CMAKE_CXX_COMPILER_VERSION}")
    find_program(PROJECT_LLVM_COV NAMES llvm-cov-${_major} llvm-cov)
    find_program(PROJECT_LLVM_PROFDATA NAMES llvm-profdata-${_major} llvm-profdata)
    if(NOT PROJECT_LLVM_COV)
      list(APPEND _missing llvm-cov)
    endif()
    if(NOT PROJECT_LLVM_PROFDATA)
      list(APPEND _missing llvm-profdata)
    endif()
    set(_tool_args
      -DLLVM_COV=${PROJECT_LLVM_COV} -DLLVM_PROFDATA=${PROJECT_LLVM_PROFDATA})
  endif()

  if(_missing)
    message(WARNING
      "Coverage report tools not found: ${_missing}. Targets are instrumented, "
      "but the 'coverage' target is not created. See documentation/testing/coverage.md.")
    return()
  endif()

  set(_objects "")
  foreach(_t IN LISTS ARG_OBJECTS)
    if(_objects)
      string(APPEND _objects "$<SEMICOLON>")
    endif()
    string(APPEND _objects "$<TARGET_FILE:${_t}>")
  endforeach()

  add_custom_target(coverage
    COMMAND ${CMAKE_COMMAND}
      -DMODE=${PROJECT_COVERAGE_MODE}
      -DSOURCE_DIR=${PROJECT_SOURCE_DIR}
      -DBINARY_DIR=${PROJECT_BINARY_DIR}
      -DOUT_DIR=${PROJECT_BINARY_DIR}/coverage
      -DCTEST=${CMAKE_CTEST_COMMAND}
      -DMIN_LINE=${PROJECT_COVERAGE_MIN_LINE}
      "-DOBJECTS=${_objects}"
      ${_tool_args}
      -P "${_coverage_dir}/RunCoverage.cmake"
    DEPENDS ${ARG_OBJECTS}
    COMMENT "Running tests and writing the coverage report"
    USES_TERMINAL VERBATIM)
endfunction()
