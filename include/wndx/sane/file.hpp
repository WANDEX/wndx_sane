#pragma once

#include "aliases.hpp"        // IWYU pragma: keep

#include "wndx/sane/path.hpp" // IWYU pragma: keep

#include <filesystem>


namespace wndx::sane::file {

[[nodiscard]] rc is_r(fs::path const& fpath) noexcept;

[[nodiscard]] rc mkdir(fs::path const&  dpath,
                       fs::perms const& perms = fs::perms::group_all,
                       bool             force = false) noexcept;


} // namespace wndx::sane::file
