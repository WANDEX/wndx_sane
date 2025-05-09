include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## BEG CONF
set(pkg_name "gtest")
set(pkg_repo "https://github.com/google/googletest.git")
if(TRUE)
  set(pkg_ver "1.16.0")
  set(pkg_tag "6910c9d9165801d8827d628cb72eb7ea9dd538c5") # v1.16.0
else()
  set(pkg_ver "1.12.1")
  set(pkg_tag "58d77fa8070e8cec2dc1ed015d66b454c8d78850") # last C++11 tag release-1.12.1
endif()
set(pkg_tgt "${pkg_name}::gtest_main") ## target

set(INSTALL_GTEST OFF)

if(NOT DEFINED BUILD_GMOCK)
  set(BUILD_GMOCK ON)
endif()

## For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
## END CONF

include(wndx_sane_find)
wndx_sane_find(
  PKG_NAME  "${pkg_name}"
  PKG_REPO  "${pkg_repo}"
  PKG_TAG   "${pkg_tag}"
  PKG_VER   "${pkg_ver}"
  PKG_TGT   "${pkg_tgt}"
  FORCE_FETCH
  PKG_NO_LINK
)

## When Google Test is included directly rather than through find_package, the aliases are missing.
if(NOT TARGET ${pkg_name}::gtest)
  if(TARGET gtest)
    message(DEBUG "create aliases on built from source TARGET gtest.")
    add_library(${pkg_name}::gtest      ALIAS gtest)
    add_library(${pkg_name}::gtest_main ALIAS gtest_main)
  else()
    message(FATAL_ERROR "target gtest was not found.")
  endif()
  if(TARGET gmock)
    add_library(${pkg_name}::gmock      ALIAS gmock)
    add_library(${pkg_name}::gmock_main ALIAS gmock_main)
  elseif(${BUILD_GMOCK}) # only if explicitly instructed to build gmock.
    message(FATAL_ERROR "target gmock was not found.")
  endif()
endif()

