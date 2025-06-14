include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.
## useful functions / variable definitions

## append to the list of env vars respecting environment value else set default.
function(wndx_sane_env_set) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "LIST;DEF_VAL;ENV_VAR" # ovk
    "" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_env_set()")
  if(DEFINED ENV{${arg_ENV_VAR}})
    list(APPEND ${arg_LIST} "${arg_ENV_VAR}=$ENV{${arg_ENV_VAR}}")
  else()
    list(APPEND ${arg_LIST} "${arg_ENV_VAR}=${arg_DEF_VAL}")
  endif()
  # message(DEBUG "${fun} ${arg_LIST}")
  return(PROPAGATE ${arg_LIST})
endfunction()

function(wndx_sane_path arg_VAR_NAME) ## ARGN
  unset(${arg_VAR_NAME} PARENT_SCOPE) ## unset old variable
  file(REAL_PATH "${CMAKE_CURRENT_SOURCE_DIR}" args)
  cmake_path(APPEND args ${ARGN})
  set(${arg_VAR_NAME} "${args}" PARENT_SCOPE) ## set literal variable
  # message("${ARGN}")
  # message("${arg_VAR_NAME}")
endfunction()

## define variables to be able to use short if conditions
## if(${NOT_Release})
function(not_build_type ARG)
  if(NOT CMAKE_BUILD_TYPE STREQUAL ${ARG})
    set(NOT_${ARG} TRUE  PARENT_SCOPE)
  else()
    set(NOT_${ARG} FALSE PARENT_SCOPE)
  endif()
endfunction(not_build_type)
## creation of variables to be able to use them later
not_build_type(Release)
not_build_type(Debug)


## define variables to be able to use short & readable if conditions
## if(${Clang_COMP} OR ${GNU_COMP})
function(under_compiler ARG)
  if( (  CMAKE_C_COMPILER_ID STREQUAL ${ARG}) OR
      (CMAKE_CXX_COMPILER_ID STREQUAL ${ARG}) )
    if(${NOT_Release})
      message(NOTICE ">> ${CMAKE_PROJECT_NAME} UNDER ${ARG}")
    endif()
    set(${ARG}_COMP TRUE  PARENT_SCOPE)
  else()
    set(${ARG}_COMP FALSE PARENT_SCOPE)
  endif()
endfunction(under_compiler)
## creation of variables to be able to use them later
under_compiler(GNU)
under_compiler(Clang)
under_compiler(AppleClang)
under_compiler(MSVC)   # cmake has short MSVC  (so this is added for consistency!)


## https://cmake.org/cmake/help/latest/module/CheckCXXCompilerFlag.html
include(CheckCXXCompilerFlag) # -> check_cxx_compiler_flag()

## NOTE: only one flag is supported as function argument!
## usage target_add_check_cxx_compiler_flag(target -Wstrict-null-sentinel )
function(target_add_check_cxx_compiler_flag target flag)
  check_cxx_compiler_flag(${flag} HAS_${flag})
  if(HAS_${flag})
    target_compile_options(${target} INTERFACE ${flag})
  endif()
endfunction(target_add_check_cxx_compiler_flag)


## recursively include all sub-directories of the given dir
function(include_subdirs arg_dir)
  file(GLOB_RECURSE recurse_rpaths LIST_DIRECTORIES true
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${arg_dir}/$")
  ## ^ list only sub-directories of the given dir using relative path
  list(FILTER recurse_rpaths EXCLUDE REGEX "/\\.") # exclude paths with .dirs
  foreach(rel_path ${recurse_rpaths})
    ## get absolute path (relative paths have problems particularly in Windows)
    file(REAL_PATH "${rel_path}" abs_path BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    ## double check that this is directory
    if(NOT IS_DIRECTORY "${abs_path}")
      if(${NOT_Release})
        message(DEBUG "(SKIP) THIS IS NOT DIRECTORY: ${abs_path}")
      endif()
      continue()
    endif()
    ## include dir
    include_directories("${abs_path}")
    ## see which dirs are included in the build process
    if(${NOT_Release})
      message(DEBUG "included subdir: ${abs_path}")
    endif()
  endforeach(rel_path)
endfunction(include_subdirs)

