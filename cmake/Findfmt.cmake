include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## BEG CONF
set(pkg_name "fmt")
set(pkg_repo "https://github.com/fmtlib/fmt.git")
set(pkg_ver "9.1.0")
set(pkg_tag "${pkg_ver}")
set(pkg_tgt "${pkg_name}::${pkg_name}") ## target

option(FMT_INSTALL OFF)
option(FMT_OS OFF)
## END CONF

include(wndx_sane_find)
wndx_sane_find(
  PKG_NAME  "${pkg_name}"
  PKG_REPO  "${pkg_repo}"
  PKG_TAG   "${pkg_tag}"
  PKG_VER   "${pkg_ver}"
  PKG_TGT   "${pkg_tgt}"
  # FORCE_FETCH
  # PKG_NO_LINK
)

## link with the static library fmt
## which is found in the fetched locally lib dir.
## NOTE: this is the same stuff, left for reference.
# if(TRUE)
#   if(TRUE)
#     target_link_libraries(sane_deps "${pkg_tgt}")
#   else()
#     target_include_directories(sane_deps PUBLIC "${pkg_inc}")
#     target_link_libraries(sane_deps PRIVATE "${pkg_tgt}")
#   endif()
# else()
#   target_include_directories(sane_deps PUBLIC "${pkg_inc}")
#   target_link_libraries(sane_deps PRIVATE
#     -L"${pkg_bin}" -l$<$<CONFIG:Debug>:fmtd>$<$<CONFIG:Release>:fmt>
#   )
# endif()

