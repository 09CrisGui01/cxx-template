# Test dependency: Catch2 v3. Prefer a system install; otherwise fetch a pinned
# release. Fetching needs network access on first configure; see the
# dependency table in README.md and documentation/architecture/decisions/0002-catch2-test-framework.md.
find_package(Catch2 3.3 QUIET)
if(NOT Catch2_FOUND)
  include(FetchContent)
  FetchContent_Declare(Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.7.1
    GIT_SHALLOW    TRUE
    SYSTEM)
  FetchContent_MakeAvailable(Catch2)
  list(APPEND CMAKE_MODULE_PATH "${catch2_SOURCE_DIR}/extras")
endif()
include(Catch)

add_executable(app_tests config_test.cpp)
target_link_libraries(app_tests PRIVATE app_core Catch2::Catch2WithMain)
project_set_warnings(app_tests)
project_set_portability(app_tests)
project_set_coverage(app_tests)
project_set_static_analysis(app_tests)
project_set_sanitizers(app_tests)

# Each Catch2 test case becomes its own CTest test.
catch_discover_tests(app_tests)

# Integration tests: run the real executable against real files.
set(sample_conf "${PROJECT_SOURCE_DIR}/configuration/default.conf")

add_test(NAME app.runs_without_arguments COMMAND app)
add_test(NAME app.loads_sample_configuration COMMAND app "${sample_conf}")
set_tests_properties(app.loads_sample_configuration PROPERTIES
  PASS_REGULAR_EXPRESSION "loaded 2 entries")

# --version prints X.Y.Z[-TAG]+<timestamp>.<preset>.<os>.<arch>.<toolchain>.
string(REPLACE "." "\\." version_re "${PROJECT_VERSION}")
if(PROJECT_VERSION_TAG)
  set(tag_re "-${PROJECT_VERSION_TAG}")
else()
  set(tag_re "")
endif()
set(id_re "[0-9A-Za-z-]+")
add_test(NAME app.prints_full_version COMMAND app --version)
set_tests_properties(app.prints_full_version PROPERTIES PASS_REGULAR_EXPRESSION
  "^${version_re}${tag_re}\\+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\.${id_re}\\.${id_re}\\.${id_re}\\.${id_re}")

add_test(NAME app.rejects_missing_file COMMAND app "${CMAKE_CURRENT_BINARY_DIR}/does-not-exist.conf")
set_tests_properties(app.rejects_missing_file PROPERTIES WILL_FAIL TRUE)

# A parse error must name its line. The file is written at configure time into
# the build tree, so no tracked fixture is needed. CTest ignores the exit status
# when a pass regular expression is set; the failure exit status is covered by
# app.rejects_missing_file.
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/invalid.conf" "name=value\nthis line has no separator\n")
add_test(NAME app.reports_line_of_parse_error COMMAND app "${CMAKE_CURRENT_BINARY_DIR}/invalid.conf")
set_tests_properties(app.reports_line_of_parse_error PROPERTIES PASS_REGULAR_EXPRESSION
  "error: missing '=' separator \\(line 2\\)")

add_test(NAME app.rejects_extra_arguments COMMAND app one two)
set_tests_properties(app.rejects_extra_arguments PROPERTIES WILL_FAIL TRUE)
