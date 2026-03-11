#pragma once
/// Log Level message urgency.
/// And preprocessor directives related to fmt specialization.

#include <fmt/base.h>

// clang-format off
#ifndef WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
#define WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT 0
#endif//WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT

#ifndef WNDX_LOG_OSTREAM_SUPPORT
#define WNDX_LOG_OSTREAM_SUPPORT 1
#endif//WNDX_LOG_OSTREAM_SUPPORT

#if defined(_WIN32) || WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
/// \brief fmt support exotic char types.
/// especially WIN32 specific fs::path type:
/// std::filesystem::path::value_type* (wchar_t*)
/// \see https://github.com/fmtlib/fmt/issues/2363
#include <fmt/xchar.h>
#endif

#if     WNDX_LOG_OSTREAM_SUPPORT
#include <ostream>
#endif//WNDX_LOG_OSTREAM_SUPPORT
// clang-format on


namespace wndx::sane {

/// \brief Log Level - log msg have Log Level.
/// The higher the level, the fewer messages.
enum class LL // NOLINT(performance-enum-size)
{
  DBUG = 1,   // DEBUG
  INFO,       // INFO
  STAT,       // STATUS
  NTFY,       // NOTIFY
  WARN,       // WARNING
  ERRO,       // ERROR
  CRIT,       // CRITICAL
};

} // namespace wndx::sane

/// \brief format enum log levels in the readable text form.
/// NOTE: fmt demands to specialize/declare this here!
/// [template_spec_redecl_out_of_scope].
template <>
struct fmt::formatter<wndx::sane::LL> : formatter<string_view>
{
  auto format(wndx::sane::LL ll, format_context& ctx) const
      -> format_context::iterator;
};

#if WNDX_LOG_OSTREAM_SUPPORT
/// overload std::ostream (to output Log Level as text)
std::ostream& operator<<(std::ostream& os, wndx::sane::LL ll);
#endif // WNDX_LOG_OSTREAM_SUPPORT
