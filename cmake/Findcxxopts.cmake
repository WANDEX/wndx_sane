include_guard(GLOBAL)
## cmake module from WANDEX/wndx_sane lib.

## BEG CONF
set(pkg_name "cxxopts")
set(pkg_repo "https://github.com/jarro2783/cxxopts.git")
set(pkg_ver "3.1.1")
set(pkg_tag "v${pkg_ver}")
set(pkg_tgt "${pkg_name}::${pkg_name}") ## XXX: fake target

option(CXXOPTS_ENABLE_INSTALL OFF)
## END CONF

include(wndx_sane_find)
wndx_sane_find(
  PKG_NAME  "${pkg_name}"
  PKG_REPO  "${pkg_repo}"
  PKG_TAG   "${pkg_tag}"
  PKG_VER   "${pkg_ver}"
  PKG_TGT   "${pkg_tgt}"
  # FORCE_FETCH
  PKG_NO_LINK
  HFILES "cxxopts.hpp"
)

