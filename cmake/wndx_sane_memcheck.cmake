include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

function(wndx_sane_memcheck) ## args
  cmake_parse_arguments(arg # pfx
    "" # opt
    "TGT_NAME;TGT_EXEC" # ovk
    "TGT_DEPS" # mvk
    ${ARGN}
  )
  set(fun "wndx_sane_memcheck()")

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

  # FIXME: this module is not tested, fix after integrating into algorithms library
  add_custom_target(${arg_TGT_NAME}
    COMMAND valgrind --tool=memcheck -s --leak-check=full --show-leak-kinds=all
                    --error-exitcode=73 # --exit-on-first-error=yes
                    -- ./${arg_TGT_EXEC} --gtest_brief=1
    WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    DEPENDS ${arg_TGT_DEPS}
  )
  add_dependencies(${arg_TGT_NAME} ${arg_TGT_DEPS})
endfunction()
