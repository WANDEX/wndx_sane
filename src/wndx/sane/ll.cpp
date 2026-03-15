
#include "wndx/sane/ll.hpp"


auto fmt::formatter<wndx::sane::LL>::format(wndx::sane::LL ll, format_context& ctx) const
    -> format_context::iterator
{
  string_view name = "unknown";
  switch (ll) {
  case wndx::sane::LL::DBUG: name = "DBUG"; break;
  case wndx::sane::LL::INFO: name = "INFO"; break;
  case wndx::sane::LL::STAT: name = "STAT"; break;
  case wndx::sane::LL::NTFY: name = "NTFY"; break;
  case wndx::sane::LL::WARN: name = "WARN"; break;
  case wndx::sane::LL::ERRO: name = "ERRO"; break;
  case wndx::sane::LL::CRIT: name = "CRIT"; break;
  }
  return formatter<string_view>::format(name, ctx);
}

// auto fmt::formatter<std::filesystem::path>::format(std::filesystem::path const& p, format_context& ctx) const
    // -> format_context::iterator
// {
  // return format_to(ctx.out(), "{}", p.u8string()); // XXX
  // return formatter<std::u8string_view>::format(p.u8string(), ctx);
// }

auto fmt::formatter<std::filesystem::path>::format(std::filesystem::path const& p, format_context& ctx) const
    -> format_context::iterator
{
  return formatter<string_view>::format(p.string(), ctx);
}

#if WNDX_LOG_OSTREAM_SUPPORT
std::ostream& operator<<(std::ostream& os, wndx::sane::LL ll)
{
  return os << fmt::to_string(ll);
}

std::ostream& operator<<(std::ostream& os, std::filesystem::path const& p)
{
  return os << fmt::to_string(p);
}
#endif // WNDX_LOG_OSTREAM_SUPPORT
