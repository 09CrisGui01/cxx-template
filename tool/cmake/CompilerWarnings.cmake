# Per-target warning configuration for GCC, Clang and MSVC.
# Usage: project_set_warnings(<target>)
# Honors PROJECT_WARNINGS_AS_ERRORS.

function(project_set_warnings target)
  set(msvc_warnings /W4 /permissive-)
  set(clang_warnings
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion
    -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Woverloaded-virtual
    -Wnull-dereference -Wdouble-promotion -Wformat=2)
  set(gcc_warnings ${clang_warnings}
    -Wduplicated-cond -Wlogical-op -Wuseless-cast)

  if(PROJECT_WARNINGS_AS_ERRORS)
    list(APPEND msvc_warnings /WX)
    list(APPEND clang_warnings -Werror)
    list(APPEND gcc_warnings -Werror)
  endif()

  if(MSVC)
    set(warnings ${msvc_warnings})
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(warnings ${clang_warnings})
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(warnings ${gcc_warnings})
  else()
    message(WARNING "No warning set for compiler '${CMAKE_CXX_COMPILER_ID}'")
    return()
  endif()

  target_compile_options(${target} PRIVATE ${warnings})
endfunction()
