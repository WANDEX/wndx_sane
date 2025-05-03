include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_memcheck) ## args
  cmake_parse_arguments(arg # pfx
    "EXIT_ON_FIRST_ERROR" # opt
    "TGT_NAME;WORKING_DIRECTORY" # ovk
    "TGT_DEPS;TGT_EXEC;VALGRIND_OPTS" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_memcheck()")

  ## use default value if not explicitly provided
  if(NOT arg_WORKING_DIRECTORY OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*WORKING_DIRECTORY.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "WORKING_DIRECTORY")
    set(arg_WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
  endif()

  ## use default value if not explicitly provided
  if(NOT arg_VALGRIND_OPTS OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*VALGRIND_OPTS.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "VALGRIND_OPTS")
    set(arg_VALGRIND_OPTS "")
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
  if(NOT arg_TGT_EXEC MATCHES "^.+$")
    message(FATAL_ERROR "${fun} TGT_EXEC not provided!")
  endif()
  if(NOT arg_TGT_DEPS MATCHES "^.+$")
    message(FATAL_ERROR "${fun} TGT_DEPS not provided!")
  endif()

  if(arg_EXIT_ON_FIRST_ERROR)
    LIST(APPEND arg_VALGRIND_OPTS "--exit-on-first-error=yes")
  endif()

  if(WIN32)
    message(NOTICE "${fun} SKIP MEMCHECK - valgrind is not supported on WINDOWS platform!")
    add_custom_target(${arg_TGT_NAME}
      COMMAND echo 'dummy echo instead of --target ${arg_TGT_NAME} call!'
    )
  else()
    find_program(VALGRIND NAMES valgrind)
    if(NOT VALGRIND)
      message(FATAL_ERROR "${fun} valgrind not found at PATH!")
    else()
      message(DEBUG "${fun} valgrind found at PATH ${VALGRIND}")
    endif()
    add_custom_target(${arg_TGT_NAME}
      COMMAND ${VALGRIND} --tool=memcheck -s --leak-check=full --show-leak-kinds=all
                      --error-exitcode=73 ${arg_VALGRIND_OPTS}
                      -- ${arg_TGT_EXEC}
      WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
      DEPENDS ${arg_TGT_DEPS}
      USES_TERMINAL
      VERBATIM
    )
    add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
  endif()
endfunction()
