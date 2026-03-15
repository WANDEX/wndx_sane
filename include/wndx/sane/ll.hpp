#pragma once
/// Log Level message urgency.
/// And preprocessor directives related to fmt specialization.

// clang-format off
#ifndef WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
#if defined(_WIN32)
#define WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT 1
#else
#define WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT 0
#endif
#endif//WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT

#ifndef WNDX_LOG_OSTREAM_SUPPORT
#define WNDX_LOG_OSTREAM_SUPPORT 1
#endif//WNDX_LOG_OSTREAM_SUPPORT

#include <fmt/format.h>
#if     WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
/// \brief fmt support exotic char types.
/// especially WIN32 specific fs::path type:
/// std::filesystem::path::value_type* (wchar_t*)
/// \see https://github.com/fmtlib/fmt/issues/2363
#include <fmt/xchar.h>
#endif//WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT

#include <filesystem>

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
template <>
struct fmt::formatter<wndx::sane::LL> : formatter<string_view>
{
  auto format(wndx::sane::LL ll, format_context& ctx) const
      -> format_context::iterator;
};

/// \brief format fs::path as utf-8 (uniform & cross-platform).
// template <>
// struct fmt::formatter<std::filesystem::path> : formatter<std::u8string_view>
// {
// auto format(std::filesystem::path const& p, format_context& ctx) const
// -> format_context::iterator;
// };

/// \brief format fs::path as string.
template <>
struct fmt::formatter<std::filesystem::path> : formatter<string_view>
{
  auto format(std::filesystem::path const& p, format_context& ctx) const
      -> format_context::iterator;
};

#if WNDX_LOG_OSTREAM_SUPPORT
/// overload for std::ostream (to output as text).
std::ostream& operator<<(std::ostream& os, wndx::sane::LL ll);

/// overload for std::ostream (to output as text).
std::ostream& operator<<(std::ostream& os, std::filesystem::path const& p);
#endif // WNDX_LOG_OSTREAM_SUPPORT
