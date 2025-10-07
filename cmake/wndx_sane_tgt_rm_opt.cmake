include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.
##
## NOTE: this module has not been tested properly, it does not currently work and may never work!
## The idea of removing options/flags from the targets might be a dead end.
## The only correct way is not to inherit options/flags that are not needed!
##
## This file is a reminder that experiments were done with this feature.

## XXX: This function does not work!
## remove option from target. e.g. -fsanitize=address.
function(wndx_sane_tgt_rm_opt tgt opt)
  if(NOT TARGET ${tgt})
    return()
  endif()
  ## FIXME: I broke the function or why it does not remove options?
  set(fun "wndx_sane_tgt_rm_opt()")
  message(WARNING "${fun} rm opt : ${opt}")
  # set(_c_opts "") # remove from COMPILE_OPTIONS (if present)
  get_target_property(c_opts ${tgt} COMPILE_OPTIONS)
  if(_c_opts)
    list(FILTER _c_opts EXCLUDE REGEX "^${opt}$")
    set_target_properties(${tgt} PROPERTIES COMPILE_OPTIONS "${_c_opts}")
  endif(_c_opts)

  # set(l_opts "") # remove from LINK_OPTIONS (if present)
  get_target_property(_l_opts ${tgt} LINK_OPTIONS)
  if(_l_opts)
    list(FILTER _l_opts EXCLUDE REGEX "^${opt}$")
    set_target_properties(${tgt} PROPERTIES LINK_OPTIONS "${_l_opts}")
  endif(_l_opts)

  # set(i_opts "") # remove from INTERFACE_COMPILE_OPTIONS (if propagated)
  get_target_property(_i_opts ${tgt} INTERFACE_COMPILE_OPTIONS)
  if(_i_opts)
    list(FILTER _i_opts EXCLUDE REGEX "^${opt}$")
    set_target_properties(${tgt} PROPERTIES INTERFACE_COMPILE_OPTIONS "${_i_opts}")
  endif(_i_opts)
endfunction()

## XXX: This function does not work!
## helper: remove any -fsanitize=address flags from a target
function(wndx_sane_tgt_rm_fsanitize_address tgt)
  if (TARGET ${tgt})
    get_target_property(_old_cflags ${tgt} COMPILE_OPTIONS)
    if (NOT _old_cflags)
      set(_old_cflags "")
    endif()
    # remove -fsanitize=address from COMPILE_OPTIONS
    list(FILTER _old_cflags EXCLUDE REGEX "^-fsanitize=address$")
    set_target_properties(${tgt} PROPERTIES COMPILE_OPTIONS "${_old_cflags}")

    # remove ASAN from link flags (if present)
    get_target_property(_old_linkopts ${tgt} LINK_OPTIONS)
    if (NOT _old_linkopts)
      set(_old_linkopts "")
    endif()
    list(FILTER _old_linkopts EXCLUDE REGEX "^-fsanitize=address$")
    set_target_properties(${tgt} PROPERTIES LINK_OPTIONS "${_old_linkopts}")

    # also remove from INTERFACE_COMPILE_OPTIONS if propagated
    get_target_property(_int_opts ${tgt} INTERFACE_COMPILE_OPTIONS)
    if(_int_opts)
      list(FILTER _int_opts EXCLUDE REGEX "^-fsanitize=address$")
      set_target_properties(${tgt} PROPERTIES INTERFACE_COMPILE_OPTIONS "${_int_opts}")
    endif()
  endif()
endfunction()
