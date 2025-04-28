include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_package) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "TGT_NAME;SUFFIX;DST_DIR" # ovk
    "FILES" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_package()")

  ## use default destination dir if not explicitly provided
  if(arg_KEYWORDS_MISSING_VALUES MATCHES ".*DST_DIR.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "DST_DIR")
    cmake_path(SET arg_DST_DIR NORMALIZE "${CMAKE_CURRENT_BINARY_DIR}")
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
  if(NOT arg_SUFFIX MATCHES "^.+$")
    message(FATAL_ERROR "${fun} SUFFIX not provided!")
  endif()
  if(NOT arg_FILES MATCHES "^.+$")
    message(FATAL_ERROR "${fun} FILES not provided!")
  endif()
  if(NOT arg_DST_DIR MATCHES "^.+$")
    message(FATAL_ERROR "${fun} DST_DIR not valid!")
  endif()

  cmake_path(SET dst_dir NORMALIZE "${arg_DST_DIR}")
  set(fname "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${arg_SUFFIX}")
  set(fpath "")
  cmake_path(APPEND fpath "${dst_dir}" "${fname}.tar.gz")
  message(DEBUG ">> ${fun} tgt: ${arg_TGT_NAME} fpath: ${fpath}")
  add_custom_command(
    OUTPUT "${fpath}"
    COMMAND ${CMAKE_COMMAND} -E tar -czf "${fpath}" -- ${arg_FILES}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS ${arg_FILES}
  )
  add_custom_target(${arg_TGT_NAME} DEPENDS "${fpath}")
endfunction()
