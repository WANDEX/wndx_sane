include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## -- >> pfx: wndx    name: sane::deps    tgt: sane_deps
## -- >> pfx: wndx    name: sane::src     tgt: sane_src
## -- >> pfx: wndx    name: sane::core    tgt: sane_core
## -- >> pfx: wndx    name: sane::dev     tgt: sane_dev
## -- >> pfx: wndx    name: sane          tgt: sane
function(wndx_sane_add_alias lib_pfx lib_name target)
  message(DEBUG ">> pfx: ${lib_pfx}\t name: ${lib_name}\t tgt: ${target}")
  add_library("${lib_pfx}::${lib_name}" ALIAS "${target}")
  set_target_properties("${target}" PROPERTIES EXPORT_NAME "${lib_name}")
endfunction()

## abstracts a lot redundant steps as a modern cmake configuration related to targets/headers.
## create default targets, add PUBLIC library headers, create dev target with compilation opts.
## dev target with strict CXX compilation options for development.
function(wndx_sane_create_targets) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "PFX;LIB;CXX_STD;PHD" # ovk
    "" # mvk
    ${ARGN}
  )
  message(DEBUG "CXX_STD: ${arg_CXX_STD}, PHD: ${arg_PHD}")
  if(arg_UNPARSED_ARGUMENTS)
    message(WARNING "UNPARSED: wndx_sane_create_targets() ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(arg_KEYWORDS_MISSING_VALUES)
    message(WARNING " MISSING: wndx_sane_create_targets() ${arg_KEYWORDS_MISSING_VALUES}")
  endif()
  if(NOT arg_PFX MATCHES "^.+$")
    message(FATAL_ERROR "wndx_sane_create_targets() PFX not provided!")
  endif()
  if(NOT arg_LIB MATCHES "^.+$")
    message(FATAL_ERROR "wndx_sane_create_targets() LIB_NAME_EXPORT not provided!")
  endif()
  if(NOT arg_CXX_STD MATCHES "^cxx_std_..$")
    set(arg_CXX_STD cxx_std_20)
    message(WARNING "wndx_sane_create_targets() CXX_STD not provided => used by default: ${arg_CXX_STD}")
  endif()

  ## sanity checks of the user input: PHD
  set(PHD_w_prefix "")
  set(PHD_is_prefix FALSE)
  cmake_path(APPEND PHD_w_prefix "${CMAKE_CURRENT_SOURCE_DIR}" "${arg_PHD}")
  cmake_path(IS_PREFIX CMAKE_CURRENT_SOURCE_DIR ${PHD_w_prefix} NORMALIZE PHD_is_prefix)
  if(NOT PHD_is_prefix)
    message(FATAL_ERROR "wndx_sane_create_targets() "
      "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}\nNOT A PREFIX OF: ${PHD_w_prefix}"
    )
  endif()
  if(NOT IS_DIRECTORY "${PHD_w_prefix}")
    message(FATAL_ERROR "wndx_sane_create_targets() IS NOT A DIR: ${PHD_w_prefix}")
  endif()

  ## default include dir path for PUBLIC HEADERS - common to all properly configured projects.
  ## => by hard-coding it we enforce proper usage of the header paths relative to default include dir.
  cmake_path(SET CUR_INC_DIR NORMALIZE "${CMAKE_CURRENT_SOURCE_DIR}/include")

  set(WNDX_SANE_HEADERS_LIST "")
  ## this is currently the only way to gather list of files in a directory
  file(GLOB_RECURSE wndx_sane_headers LIST_DIRECTORIES false
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" # FILE_SET TYPE HEADERS requirement!
    "${arg_PHD}/*.h" "${arg_PHD}/*.hh" "${arg_PHD}/*.hpp"
  )
  list(APPEND WNDX_SANE_HEADERS_LIST ${wndx_sane_headers})

  message(DEBUG ">> RELATIVE TO THE CMAKE_CURRENT_SOURCE_DIR LIST OF HEADERS:")
  foreach(fpath ${WNDX_SANE_HEADERS_LIST})
    message(DEBUG ">> ${fpath}")
  endforeach(fpath)

  ## create target base: common to targets inheritance
  add_library(_${arg_LIB}_base INTERFACE)
  target_include_directories(_${arg_LIB}_base INTERFACE
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> # XXX
  )
  target_compile_features(_${arg_LIB}_base INTERFACE ${arg_CXX_STD})

  ## create target deps: for dependencies
  add_library(${arg_LIB}_deps)
  wndx_sane_add_alias(${arg_PFX} ${arg_LIB}::deps ${arg_LIB}_deps)
  target_include_directories(${arg_LIB}_deps PUBLIC
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
  target_sources(${arg_LIB}_deps PUBLIC
    FILE_SET headers TYPE HEADERS
    FILES ${WNDX_SANE_HEADERS_LIST}
  )
  set_target_properties(${arg_LIB}_deps PROPERTIES LINKER_LANGUAGE CXX)
  target_compile_features(${arg_LIB}_deps PUBLIC ${arg_CXX_STD})

  ## create target src: for sources
  add_library(${arg_LIB}_src)
  wndx_sane_add_alias(${arg_PFX} ${arg_LIB}::src ${arg_LIB}_src)
  target_include_directories(${arg_LIB}_src PUBLIC
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
  target_sources(${arg_LIB}_src PUBLIC
    FILE_SET headers TYPE HEADERS
    FILES ${WNDX_SANE_HEADERS_LIST}
  )
  set_target_properties(${arg_LIB}_src PROPERTIES LINKER_LANGUAGE CXX)
  target_compile_features(${arg_LIB}_src PUBLIC ${arg_CXX_STD})

  ## create target core: for dependency inheritance SYSTEM INTERFACE
  add_library(${arg_LIB}_core INTERFACE)
  wndx_sane_add_alias(${arg_PFX} ${arg_LIB}::core ${arg_LIB}_core)
  target_link_libraries(${arg_LIB}_core INTERFACE _${arg_LIB}_base)
  target_include_directories(${arg_LIB}_core SYSTEM INTERFACE
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

  ## create target dev: for options, flags (development) INTERFACE
  add_library(${arg_LIB}_dev INTERFACE)
  wndx_sane_add_alias(${arg_PFX} ${arg_LIB}::dev ${arg_LIB}_dev)
  target_link_libraries(${arg_LIB}_dev INTERFACE _${arg_LIB}_base)
  target_include_directories(${arg_LIB}_dev INTERFACE
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

  ## create umbrella target with all components INTERFACE
  add_library(${arg_LIB} INTERFACE)
  wndx_sane_add_alias(${arg_PFX} ${arg_LIB} ${arg_LIB})
  target_link_libraries(${arg_LIB} INTERFACE ${arg_PFX}::core)

  under_compiler(GNU)
  under_compiler(Clang)
  under_compiler(AppleClang)
  ## here we set flags/options common to our main target compilers
  if(${GNU_COMP} OR ${Clang_COMP} OR ${AppleClang_COMP})

    if(CMAKE_BUILD_TYPE STREQUAL Release)
      target_compile_options(${arg_LIB}_dev INTERFACE -O3)
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
      target_compile_options(${arg_LIB}_dev INTERFACE -g -Og)

      ## This helps to see/fix errors (which MSVC will throw anyway)
      ## => they should be fixed. (it is crucial flag, but has its own cost)
      target_compile_options(${arg_LIB}_dev INTERFACE -D_GLIBCXX_DEBUG)
    endif()

    target_compile_options(${arg_LIB}_dev INTERFACE -Wall -Wextra -Wpedantic -pedantic-errors)

    ## disallow implicit conversions
    ## NOTE: with -Wconversion Clang also enables -Wsign-conversion (GCC not!)
    target_compile_options(${arg_LIB}_dev INTERFACE
      -Wconversion
      -Wsign-conversion
      -Wenum-conversion
      -Wfloat-conversion

      -Wsign-promo
      -Wdouble-promotion
    )

    target_compile_options(${arg_LIB}_dev INTERFACE
      -Wold-style-cast
      -Wundef
      -Wshadow
      -ftrapv
    )

    target_compile_options(${arg_LIB}_dev INTERFACE
      -fdiagnostics-color=always
      -fdiagnostics-show-template-tree
    )

    ## enable this flags depending on the situation / debugging approach
    target_compile_options(${arg_LIB}_dev INTERFACE
      # -Wfatal-errors
    )

    ## credit: https://gavinchou.github.io/experience/summary/syntax/gcc-address-sanitizer/
    ## TODO: remove this if clause as it is not finished!
    if(WNDX_SANE_SNTZ_ADDR)
      message(NOTICE ">> ADDRESS SANITIZER ENABLED")
      target_compile_options(${arg_LIB}_dev INTERFACE
        -ggdb -fno-omit-frame-pointer # call stack and line number report format
        # -fsanitize=address
        # -static-libstdc++
      )
      ## XXX FIXME linker or compile options?
      ## XXX This command cannot be used to add options for static library targets
      ## XXX ???
      target_link_options(${arg_LIB}_dev INTERFACE
        -ggdb -fno-omit-frame-pointer # call stack and line number report format
        -fsanitize=address
        -static-libstdc++
      )
      ## platform specific:
      if(APPLE)
        target_compile_options(${arg_LIB}_dev INTERFACE
          -static-libgcc # macos
        )
      elseif(UNIX)
        ## -lrt, needed by linux shared memory operation: shm_open and shm_unlink
        # target_compile_options(${arg_LIB}_dev INTERFACE
        # target_link_options(${arg_LIB}_dev INTERFACE
        #   -static-libasan -lrt # linux
        # )
      elseif(WIN32)
        # FIXME: what to use here...
        # target_add_check_cxx_compiler_flag(${arg_LIB}_dev /static-libgcc )
      endif()
    endif(WNDX_SANE_SNTZ_ADDR)

  endif()

  if(MSVC)
    ## TODO: mimic all other flags from the targeted compilers
    ## (to have equal warnings between compilers and all environments/platforms)
    target_compile_options(${arg_LIB}_dev INTERFACE /W3 /utf-8)

  else()
    ## ^ (flag is obviously missing in MSVC if flag has leading - sign)
    ## Other flags which may miss in any of the targeted compilers.
    ## Not targeted compilers may have support of the GNU/Clang flags
    ## -> so we check support of the following flags, applying only supported.

    ### following flags are missing in Clang

    target_add_check_cxx_compiler_flag(${arg_LIB}_dev -Warith-conversion )
    target_add_check_cxx_compiler_flag(${arg_LIB}_dev -Wstrict-null-sentinel )
    target_add_check_cxx_compiler_flag(${arg_LIB}_dev -Wzero-as-null-pointer-constant ) # has

    if(${GNU_COMP})
      ## gives many false positives with GCC 13
      ## https://github.com/fmtlib/fmt/issues/3415
      target_add_check_cxx_compiler_flag(${arg_LIB}_dev -Wno-dangling-reference )
    endif()

    ### section for the other flags (may be or may be missing in Clang)
    ### for brevity - flags for the other compilers should be here

  endif()

endfunction()
