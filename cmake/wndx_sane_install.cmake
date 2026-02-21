include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_install) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "NAMESPACE;PHD" # ovk
    "TARGETS;PATTERNS" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_install()")

  ## use default value if not explicitly provided
  if(NOT arg_NAMESPACE OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*NAMESPACE.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "NAMESPACE")
    set(arg_NAMESPACE "wndx::")
    message(WARNING "${fun} NAMESPACE not provided => used by default: ${arg_NAMESPACE}")
  endif()

  if(NOT arg_PHD OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*PHD.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "PHD")
    cmake_path(APPEND arg_PHD "include" "${PROJECT_NAME}")
  endif()

  message(DEBUG "PATTERNS: ${arg_PATTERNS}, TARGETS: ${arg_TARGETS}")

  if(arg_UNPARSED_ARGUMENTS)
    message(WARNING "UNPARSED: ${fun} ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(arg_KEYWORDS_MISSING_VALUES)
    message(WARNING " MISSING: ${fun} ${arg_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT arg_PATTERNS)
    set(arg_PATTERNS "*.hpp" "*.h" "*.hh")
    message(WARNING "${fun} PATTERNS not provided => used by default: ${arg_PATTERNS}")
  endif()

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

  message(STATUS "Generating Install")
  include(CMakePackageConfigHelpers)
  include(GNUInstallDirs)

  set(proj_config "${PROJECT_NAME}-config")
  cmake_path(APPEND cmake_proj_config "cmake" "${proj_config}")
  cmake_path(APPEND bin_dir_proj_config "${PROJECT_BINARY_DIR}" "${proj_config}")
  cmake_path(APPEND install_libdir_cmake "${CMAKE_INSTALL_LIBDIR}" "cmake" "${PROJECT_NAME}")

  install(TARGETS ${arg_TARGETS}
    EXPORT ${PROJECT_NAME}-targets
    RUNTIME   DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY   DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE   DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    FRAMEWORK DESTINATION "${CMAKE_INSTALL_LIBDIR}" # must be explicitly set for Xcode etc.
    BUNDLE    DESTINATION . # macOS bundles are installed directly into CMAKE_INSTALL_PREFIX
  )

  install(EXPORT ${PROJECT_NAME}-targets
    NAMESPACE   "${arg_NAMESPACE}"
    DESTINATION "${install_libdir_cmake}"
  )

  configure_package_config_file(
    "${cmake_proj_config}.cmake.in"
    "${bin_dir_proj_config}.cmake"
    INSTALL_DESTINATION "${install_libdir_cmake}"
  )
  install(FILES "${bin_dir_proj_config}.cmake"
    DESTINATION "${install_libdir_cmake}"
  )

  write_basic_package_version_file(
    "${bin_dir_proj_config}-version.cmake"
    COMPATIBILITY ExactVersion
  )

  install(FILES "${bin_dir_proj_config}-version.cmake"
    DESTINATION "${install_libdir_cmake}"
  )

  install(DIRECTORY "${arg_PHD}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    FILES_MATCHING PATTERN "${arg_PATTERNS}"
  )
endfunction()

