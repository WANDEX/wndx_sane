## file with CXX compiler options.
##
## vars & funcs defined and come from the funcs.cmake
include(cmake/funcs.cmake) # useful project functions / variables
include(GNUInstallDirs)


function(add_alias name target)
  add_library(wandex::${name} ALIAS ${target})
  set_target_properties(${target} PROPERTIES EXPORT_NAME ${name})
endfunction()

file(REAL_PATH "${CMAKE_CURRENT_SOURCE_DIR}" real_root_of_src_tree)
cmake_path(APPEND wndx_sane_include_rootd "${real_root_of_src_tree}"  "include")
cmake_path(APPEND wndx_sane_include_wndx_sane "${wndx_sane_include_rootd}"      "wndx_sane")

file(GLOB_RECURSE wndx_sane_headers LIST_DIRECTORIES false "${wndx_sane_include_wndx_sane}" *.hpp)

## Base target for common options.
add_library(_wndx_sane_base INTERFACE)
target_include_directories(_wndx_sane_base INTERFACE
  $<BUILD_INTERFACE:${wndx_sane_include_wndx_sane}>
)
target_compile_features(_wndx_sane_base INTERFACE cxx_std_20)


## target for dependencies (link inheritance)
add_library(wndx_sane_deps "")
add_alias(wndx_sane::deps wndx_sane_deps)
target_include_directories(wndx_sane_deps PUBLIC
  $<BUILD_INTERFACE:${wndx_sane_include_wndx_sane}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_sources(wndx_sane_deps PUBLIC ${wndx_sane_headers})
set_target_properties(wndx_sane_deps PROPERTIES LINKER_LANGUAGE CXX)
target_compile_features(wndx_sane_deps PUBLIC cxx_std_20)

## target for src (link inheritance)
add_library(wndx_sane_src  "")
add_alias(wndx_sane::src wndx_sane_src)
target_include_directories(wndx_sane_src PUBLIC
  $<BUILD_INTERFACE:${wndx_sane_include_wndx_sane}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
# target_sources(wndx_sane_src PUBLIC ${wndx_sane_headers})
set_target_properties(wndx_sane_src PROPERTIES LINKER_LANGUAGE CXX)
target_compile_features(wndx_sane_src PUBLIC cxx_std_20)


## Core library.
add_library(wndx_sane_core INTERFACE)
add_alias(wndx_sane::core wndx_sane_core)
target_link_libraries(wndx_sane_core INTERFACE _wndx_sane_base)
target_include_directories(wndx_sane_core SYSTEM INTERFACE
  $<BUILD_INTERFACE:${wndx_sane_include_wndx_sane}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)


## Core library with warnings; for development only.
add_library(wndx_sane_dev INTERFACE)
add_alias(wndx_sane::dev wndx_sane_dev)
target_link_libraries(wndx_sane_dev INTERFACE _wndx_sane_base)
target_include_directories(wndx_sane_dev INTERFACE
  $<BUILD_INTERFACE:${wndx_sane_include_wndx_sane}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)


## here we set flags/options common to our main target compilers
if(${GNU_COMP} OR ${Clang_COMP} OR ${AppleClang_COMP})

  if(CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_options(wndx_sane_dev INTERFACE -O3)
  elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
    target_compile_options(wndx_sane_dev INTERFACE -g -Og)

    ## This helps to see/fix errors (which MSVC will throw anyway)
    ## => they should be fixed. (it is crucial flag, but has its own cost)
    target_compile_options(wndx_sane_dev INTERFACE -D_GLIBCXX_DEBUG)
  endif()

  target_compile_options(wndx_sane_dev INTERFACE -Wall -Wextra -Wpedantic -pedantic-errors)

  ## disallow implicit conversions
  ## NOTE: with -Wconversion Clang also enables -Wsign-conversion (GCC not!)
  target_compile_options(wndx_sane_dev INTERFACE
    -Wconversion
    -Wsign-conversion
    -Wenum-conversion
    -Wfloat-conversion

    -Wsign-promo
    -Wdouble-promotion
  )

  target_compile_options(wndx_sane_dev INTERFACE
    -Wold-style-cast
    -Wundef
    -Wshadow
    -ftrapv # XXX: sane default or delete for the "better"?
  )

  target_compile_options(wndx_sane_dev INTERFACE
    -fdiagnostics-color=always
    -fdiagnostics-show-template-tree
  )

  ## enable this flags depending on the situation / debugging approach
  target_compile_options(wndx_sane_dev INTERFACE
    # -Wfatal-errors
    # -Wno-unused-parameter # XXX
  )

  ## credit: https://gavinchou.github.io/experience/summary/syntax/gcc-address-sanitizer/
  ## TODO: remove this if clause as it is not finished!
  if(WNDX_SANE_SNTZ_ADDR)
    message(NOTICE ">> ADDRESS SANITIZER ENABLED")
    target_compile_options(wndx_sane_dev INTERFACE
      -ggdb -fno-omit-frame-pointer # call stack and line number report format
      # -fsanitize=address
      # -static-libstdc++
    )
    ## XXX FIXME linker or compile options?
    ## XXX This command cannot be used to add options for static library targets
    ## XXX ???
    target_link_options(wndx_sane_dev INTERFACE
      -ggdb -fno-omit-frame-pointer # call stack and line number report format
      -fsanitize=address
      -static-libstdc++
    )
    ## platform specific:
    if(APPLE)
      target_compile_options(wndx_sane_dev INTERFACE
        -static-libgcc # macos
      )
    elseif(UNIX)
      ## -lrt, needed by linux shared memory operation: shm_open and shm_unlink
      # target_compile_options(wndx_sane_dev INTERFACE
      # target_link_options(wndx_sane_dev INTERFACE
      #   -static-libasan -lrt # linux
      # )
    elseif(WIN32)
      # TODO: what to use here...
      target_add_check_cxx_compiler_flag(wndx_sane_dev -static-libgcc ) # XXX works?
    endif()
  endif(WNDX_SANE_SNTZ_ADDR)

endif()

if(MSVC)
  ## TODO: mimic all other flags from the targeted compilers
  ## (to have equal warnings between compilers and all environments/platforms)
  target_compile_options(wndx_sane_dev INTERFACE /W3)

else()
  ## ^ (flag is obviously missing in MSVC if flag has leading - sign)
  ## Other flags which may miss in any of the targeted compilers.
  ## Not targeted compilers may have support of the GNU/Clang flags
  ## -> so we check support of the following flags, applying only supported.

  ### following flags are missing in Clang

  target_add_check_cxx_compiler_flag(wndx_sane_dev -Warith-conversion )
  target_add_check_cxx_compiler_flag(wndx_sane_dev -Wstrict-null-sentinel )
  target_add_check_cxx_compiler_flag(wndx_sane_dev -Wzero-as-null-pointer-constant ) # has

  if(${GNU_COMP})
    ## gives many false positives with GCC 13
    ## https://github.com/fmtlib/fmt/issues/3415
    target_add_check_cxx_compiler_flag(wndx_sane_dev -Wno-dangling-reference )
  endif()

  ### section for the other flags (may be or may be missing in Clang)
  ### for brevity - flags for the other compilers should be here

endif()


## link core target with the libc -lc (to work with the socket API etc.)
# target_link_libraries(wndx_sane_core INTERFACE c)

## link sources with project dependencies from the core library target.
target_link_libraries(wndx_sane_src INTERFACE wandex::wndx_sane::core)

## link sources with project dependencies
target_link_libraries(wndx_sane_src PUBLIC wandex::wndx_sane::deps)

## link sources with project dev interface (for the compilation flags/options)
target_link_libraries(wndx_sane_src PRIVATE wandex::wndx_sane::dev)


## Umbrella target with all components.
add_library(wndx_sane INTERFACE)
add_alias(wndx_sane wndx_sane)
target_link_libraries(wndx_sane INTERFACE wandex::wndx_sane::core)

