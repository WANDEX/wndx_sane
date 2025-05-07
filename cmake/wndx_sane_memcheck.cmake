include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_memcheck) ## args
  cmake_parse_arguments(arg # pfx
    "EXIT_ON_FIRST_ERROR;FORCE_DRMEMORY" # opt
    "TGT_NAME;WORKING_DIRECTORY" # ovk
    "TGT_DEPS;TGT_EXEC;VALGRIND_OPTS;DRMEMORY_OPTS" # mvk
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

  ## use default value if not explicitly provided
  if(NOT arg_DRMEMORY_OPTS OR arg_KEYWORDS_MISSING_VALUES MATCHES ".*DRMEMORY_OPTS.*")
    list(REMOVE_ITEM arg_KEYWORDS_MISSING_VALUES "DRMEMORY_OPTS")
    set(arg_DRMEMORY_OPTS "")
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
    list(APPEND arg_VALGRIND_OPTS "--exit-on-first-error=yes")
  endif()


  # get_target_property(output_name ${arg_TGT_DEPS} OUTPUT_NAME)
  # message(WARNING "output_name: ${output_name}") # XXX
  # get_target_property(output ${arg_TGT_DEPS} OUTPUT)
  # message(WARNING "output: ${output}") # XXX


  list(APPEND CUSTOM_TARGET_OPTS
    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
    DEPENDS ${arg_TGT_DEPS}
    USES_TERMINAL
    VERBATIM
  )

  if(WIN32 OR arg_FORCE_DRMEMORY)
    if(TRUE)
      find_program(DRMEMORY_COMMAND NAMES drmemory)
      if(NOT DRMEMORY_COMMAND)
        message(FATAL_ERROR "${fun} drmemory util not found at PATH!")
      else()
        message(DEBUG "${fun} drmemory util found at PATH ${DRMEMORY_COMMAND}")
      endif()
      add_custom_target(${arg_TGT_NAME}
        COMMAND ${DRMEMORY_COMMAND} ${arg_DRMEMORY_OPTS}
                        -- ${arg_TGT_EXEC}
        ${CUSTOM_TARGET_OPTS}
      )
      add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
    else()
      message(NOTICE "${fun} SKIP MEMCHECK - not supported on WINDOWS platform!")
      add_custom_target(${arg_TGT_NAME}
        COMMAND echo 'dummy echo instead of --target ${arg_TGT_NAME} call!'
      )
    endif()
  elseif(APPLE)
    find_program(LEAKS_COMMAND NAMES leaks)
    if(NOT LEAKS_COMMAND)
      message(FATAL_ERROR "${fun} leaks util not found at PATH!")
    else()
      message(DEBUG "${fun} leaks util found at PATH ${LEAKS_COMMAND}")
    endif()
    add_custom_target(${arg_TGT_NAME}
      COMMAND export MallocStackLogging=1 && ${LEAKS_COMMAND} --atExit
                      -- ${arg_TGT_EXEC}
      ${CUSTOM_TARGET_OPTS}
    )
    add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
  else()
    find_program(VALGRIND_COMMAND NAMES valgrind)
    if(NOT VALGRIND_COMMAND)
      message(FATAL_ERROR "${fun} valgrind util not found at PATH!")
    else()
      message(DEBUG "${fun} valgrind util found at PATH ${VALGRIND_COMMAND}")
    endif()
    add_custom_target(${arg_TGT_NAME}
      COMMAND ${VALGRIND_COMMAND} --tool=memcheck -s --leak-check=full --show-leak-kinds=all
                      --error-exitcode=73 ${arg_VALGRIND_OPTS}
                      -- ${arg_TGT_EXEC}
      ${CUSTOM_TARGET_OPTS}
    )
    add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
  endif()
endfunction()
