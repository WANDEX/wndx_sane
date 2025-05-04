include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_coverage) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "TGT_NAME;CLEAN" # ovk
    "TGT_DEPS;RMGLOB" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_coverage()")

  ## use default value if not explicitly provided
  if(NOT arg_CLEAN OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*CLEAN.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "CLEAN")
    set(arg_CLEAN FALSE)
  endif()

  ## use default value if not explicitly provided
  if(NOT arg_RMGLOB OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*RMGLOB.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "RMGLOB")
    list(APPEND arg_RMGLOB *.gcda) # *.gcno
  endif()

  if(arg_UNPARSED_ARGUMENTS)
    message(WARNING "UNPARSED: ${fun} ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(arg_KEYWORDS_MISSING_VALUES)
    message(WARNING " MISSING: ${fun} ${arg_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT arg_TGT_NAME MATCHES "^.+$")
    message(FATAL_ERROR "${fun} TGT_NAME not provided!")
  endif()
  if(NOT arg_TGT_DEPS MATCHES "^.+$")
    message(FATAL_ERROR "${fun} TGT_DEPS not provided!")
  endif()

  include(wndx_sane_funcs)
  under_compiler(GNU)
  if(${GNU_COMP})
    add_library(${arg_TGT_NAME} INTERFACE)
    add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
    ## NOTE: without optimizations
    ## => other optimization levels/options obviously ruin coverage report.
    target_compile_options(${arg_TGT_NAME} INTERFACE -g -O0 --coverage)
    target_link_options(${arg_TGT_NAME} INTERFACE --coverage)
    if(arg_CLEAN)
      ### before taking new coverage analysis data:
      ## find all coverage files in the project binary dir
      file(GLOB_RECURSE prev_cov_files LIST_DIRECTORIES false
        ABSOLUTE "${CMAKE_CURRENT_BINARY_DIR}" ${arg_RMGLOB})
      ## clean from the previous coverage data files (if any)
      if(NOT prev_cov_files STREQUAL "")
        file(REMOVE ${prev_cov_files})
        message(DEBUG "${fun} cleared of previous coverage data files.")
      else()
        message(DEBUG "${fun} nothing to clean up. (no coverage data files found)")
      endif()
    endif(arg_CLEAN)
    message(NOTICE "${fun} code coverage will be collected!")
  else()
    message(NOTICE "${fun} code coverage analysis enabled only on the GNU/GCC toolchain!")
  endif()
endfunction()
