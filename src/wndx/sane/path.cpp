
#include "wndx/sane/path.hpp"


namespace wndx::sane::path {

/// \brief trim trailing separators.
/// any path provided by the user may contain a trailing separator - trim it!
[[nodiscard]] fs::path trim(fs::path const& path) noexcept
{
  fs::path npath{ path };
  // additional trailing directory separators are never introduced
  npath += fs::path::preferred_separator;
  return npath.parent_path(); // safely remove trailing separators
}

[[nodiscard]] fs::path sanitize(fs::path const& path) noexcept
{
  return trim(path);
}

} // namespace wndx::sane::path
