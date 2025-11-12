#pragma once
// Logger class common for the both targets: client & daemon

#include "ll.hpp" // LL enum and its string format specialization

#include "aliases.hpp"
#include "config.hpp"

#include <fmt/core.h>
#include <fmt/format.h>

#include <string_view>


namespace wndx {

class Logger final
{
public:
  Logger() = default;
  Logger(Logger &&) = default;
  Logger(const Logger &) = default;
  Logger &operator=(Logger &&) = default;
  Logger &operator=(const Logger &) = default;
  ~Logger() noexcept;

  explicit Logger(fs::path const& log_fpath) noexcept;

private:
  /**
   * @brief trace with message content - line: file.
   * for the messages of specific log level (LL:WARN, LL::ERRO, LL:CRIT).
   */
  void trace_to_the_file(
      char const* file, int line, LL ll);

  void vlog(
      char const* file, int line, LL ll,
      fmt::string_view fmt, fmt::format_args args);

public:
  template <typename... Args>
  void log(
      const char* file, int line, LL ll,
      fmt::format_string<Args...> fmt, Args&&... args)
  {
    if (m_urgency_level > ll) {
      return;
    }
    vlog(file, line, ll, fmt, fmt::make_format_args(args...));
  }

public:
  [[nodiscard]] fs::path
  get_log_fpath() noexcept;

  [[nodiscard]] LL
  get_urgency() noexcept;

  void set_urgency(LL ll) noexcept;

  /**
   * @brief specific log message format for the errno.
   * 'https://en.cppreference.com/w/cpp/error/errno'
   */
  void errnum(int errnum, std::string_view msg) noexcept;

private:
  fs::path m_log_fpath     { cfg::log_fpath };
  LL       m_urgency_level { cfg::urgency   };
};

/**
 * defined here for convenience => be able to use it in other files/functions ->
 * without the need to pass it into every single function as the extra argument.
 * (usually logger is needed for the whole life of the program anyway!) */
inline Logger log_g {};

} // namespace wndx

#ifndef WNDX_LOG
#define WNDX_LOG(LL, ...) \
wndx::log_g.log(__FILE__, __LINE__, LL, __VA_ARGS__)
#endif//WNDX_LOG

