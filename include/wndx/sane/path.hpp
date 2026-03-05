#pragma once

#include "aliases.hpp" // IWYU pragma: keep


namespace wndx::sane::path {

[[nodiscard]] fs::path trim(fs::path const& path) noexcept;

[[nodiscard]] fs::path sanitize(fs::path const& path) noexcept;

} // namespace wndx::sane::path
