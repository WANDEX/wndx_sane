include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## function to find/fetch module
function(wndx_sane_find) ## args
  cmake_parse_arguments(arg # pfx
    "FORCE_FETCH;PKG_NO_LINK" # opt
    "PKG_NAME;PKG_REPO;PKG_TAG;PKG_VER;PKG_TGT" # ovk
    "HFILES" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_find()")

  ## optional HEADER FILES list (for the header only libraries)
  if(arg_KEYWORDS_MISSING_VALUES MATCHES ".*HFILES.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "HFILES")
    cmake_path(SET arg_HFILES NORMALIZE "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  message(DEBUG "${fun} PKG_NAME: ${arg_PKG_NAME}, PKG_VER: ${arg_PKG_VER}, PKG_TGT: ${arg_PKG_TGT}")
  message(DEBUG "${fun} PKG_REPO: ${arg_PKG_REPO}, PKG_TAG: ${arg_PKG_TAG}")

  if(arg_UNPARSED_ARGUMENTS)
    message(WARNING "UNPARSED: ${fun} ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(arg_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR " MISSING: ${fun} ${arg_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT arg_PKG_TGT MATCHES "^.*::.*$")
    message(FATAL_ERROR "${fun} PKG_TGT not a valid target ${arg_PKG_TGT}")
  endif()

  set(pkg_name "${arg_PKG_NAME}") ## package name
  set(pkg_repo "${arg_PKG_REPO}") ## git repository
  set(pkg_tag  "${arg_PKG_TAG}") ## git tag
  set(pkg_ver  "${arg_PKG_VER}") ## find version
  set(pkg_tgt  "${arg_PKG_TGT}") ## package target

  unset(dep_dir)
  if(WNDX_SANE_DIR_3RDPARTY)
    if(IS_ABSOLUTE "${WNDX_SANE_DIR_3RDPARTY}" AND EXISTS "${WNDX_SANE_DIR_3RDPARTY}")
      message(DEBUG "${fun} dir for the 3rdparty dependency '${pkg_name}': ${WNDX_SANE_DIR_3RDPARTY}")
      cmake_path(APPEND dep_dir "${WNDX_SANE_DIR_3RDPARTY}")
    else()
      cmake_path(APPEND dep_dir "${CMAKE_SOURCE_DIR}" ".3rdparty")
    endif()
  else()
    cmake_path(APPEND dep_dir "${PROJECT_BINARY_DIR}" "_deps")
  endif()

  foreach(variable IN LISTS pkg_dir pkg_sub pkg_src pkg_bin pkg_inc)
    unset(${variable})
  endforeach()
  cmake_path(APPEND pkg_dir "${dep_dir}" "${pkg_name}") # lib dir root
  cmake_path(APPEND pkg_sub "${pkg_dir}" "sub")
  cmake_path(APPEND pkg_src "${pkg_dir}" "src")
  cmake_path(APPEND pkg_bin "${pkg_dir}" "bin")
  cmake_path(APPEND pkg_inc "${pkg_src}" "include")

  if(FALSE) # XXX
    message(DEBUG "${fun} ${pkg_name}_FOUND: ${${pkg_name}_FOUND}")
    if(IS_READABLE "${${pkg_name}_DIR}")
      message(DEBUG "${fun} IS READABLE ${pkg_name}_DIR: ${${pkg_name}_DIR}")
    endif()
  endif()

  find_package("${pkg_name}" "${pkg_ver}"
    PATHS
      "${${pkg_name}_DIR}" ## previously found dir with module/pkg config
    NO_DEFAULT_PATH
  )

  if(arg_FORCE_FETCH)
    set(_force " FORCE")
  else()
    set(_force "")
  endif()

  if(arg_FORCE_FETCH OR NOT ${${pkg_name}_FOUND})
    message(NOTICE ">> ${fun}${_force} fetch ${pkg_name} of required version ${pkg_ver}")
    include(FetchContent)
    FetchContent_Declare(   "${pkg_name}"
      GIT_REPOSITORY        "${pkg_repo}"
      GIT_TAG               "${pkg_tag}"
      SUBBUILD_DIR          "${pkg_sub}"
      SOURCE_DIR            "${pkg_src}"
      BINARY_DIR            "${pkg_bin}"
      OVERRIDE_FIND_PACKAGE
    )
    FetchContent_MakeAvailable("${pkg_name}")
  else()
    message(NOTICE ">> ${fun} found ${pkg_name} of required version ${pkg_ver}")
  endif()

  cmake_path(SET DEP_INC_DIR NORMALIZE "${pkg_inc}")

  if(NOT arg_PKG_NO_LINK)
    target_include_directories(sane_deps PUBLIC
      $<BUILD_INTERFACE:${DEP_INC_DIR}>
      $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
    target_link_libraries(sane_deps PRIVATE "${pkg_tgt}")
  endif(NOT arg_PKG_NO_LINK)

  if(arg_HFILES)
    ## RELATIVE_PATH is a FILE_SET TYPE HEADERS requirement!
    file(RELATIVE_PATH rel_path "${CMAKE_CURRENT_SOURCE_DIR}" "${DEP_INC_DIR}")
    set(DEP_HEADERS_LIST "")
    foreach(hfile ${arg_HFILES})
      set(hpath "")
      cmake_path(APPEND hpath "${rel_path}" "${hfile}")
      if(NOT IS_READABLE "${hpath}")
        message(FATAL_ERROR "${fun} NOT READABLE file: ${hpath}")
      endif()
      list(APPEND DEP_HEADERS_LIST ${hpath})
      message(DEBUG "${fun} hfile: ${hfile} | hpath: ${hpath}")
    endforeach(hfile)

    target_include_directories(sane_deps PUBLIC
      $<BUILD_INTERFACE:${DEP_INC_DIR}>
      $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
    target_sources(sane_deps PUBLIC
      FILE_SET  headers_deps TYPE HEADERS
      FILES     "${DEP_HEADERS_LIST}"
    )
  endif(arg_HFILES)
endfunction(wndx_sane_find)

