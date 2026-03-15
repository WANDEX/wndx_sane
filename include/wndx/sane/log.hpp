#pragma once
/// Logger using fmtlib.
///
/// \see why wchar_t is horrible and should not be used.
///   https://www.moria.us/articles/wchar-is-a-historical-accident/
///   https://losingfight.com/blog/2006/07/28/wchar_t-unsafe-at-any-size/
///   https://news.ycombinator.com/item?id=11084178
///   https://learn.microsoft.com/en-us/windows/win32/midl/wchar-t
///   https://en.cppreference.com/w/cpp/language/types.html#Character_types

#include "aliases.hpp" // IWYU pragma: keep
#include "ll.hpp"      // LL enum and its string format specialization


namespace wndx::sane {

class Logger final
{
public:
  Logger() noexcept                         = default;
  Logger(Logger&&) noexcept                 = default;
  Logger(Logger const&) noexcept            = default;
  Logger& operator=(Logger&&) noexcept      = default;
  Logger& operator=(Logger const&) noexcept = default;
  ~Logger() noexcept                        = default;

  explicit Logger(fs::path const log_fpath) noexcept;

private:
  /// \brief trace with message content - line: file.
  /// for the messages of specific log level (LL:WARN, LL::ERRO, LL:CRIT).
  static void trace_to_the_file(char const* file, int line, LL ll);

  /// \brief log.
  template <typename SV = fmt::string_view, // or fmt::wstring_view
            typename FA = fmt::format_args> // or fmt::wformat_args
  static void vlog(char const* file, int line, LL ll, SV fmt, FA args)
  {
    fmt::print(stderr, "[{}]: {}", ll, fmt::vformat(fmt, args));
    trace_to_the_file(file, line, ll);
  }

public:
  template <typename Char, typename... Args>
  void log(char const* file, int line, LL ll, fmt::basic_string_view<Char> fmt,
           Args&&... args) // NOLINT(*-forward)
  {
    if (m_urgency_level > ll) {
      return;
    }
#if WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
    if constexpr (fmt::detail::is_exotic_char<Char>::value) {
#ifdef warning
#warning "fixme - consider rewrite without using exotic char types."
#endif // warning || std::is_same_v<Char, wchar_t>
      using SV = fmt::wstring_view;
      using FA = fmt::wformat_args;
      vlog<SV, FA>(file, line, ll, fmt, fmt::make_wformat_args(args...));
    } else {
      using SV = fmt::string_view;
      using FA = fmt::format_args;
      vlog<SV, FA>(file, line, ll, fmt, fmt::make_format_args(args...));
    }
#else
    using SV = fmt::string_view;
    using FA = fmt::format_args;
    vlog<SV, FA>(file, line, ll, fmt, fmt::make_format_args(args...));
#endif // WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
  }

  /// \brief specialization for the standard fmt string / char type.
  template <typename... Args>
  void log(char const* file, int line, LL ll, fmt::format_string<Args...> fmt,
           Args&&... args) // NOLINT(*-forward)
  {
    log(file, line, ll, fmt::string_view{ fmt }, args...);
  }

#if WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT
  /// \brief specialization for the wide fmt string / wchar_t type etc.
  ///
  /// use of the wchar_t is highly discouraged!
  template <typename... Args>
  void log(char const* file, int line, LL ll, fmt::wformat_string<Args...> fmt,
           Args&&... args) // NOLINT(*-forward)
  {
    log(file, line, ll, fmt::wstring_view{ fmt }, args...);
  }
#endif // WNDX_LOG_EXOTIC_CHAR_TYPE_SUPPORT

  [[nodiscard]] fs::path get_log_fpath() noexcept;

  [[nodiscard]] LL get_urgency() noexcept;

  void set_urgency(LL ll) noexcept;

  /// \brief specific log message format for the errno.
  static void errnum(int errnum, std::string_view msg) noexcept;

private:
  /// default (client UID / device MAC) unique to the client/device.
  sv_t     m_cli_uid{ "f000:f000:f000:f000:f000" };
  fs::path m_log_fpath{ "/tmp/wndx/logs/default.log" };
  LL       m_urgency_level{
#ifndef NDEBUG
    LL::DBUG // development level (all messages)
#else
    LL::NTFY // default for the standard use
#endif
  };
};

/// defined here for convenience => be able to use it in other files/functions,
/// without the need to pass into every single function as the extra argument
/// (usually logger is needed for the whole life of the program anyway!)
inline Logger log_g{}; // NOLINT(*-avoid-non-const-global-variables)

} // namespace wndx::sane

// NOLINTBEGIN(cppcoreguidelines-macro-usage)
#ifndef WNDX_LOG
#define WNDX_LOG(LL, ...) \
wndx::sane::log_g.log(__FILE__, __LINE__, LL, __VA_ARGS__)
#endif // WNDX_LOG
// NOLINTEND(cppcoreguidelines-macro-usage)
