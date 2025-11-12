
#include "wndx/sane/ll.hpp"

#include <fmt/format.h>


auto fmt::formatter<wndx::LL>::format(wndx::LL ll, format_context& ctx) const
  -> format_context::iterator
{
  string_view name = "unknown";
  switch (ll) {
  case wndx::LL::DBUG: name = "DBUG"; break;
  case wndx::LL::INFO: name = "INFO"; break;
  case wndx::LL::STAT: name = "STAT"; break;
  case wndx::LL::NTFY: name = "NTFY"; break;
  case wndx::LL::WARN: name = "WARN"; break;
  case wndx::LL::ERRO: name = "ERRO"; break;
  case wndx::LL::CRIT: name = "CRIT"; break;
  }
  return formatter<string_view>::format(name, ctx);
}

#if WNDX_LOG_OSTREAM_SUPPORT
// overload std::ostream (to output Log Level as text)
std::ostream& operator<<(std::ostream& os, wndx::LL ll)
{
  return os << fmt::to_string(ll);
}
#endif//WNDX_LOG_OSTREAM_SUPPORT

