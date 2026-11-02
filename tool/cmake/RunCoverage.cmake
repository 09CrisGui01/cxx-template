# Runs the tests and writes coverage reports. Invoked by the `coverage` target
# as `cmake -P RunCoverage.cmake` with these variables (see Coverage.cmake):
#   MODE         gcov (GCC) or llvm (Clang)
#   SOURCE_DIR   repository root
#   BINARY_DIR   build directory
#   OUT_DIR      report directory, <build dir>/coverage; deleted first
#   CTEST        path to ctest
#   MIN_LINE     minimum line coverage percent; 0 disables the check
#   OBJECTS      instrumented executables (list)
#   GCOVR, GCOV                  (MODE gcov)
#   LLVM_COV, LLVM_PROFDATA      (MODE llvm)
#
# Outputs
#   gcov: <OUT_DIR>/html/index.html, <OUT_DIR>/cobertura.xml
#   llvm: <OUT_DIR>/html/index.html, <OUT_DIR>/lcov.info
# Only sources under internal/ are reported; test/, third-party and system
# code are excluded.

cmake_minimum_required(VERSION 3.25)

foreach(_v MODE SOURCE_DIR BINARY_DIR OUT_DIR CTEST OBJECTS)
  if(NOT DEFINED ${_v})
    message(FATAL_ERROR "RunCoverage.cmake: ${_v} is not set")
  endif()
endforeach()
if(NOT DEFINED MIN_LINE OR MIN_LINE STREQUAL "")
  set(MIN_LINE 0)
endif()

function(_run)
  execute_process(COMMAND ${ARGN} RESULT_VARIABLE _rc)
  if(NOT _rc EQUAL 0)
    string(REPLACE ";" " " _cmd "${ARGN}")
    message(FATAL_ERROR "Command failed (${_rc}): ${_cmd}")
  endif()
endfunction()

file(REMOVE_RECURSE "${OUT_DIR}")
file(MAKE_DIRECTORY "${OUT_DIR}/html")

if(MODE STREQUAL "gcov")
  # Stale counters from an earlier run would be merged into this one.
  file(GLOB_RECURSE _stale "${BINARY_DIR}/*.gcda")
  if(_stale)
    file(REMOVE ${_stale})
  endif()

  _run("${CTEST}" --test-dir "${BINARY_DIR}" --output-on-failure)

  set(_fail)
  if(MIN_LINE GREATER 0)
    set(_fail --fail-under-line ${MIN_LINE})
  endif()
  execute_process(
    COMMAND "${GCOVR}"
      --root "${SOURCE_DIR}"
      --object-directory "${BINARY_DIR}"
      --gcov-executable "${GCOV}"
      --filter "${SOURCE_DIR}/internal/"
      --txt --print-summary
      --html-details "${OUT_DIR}/html/index.html"
      --cobertura "${OUT_DIR}/cobertura.xml"
      ${_fail}
    RESULT_VARIABLE _rc)
  if(NOT _rc EQUAL 0)
    message(FATAL_ERROR
      "gcovr failed (${_rc}); with MIN_LINE=${MIN_LINE} this can mean the "
      "line coverage is below the minimum. Reports are in ${OUT_DIR}.")
  endif()

elseif(MODE STREQUAL "llvm")
  set(_raw "${OUT_DIR}/raw")
  file(MAKE_DIRECTORY "${_raw}")
  # %p = process id, %m = binary signature: parallel and repeated runs write
  # separate files that llvm-profdata merges.
  set(ENV{LLVM_PROFILE_FILE} "${_raw}/%p-%m.profraw")
  _run("${CTEST}" --test-dir "${BINARY_DIR}" --output-on-failure)

  file(GLOB _profraw "${_raw}/*.profraw")
  if(NOT _profraw)
    message(FATAL_ERROR "No .profraw files were written to ${_raw}")
  endif()
  set(_profdata "${OUT_DIR}/coverage.profdata")
  _run("${LLVM_PROFDATA}" merge -sparse ${_profraw} -o "${_profdata}")

  list(GET OBJECTS 0 _first)
  set(_objargs "${_first}")
  list(SUBLIST OBJECTS 1 -1 _rest)
  foreach(_o IN LISTS _rest)
    list(APPEND _objargs -object "${_o}")
  endforeach()
  # Report only this project's sources under internal/, as the gcov path does.
  file(GLOB _sources "${SOURCE_DIR}/internal/*.cpp" "${SOURCE_DIR}/internal/*.hpp")
  set(_common -instr-profile=${_profdata})
  set(_sourceargs ${_sources})

  _run("${LLVM_COV}" report ${_objargs} ${_common} ${_sourceargs})
  _run("${LLVM_COV}" show ${_objargs} ${_common} ${_sourceargs}
    -format=html -output-dir=${OUT_DIR}/html)
  execute_process(
    COMMAND "${LLVM_COV}" export ${_objargs} ${_common} ${_sourceargs} -format=lcov
    OUTPUT_FILE "${OUT_DIR}/lcov.info" RESULT_VARIABLE _rc)
  if(NOT _rc EQUAL 0)
    message(FATAL_ERROR "llvm-cov export (lcov) failed (${_rc})")
  endif()

  if(MIN_LINE GREATER 0)
    execute_process(
      COMMAND "${LLVM_COV}" export ${_objargs} ${_common} ${_sourceargs} -summary-only
      OUTPUT_VARIABLE _json RESULT_VARIABLE _rc)
    if(NOT _rc EQUAL 0)
      message(FATAL_ERROR "llvm-cov export (summary) failed (${_rc})")
    endif()
    string(JSON _pct GET "${_json}" data 0 totals lines percent)
    string(REGEX REPLACE "(\\.[0-9][0-9])[0-9]*$" "\\1" _pct "${_pct}")
    message(STATUS "Line coverage: ${_pct}% (minimum ${MIN_LINE}%)")
    if(_pct LESS MIN_LINE)
      message(FATAL_ERROR
        "Line coverage ${_pct}% is below the minimum ${MIN_LINE}%. "
        "Reports are in ${OUT_DIR}.")
    endif()
  endif()

else()
  message(FATAL_ERROR "RunCoverage.cmake: unknown MODE '${MODE}'")
endif()

message(STATUS "Coverage reports written to ${OUT_DIR}")
