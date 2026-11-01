# Version stage tag and build metadata. Documentation-only information: no
# program logic depends on it, but it can be determined from CMake variables,
# compile definitions and the `--version` flag of the application.
#
# Inputs
#   PROJECT_VERSION         numeric X.Y.Z from project(VERSION ...)
#   PROJECT_VERSION_TAG     alpha, beta, gamma, or empty for a final release.
#                           Must be defined before include(Version). Override
#                           with -DPROJECT_VERSION_TAG=<tag> (empty allowed).
#   PROJECT_BUILD_PRESET    configure preset name; set by CMakePresets.json,
#                           "none" when absent
# Outputs (normal variables in the including scope)
#   PROJECT_VERSION_TAGGED    X.Y.Z-TAG, or X.Y.Z for a final release
#   PROJECT_VERSION_METADATA  <timestamp>.<build-preset>.<os>.<architecture>.<toolchain>
#   PROJECT_VERSION_FULL      <TAGGED>+<METADATA>
#
# The timestamp is the UTC configure date (YYYYMMDD: year, month, day). string(TIMESTAMP)
# honors the SOURCE_DATE_EPOCH environment variable, so builds can be made
# reproducible. Every metadata field is limited to [0-9A-Za-z-]; other
# characters become '-', so the metadata always has exactly five fields.

set(_project_version_tags alpha beta gamma)

if(NOT DEFINED PROJECT_VERSION_TAG)
  message(FATAL_ERROR "PROJECT_VERSION_TAG must be defined before include(Version)")
endif()
if(NOT PROJECT_VERSION_TAG STREQUAL "" AND NOT PROJECT_VERSION_TAG IN_LIST _project_version_tags)
  message(FATAL_ERROR
    "PROJECT_VERSION_TAG='${PROJECT_VERSION_TAG}' is invalid. "
    "Use one of: ${_project_version_tags}; or empty for a final release.")
endif()

function(_project_identifier out value fallback)
  string(REGEX REPLACE "[^0-9A-Za-z-]" "-" id "${value}")
  if(id STREQUAL "")
    set(id "${fallback}")
  endif()
  set(${out} "${id}" PARENT_SCOPE)
endfunction()

if(NOT DEFINED PROJECT_BUILD_PRESET OR PROJECT_BUILD_PRESET STREQUAL "")
  set(PROJECT_BUILD_PRESET "none")
endif()

string(TIMESTAMP _project_timestamp "%Y%m%d" UTC)
_project_identifier(_project_preset "${PROJECT_BUILD_PRESET}" "none")
_project_identifier(_project_os "${CMAKE_SYSTEM_NAME}" "unknown")
_project_identifier(_project_arch "${CMAKE_SYSTEM_PROCESSOR}" "unknown")
_project_identifier(_project_toolchain
  "${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}" "unknown")

set(PROJECT_VERSION_METADATA
  "${_project_timestamp}.${_project_preset}.${_project_os}.${_project_arch}.${_project_toolchain}")

set(_id "[0-9A-Za-z-]+")
if(NOT PROJECT_VERSION_METADATA MATCHES "^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\.${_id}\\.${_id}\\.${_id}\\.${_id}$")
  message(FATAL_ERROR "Invalid version metadata: '${PROJECT_VERSION_METADATA}'")
endif()

if(PROJECT_VERSION_TAG STREQUAL "")
  set(PROJECT_VERSION_TAGGED "${PROJECT_VERSION}")
else()
  set(PROJECT_VERSION_TAGGED "${PROJECT_VERSION}-${PROJECT_VERSION_TAG}")
endif()
set(PROJECT_VERSION_FULL "${PROJECT_VERSION_TAGGED}+${PROJECT_VERSION_METADATA}")

message(STATUS "Version: ${PROJECT_VERSION_FULL}")
