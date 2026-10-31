# Per-target portability settings. Usage: project_set_portability(<target>)
#
# MSVC only:
#   /utf-8              source and execution charset UTF-8 (matches GCC/Clang)
#   /Zc:__cplusplus     report the real __cplusplus value
#   NOMINMAX            stop <windows.h> from defining min/max macros
# GCC, Clang (Linux, macOS, BSD) need nothing extra.

function(project_set_portability target)
  if(MSVC)
    target_compile_options(${target} PRIVATE /utf-8 /Zc:__cplusplus)
    target_compile_definitions(${target} PRIVATE NOMINMAX)
  endif()
endfunction()
