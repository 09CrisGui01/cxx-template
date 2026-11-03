cmake_minimum_required(VERSION 3.25)

project(cpp23_template
  VERSION 0.1.0
  DESCRIPTION "Reusable C++23 application template"
  LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tool/cmake")

# Single-config generators default to Debug-less builds; make Release explicit.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(PROJECT_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

include(CompilerWarnings)
include(Portability)
include(Coverage)
include(Documentation)
include(Format)
include(StaticAnalysis)
include(Sanitizers)
include(ToolchainRequirements)

project_check_toolchain()

# Stage of the current development: alpha, beta, gamma, or empty for a final
# release. Override with -DPROJECT_VERSION_TAG=<tag>.
if(NOT DEFINED PROJECT_VERSION_TAG)
  set(PROJECT_VERSION_TAG alpha)
endif()
include(Version)

# Logging dependency: spdlog. Use the Git submodule in external/spdlog when it
# is checked out; otherwise use an installed spdlog (the container images do
# this). See documentation/architecture/decisions/0014-third-party-libraries-as-submodules.md.
set(_spdlog_dir "${CMAKE_CURRENT_SOURCE_DIR}/external/spdlog")
if(EXISTS "${_spdlog_dir}/CMakeLists.txt")
  add_subdirectory("${_spdlog_dir}" "${CMAKE_BINARY_DIR}/external/spdlog" SYSTEM)
else()
  find_package(spdlog 1.12 QUIET)
  if(NOT spdlog_FOUND)
    message(FATAL_ERROR
      "spdlog was not found. Run 'git submodule update --init --recursive', "
      "or install spdlog 1.12 or newer.")
  endif()
endif()

# Library: all logic lives here so tests link against it.
add_library(app_core STATIC
  internal/config.cpp
  internal/log.cpp)
add_library(${PROJECT_NAME}::core ALIAS app_core)
target_include_directories(app_core PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/internal")
target_compile_features(app_core PUBLIC cxx_std_23)
target_link_libraries(app_core PUBLIC spdlog::spdlog)
project_set_warnings(app_core)
project_set_portability(app_core)
project_set_coverage(app_core)
project_set_static_analysis(app_core)
project_set_sanitizers(app_core)

# Executable: thin wrapper around the library.
add_executable(app internal/main.cpp)
target_link_libraries(app PRIVATE app_core)
target_compile_definitions(app PRIVATE
  APP_VERSION="${PROJECT_VERSION}"
  APP_VERSION_TAG="${PROJECT_VERSION_TAG}"
  APP_VERSION_METADATA="${PROJECT_VERSION_METADATA}"
  APP_VERSION_FULL="${PROJECT_VERSION_FULL}")
project_set_warnings(app)
project_set_portability(app)
project_set_coverage(app)
project_set_static_analysis(app)
project_set_sanitizers(app)

# Installation: the executable and the sample configuration. The runtime
# container image is built from this install tree (see Dockerfile).
include(GNUInstallDirs)
install(TARGETS app RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES configuration/default.conf
  DESTINATION "${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}")

include(CTest) # defines BUILD_TESTING (default ON)
if(BUILD_TESTING)
  add_subdirectory(test)
endif()

project_add_coverage_target(OBJECTS app app_tests)
project_add_format_targets()
project_add_doxygen_target()
