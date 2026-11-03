# Optional API documentation target (Doxygen). Nothing here changes a normal
# build; the target exists only when Doxygen is found.
#
#   doxygen   writes HTML API documentation for internal/ to <build dir>/doxygen/html
#
# Usage in CMakeLists.txt: include(Documentation); project_add_doxygen_target()
# Doxygen comments in the headers use the `///` form. Doxygen warnings (for
# example a broken `\param` name) fail the target; undocumented entities do not.

function(project_add_doxygen_target)
  find_package(Doxygen QUIET)
  if(NOT DOXYGEN_FOUND)
    message(STATUS "Doxygen not found: target 'doxygen' is not created")
    return()
  endif()

  set(DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
  set(DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION_FULL}")
  set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doxygen")
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_WARN_AS_ERROR YES)
  set(DOXYGEN_WARN_IF_UNDOCUMENTED NO)
  set(DOXYGEN_GENERATE_LATEX NO)
  set(DOXYGEN_HAVE_DOT NO)
  set(DOXYGEN_QUIET YES)
  set(DOXYGEN_FILE_PATTERNS "*.hpp")

  doxygen_add_docs(doxygen
    "${PROJECT_SOURCE_DIR}/internal"
    COMMENT "Generating API documentation with Doxygen")
endfunction()
