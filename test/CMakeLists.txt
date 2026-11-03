# Test dependency: Catch2 v3. Use the Git submodule in external/Catch2 when it
# is checked out; otherwise use an installed Catch2 3.3 or newer (the container
# images do this). See
# documentation/architecture/decisions/0014-third-party-libraries-as-submodules.md.
set(_catch2_dir "${PROJECT_SOURCE_DIR}/external/Catch2")
if(EXISTS "${_catch2_dir}/CMakeLists.txt")
  add_subdirectory("${_catch2_dir}" "${CMAKE_BINARY_DIR}/external/Catch2" SYSTEM)
  list(APPEND CMAKE_MODULE_PATH "${_catch2_dir}/extras")
else()
  find_package(Catch2 3.3 QUIET)
  if(NOT Catch2_FOUND)
    message(FATAL_ERROR
      "Catch2 was not found. Run 'git submodule update --init --recursive', "
      "or install Catch2 3.3 or newer, or configure with -DBUILD_TESTING=OFF.")
  endif()
endif()
include(Catch)

add_executable(app_tests config_test.cpp log_test.cpp)
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

# Logging: messages go to standard error, and the level comes from the
# environment variable or the configuration file. CTest matches the pass
# expression against standard output and standard error together.
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/debug.conf" "log.level = debug\n")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/bad-level.conf" "log.level = loud\n")

add_test(NAME app.logs_info_from_configuration COMMAND app "${sample_conf}")
set_tests_properties(app.logs_info_from_configuration PROPERTIES PASS_REGULAR_EXPRESSION
  "\\[info\\] configuration loaded: 2 entries")

add_test(NAME app.environment_level_overrides_configuration COMMAND app "${sample_conf}")
set_tests_properties(app.environment_level_overrides_configuration PROPERTIES
  ENVIRONMENT "APP_LOG_LEVEL=off"
  FAIL_REGULAR_EXPRESSION "configuration loaded")

add_test(NAME app.environment_enables_debug_logging COMMAND app "${CMAKE_CURRENT_BINARY_DIR}/debug.conf")
set_tests_properties(app.environment_enables_debug_logging PROPERTIES
  ENVIRONMENT "APP_LOG_LEVEL=debug"
  PASS_REGULAR_EXPRESSION "\\[debug\\] config: parsed 1 entries")

add_test(NAME app.warns_about_invalid_environment_level COMMAND app "${sample_conf}")
set_tests_properties(app.warns_about_invalid_environment_level PROPERTIES
  ENVIRONMENT "APP_LOG_LEVEL=loud"
  PASS_REGULAR_EXPRESSION "\\[warning\\] ignoring invalid APP_LOG_LEVEL='loud'")

add_test(NAME app.rejects_invalid_configuration_level COMMAND app "${CMAKE_CURRENT_BINARY_DIR}/bad-level.conf")
set_tests_properties(app.rejects_invalid_configuration_level PROPERTIES WILL_FAIL TRUE)
