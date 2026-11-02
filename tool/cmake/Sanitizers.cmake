# Optional runtime sanitizers. Nothing here changes a normal build.
#
# Option
#   PROJECT_SANITIZERS  Semicolon-separated list, empty (off) by default.
#                       Allowed: address, undefined, thread.
#                       address;undefined is the usual pair. thread cannot be
#                       combined with address.
#
# Usage in CMakeLists.txt
#   include(Sanitizers)
#   project_set_sanitizers(<target>)    for every target that is built
#
# Instrumentation is per target. UndefinedBehaviorSanitizer is built with
# -fno-sanitize-recover=undefined, so a finding aborts the program and the test
# fails; without that flag it only prints and the test would still pass.
# Supported with GCC and Clang. MSVC is not supported here.

set(PROJECT_SANITIZERS "" CACHE STRING
  "Sanitizers to enable: address, undefined, thread (semicolon-separated); empty is off")

if(PROJECT_SANITIZERS)
  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    message(FATAL_ERROR
      "PROJECT_SANITIZERS is supported with GCC and Clang only "
      "(compiler: ${CMAKE_CXX_COMPILER_ID}).")
  endif()
  set(_allowed address undefined thread)
  foreach(_s IN LISTS PROJECT_SANITIZERS)
    if(NOT _s IN_LIST _allowed)
      message(FATAL_ERROR
        "Unknown sanitizer '${_s}' in PROJECT_SANITIZERS. Use address, undefined, thread.")
    endif()
  endforeach()
  if("thread" IN_LIST PROJECT_SANITIZERS AND "address" IN_LIST PROJECT_SANITIZERS)
    message(FATAL_ERROR "The thread and address sanitizers cannot be combined.")
  endif()
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(WARNING
      "Sanitizers are most useful with CMAKE_BUILD_TYPE=Debug; got '${CMAKE_BUILD_TYPE}'.")
  endif()
endif()

function(project_set_sanitizers target)
  if(NOT PROJECT_SANITIZERS)
    return()
  endif()
  list(JOIN PROJECT_SANITIZERS "," _list)
  set(_flags -fsanitize=${_list} -fno-omit-frame-pointer)
  if("undefined" IN_LIST PROJECT_SANITIZERS)
    list(APPEND _flags -fno-sanitize-recover=undefined)
  endif()
  target_compile_options(${target} PRIVATE ${_flags} -g)
  target_link_options(${target} PRIVATE ${_flags})
endfunction()
