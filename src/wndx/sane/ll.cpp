
#include "wndx/sane/ll.hpp"

#include <fmt/format.h>


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

#if WNDX_LOG_OSTREAM_SUPPORT
// overload std::ostream (to output Log Level as text)
std::ostream& operator<<(std::ostream& os, wndx::sane::LL ll)
{
  return os << fmt::to_string(ll);
}
#endif // WNDX_LOG_OSTREAM_SUPPORT
