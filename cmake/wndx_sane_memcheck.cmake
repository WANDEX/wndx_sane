include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_memcheck) ## args
  cmake_parse_arguments(arg # pfx
    "EXIT_ON_FIRST_ERROR;FORCE_DRMEMORY" # opt
    "TGT_NAME;WORKING_DIRECTORY" # ovk
    "TGT_EXEC;VALGRIND_OPTS;DRMEMORY_OPTS" # mvk
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

  if(arg_EXIT_ON_FIRST_ERROR)
    list(APPEND arg_VALGRIND_OPTS "--exit-on-first-error=yes")
  endif()


  # split on executable name and trailing arguments if any
  if(FALSE) # regex way
    set(exec_re "[A-Za-z0-9_.-]+") # regex match executable name
    string(REGEX MATCH   "${exec_re}" tgt_exec "${arg_TGT_EXEC}")
    string(REGEX REPLACE "^[^;]?${exec_re};" "" tgt_opts "${arg_TGT_EXEC}")
  else() # list way
    list(POP_FRONT  arg_TGT_EXEC tgt_exec)
    set (tgt_opts ${arg_TGT_EXEC})
  endif()
  message(DEBUG "${fun} TGT_EXEC name: ${tgt_exec}")
  message(DEBUG "${fun} TGT_EXEC opts: ${tgt_opts}")
  if(NOT TARGET ${tgt_exec})
    message(FATAL_ERROR "${fun} TGT_EXEC executable name: '${tgt_exec}' - TARGET not exist!")
  endif()

  list(APPEND CUSTOM_TARGET_OPTS
    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
    DEPENDS ${tgt_exec}
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
                        -- $<TARGET_FILE:${tgt_exec}> ${tgt_opts}
        ${CUSTOM_TARGET_OPTS}
      )
      add_dependencies(${arg_TGT_NAME} ${tgt_exec})
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
                      -- $<TARGET_FILE:${tgt_exec}> ${tgt_opts}
      ${CUSTOM_TARGET_OPTS}
    )
    add_dependencies(${arg_TGT_NAME} ${tgt_exec})
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
                      -- $<TARGET_FILE:${tgt_exec}> ${tgt_opts}
      ${CUSTOM_TARGET_OPTS}
    )
    add_dependencies(${arg_TGT_NAME} ${tgt_exec})
  endif()
endfunction()
