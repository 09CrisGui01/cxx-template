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

# Library: all logic lives here so tests link against it.
add_library(app_core STATIC
  internal/config.cpp)
add_library(${PROJECT_NAME}::core ALIAS app_core)
target_include_directories(app_core PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/internal")
target_compile_features(app_core PUBLIC cxx_std_23)
project_set_warnings(app_core)
project_set_portability(app_core)

# Executable: thin wrapper around the library.
add_executable(app internal/main.cpp)
target_link_libraries(app PRIVATE app_core)
target_compile_definitions(app PRIVATE APP_VERSION="${PROJECT_VERSION}")
project_set_warnings(app)
project_set_portability(app)

include(CTest) # defines BUILD_TESTING (default ON)
if(BUILD_TESTING)
  add_subdirectory(test)
endif()
