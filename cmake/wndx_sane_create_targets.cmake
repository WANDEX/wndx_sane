include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## wndx_sane_under_compiler()
## wndx_sane_tgt_add_check_cxx_compiler_flag()
include(wndx_sane_funcs)

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
    "HFILES" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_create_targets()")

  ## optional HEADER FILES list
  if(NOT arg_HFILES OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*HFILES.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "HFILES")
    unset(arg_HFILES) # unset as arg "" is also not acceptable!
  endif()

  message(DEBUG "${fun} CXX_STD: ${arg_CXX_STD}, PHD: ${arg_PHD}")

  if(arg_UNPARSED_ARGUMENTS)
    message(WARNING "UNPARSED: ${fun} ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(arg_KEYWORDS_MISSING_VALUES)
    message(WARNING " MISSING: ${fun} ${arg_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT arg_PFX MATCHES "^.+$")
    message(FATAL_ERROR "${fun} PFX not provided!")
  endif()
  if(NOT arg_LIB MATCHES "^.+$")
    message(FATAL_ERROR "${fun} LIB_NAME_EXPORT not provided!")
  endif()
  if(NOT arg_CXX_STD MATCHES "^cxx_std_..$")
    set(arg_CXX_STD cxx_std_20)
    message(WARNING "${fun} CXX_STD not provided => used by default: ${arg_CXX_STD}")
  endif()

  ## default include dir path for PUBLIC HEADERS - common to all properly configured projects.
  ## => by hard-coding it we enforce proper usage of the header paths relative to default include dir.
  cmake_path(SET CUR_INC_DIR NORMALIZE "${CMAKE_CURRENT_SOURCE_DIR}/include")

  ## sanity checks of the user input: PHD
  set(PHD_w_prefix "")
  set(PHD_is_prefix FALSE)
  cmake_path(APPEND PHD_w_prefix "${CMAKE_CURRENT_SOURCE_DIR}" "${arg_PHD}")
  cmake_path(IS_PREFIX CMAKE_CURRENT_SOURCE_DIR ${PHD_w_prefix} NORMALIZE PHD_is_prefix)
  if(NOT PHD_is_prefix)
    message(FATAL_ERROR "${fun} CMAKE_CURRENT_SOURCE_DIR: "
      "${CMAKE_CURRENT_SOURCE_DIR}\nNOT A PREFIX OF: ${PHD_w_prefix}"
    )
  endif()
  if(NOT IS_DIRECTORY "${PHD_w_prefix}")
    message(FATAL_ERROR "${fun} IS NOT A DIR: ${PHD_w_prefix}")
  endif()

  set(WNDX_SANE_HEADERS_LIST "")
  if(arg_HFILES) # explicit HEADER FILES list
    ## RELATIVE_PATH is a FILE_SET TYPE HEADERS requirement!
    file(RELATIVE_PATH rel_path "${CMAKE_CURRENT_SOURCE_DIR}" "${CUR_INC_DIR}")
    foreach(hfile ${arg_HFILES})
      set(hpath "")
      set(hpath_full "")
      cmake_path(APPEND hpath "${rel_path}" "${hfile}")
      cmake_path(APPEND hpath_full "${CMAKE_CURRENT_SOURCE_DIR}" "${hpath}")
      if(NOT IS_READABLE "${hpath_full}") # well-defined only for explicit full paths
        message(FATAL_ERROR "${fun} NOT READABLE file: ${hpath_full}")
      endif()
      list(APPEND WNDX_SANE_HEADERS_LIST ${hpath})
      # message(DEBUG "${fun} hfile: ${hfile} | hpath: ${hpath}")
    endforeach(hfile)
  else() # generate list of header files
    ## this is currently the only way to gather list of files in a directory
    file(GLOB_RECURSE wndx_sane_headers LIST_DIRECTORIES false
      RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" # FILE_SET TYPE HEADERS requirement!
      "${arg_PHD}/*.h" "${arg_PHD}/*.hh" "${arg_PHD}/*.hpp"
    )
    list(APPEND WNDX_SANE_HEADERS_LIST ${wndx_sane_headers})
  endif()

  message(DEBUG "${fun} RELATIVE TO THE CMAKE_CURRENT_SOURCE_DIR LIST OF HEADERS:")
  foreach(fpath ${WNDX_SANE_HEADERS_LIST})
    message(DEBUG "${fpath}")
  endforeach(fpath)

  ## create target base: common to targets inheritance
  add_library(_${arg_LIB}_base INTERFACE)
  target_include_directories(_${arg_LIB}_base INTERFACE
    $<BUILD_INTERFACE:${CUR_INC_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
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

  wndx_sane_under_compiler(GNU)
  wndx_sane_under_compiler(Clang)
  wndx_sane_under_compiler(AppleClang)
  ## here we set flags/options common to our main target compilers
  if(GNU_COMP OR Clang_COMP OR AppleClang_COMP)

    if(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
      target_compile_options(${arg_LIB}_dev INTERFACE -Os)
    elseif(CMAKE_BUILD_TYPE STREQUAL Release)
      target_compile_options(${arg_LIB}_dev INTERFACE -O3)
    elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
      target_compile_options(${arg_LIB}_dev INTERFACE -g -Og)
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
      target_compile_options(${arg_LIB}_dev INTERFACE -g -Og)
      ## this helps to see/fix errors which MSVC will throw anyway
      target_compile_options(${arg_LIB}_dev INTERFACE -D_GLIBCXX_DEBUG) # (has its own cost)
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

    set(fdiag_common "")
    list(APPEND fdiag_common
      -fdiagnostics-color=always # auto unfortunately does not work within the script etc.
      -fdiagnostics-show-template-tree
      -fdiagnostics-show-option
    )
    if(GNU_COMP)
      list(APPEND fdiag_common
        -fdiagnostics-urls=always
        -fdiagnostics-generate-patch
      )
    elseif(Clang_COMP OR AppleClang_COMP)
      list(APPEND fdiag_common
        -fdiagnostics-fixit-info
      )
    endif()
    target_compile_options(${arg_LIB}_dev INTERFACE ${fdiag_common})
    target_compile_options(${arg_LIB}_deps   PUBLIC ${fdiag_common})
  endif(GNU_COMP OR Clang_COMP OR AppleClang_COMP)

  if(MSVC)
    target_compile_options(${arg_LIB}_dev INTERFACE /MP /utf-8)
    if(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
      target_compile_options(${arg_LIB}_dev INTERFACE /O1si)
    elseif(CMAKE_BUILD_TYPE STREQUAL Release)
      target_compile_options(${arg_LIB}_dev INTERFACE /O2ti)
    elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
      target_compile_options(${arg_LIB}_dev INTERFACE /Ox /DEBUG /Zi)
    elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
      target_compile_options(${arg_LIB}_dev INTERFACE /Od /DEBUG /Zi)
    endif()
    ## TODO: MSVC /W3 is a baseline - mimic in other targeted compilers similar warning flags.
    ## (to have equal warnings between compilers and all environments/platforms)
    target_compile_options(${arg_LIB}_dev INTERFACE /W3)
    ## v (flag is obviously missing in MSVC if flag has leading sign: -,--)
  else()
    ## Other flags which may miss in any of the targeted compilers.
    ## Not targeted compilers may have support of the GNU/Clang flags
    ## -> so we check support of the following flags, applying only supported.

    ## following flags may be or may not be present in the compiler
    wndx_sane_tgt_add_check_cxx_compiler_flag(${arg_LIB}_dev INTERFACE
      -Warith-conversion
      -Wstrict-null-sentinel
      -Wzero-as-null-pointer-constant
    )

    ## gives many false positives with GCC 13 -- https://github.com/fmtlib/fmt/issues/3415 -- etc.
    wndx_sane_tgt_add_check_cxx_compiler_flag(${arg_LIB}_dev INTERFACE -Wno-dangling-reference)

    ## flags for other compilers should be here
  endif()
endfunction(wndx_sane_create_targets)
