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
## if(Release)
## creation of variables to be able to use them later
## wndx_sane_build_type(Release)
## wndx_sane_build_type(Debug)
function(wndx_sane_build_type ARG)
  if(CMAKE_BUILD_TYPE STREQUAL ${ARG})
    set(${ARG} TRUE  PARENT_SCOPE)
  else()
    set(${ARG} FALSE PARENT_SCOPE)
  endif()
endfunction(wndx_sane_build_type)


## define variables to be able to use short & readable if conditions
## creation of variables to be able to use them later
## wndx_sane_under_compiler(GNU)
## wndx_sane_under_compiler(Clang)
## wndx_sane_under_compiler(AppleClang)
## wndx_sane_under_compiler(MSVC) # cmake has short MSVC  (so this is added for consistency!)
## if(GNU_COMP OR Clang_COMP OR AppleClang_COMP)
function(wndx_sane_under_compiler ARG)
  if( (  CMAKE_C_COMPILER_ID STREQUAL ${ARG}) OR
      (CMAKE_CXX_COMPILER_ID STREQUAL ${ARG}) )
    # message(DEBUG "wndx_sane_under_compiler() ${CMAKE_PROJECT_NAME} UNDER ${ARG}")
    set(${ARG}_COMP TRUE  PARENT_SCOPE)
  else()
    set(${ARG}_COMP FALSE PARENT_SCOPE)
  endif()
endfunction(wndx_sane_under_compiler)


## recursively include all sub-directories of the given dir.
## NOTE: recursive approach is strongly discouraged!
##       manual and target based include are preferred!
function(wndx_sane_include_subdirs arg_dir)
  set(fun "wndx_sane_include_subdirs()")
  file(GLOB_RECURSE recurse_rpaths LIST_DIRECTORIES true
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${arg_dir}/$")
  ## ^ list only sub-directories of the given dir using relative path
  list(FILTER recurse_rpaths EXCLUDE REGEX "/\\.") # exclude paths with .dirs
  foreach(rel_path ${recurse_rpaths})
    ## get absolute path (relative paths have problems particularly in Windows)
    file(REAL_PATH "${rel_path}" abs_path BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    ## double check that this is directory
    if(NOT IS_DIRECTORY "${abs_path}")
      message(DEBUG "${fun} (SKIP) THIS IS NOT DIRECTORY: ${abs_path}")
      continue()
    endif()
    ## include dir
    include_directories("${abs_path}")
    ## see which dirs are included in the build process
    message(DEBUG "${fun} included subdir: ${abs_path}")
  endforeach(rel_path)
endfunction(wndx_sane_include_subdirs)

## https://cmake.org/cmake/help/latest/module/CheckCXXCompilerFlag.html
include(CheckCXXCompilerFlag) # -> check_cxx_compiler_flag()

## wrapper function with consecutive: check, apply.
## receives same arguments as target_compile_options().
## check_cxx_compiler_flag(), target_compile_options().
function(wndx_sane_tgt_add_check_cxx_compiler_flag) ## args
  set(arg_TARGET ${ARGV0})
  set(arg_SCOPE  ${ARGV1})
  list(SUBLIST ARGV 2 -1 arg_FLAGS) # ARGV leftovers
  set(fun "wndx_sane_tgt_add_check_cxx_compiler_flag()")
  foreach(flag ${arg_FLAGS})
    # message(DEBUG "${fun} ${flag}")
    check_cxx_compiler_flag(${flag} HAS_${flag})
    if(HAS_${flag})
      target_compile_options(${arg_TARGET} ${arg_SCOPE} ${flag})
    endif()
  endforeach(flag)
endfunction(wndx_sane_tgt_add_check_cxx_compiler_flag)

