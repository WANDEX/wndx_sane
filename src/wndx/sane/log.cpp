// Logger implementation

#include "wndx/sane/log.hpp"

#include "wndx/sane/aliases.hpp" // IWYU pragma: keep

#include <fmt/core.h>
#include <fmt/format.h>

#include <utility>


// clang-format off
// toggle showing of the line number : file path
#ifndef WNDX_LOG_TRACE_TO_THE_FILE
#define WNDX_LOG_TRACE_TO_THE_FILE 1
#endif//WNDX_LOG_TRACE_TO_THE_FILE

#ifndef WNDX_LOG_INLINE_BUFFER_SIZE
#define WNDX_LOG_INLINE_BUFFER_SIZE 250
#endif//WNDX_LOG_INLINE_BUFFER_SIZE
// clang-format on


namespace wndx {

Logger::Logger(fs::path log_fpath) noexcept
    : m_log_fpath{ std::move(log_fpath) }
{
}

void Logger::trace_to_the_file(char const* file, int line, LL ll)
{
  if (ll < LL::WARN) {
    return;
  }
  fmt::print(stderr, "{:>6}: \"{}\"\n", line, file);
}

void Logger::vlog(char const* file, int line, LL ll, fmt::string_view fmt,
                  fmt::format_args args)
{
  fmt::print(stderr, "[{}]: {}", ll, fmt::vformat(fmt, args));
  // TODO: also write message into the log file.
  // XXX : maybe use this?
  // https://github.com/PlatformLab/NanoLog
#if WNDX_LOG_TRACE_TO_THE_FILE
  trace_to_the_file(file, line, ll);
#else // portable fix: warning: unused parameter [-Wunused-parameter]
  (void)file;
  (void)line;
#endif
}

[[nodiscard]] fs::path Logger::get_log_fpath() noexcept { return m_log_fpath; }

[[nodiscard]] LL Logger::get_urgency() noexcept { return m_urgency_level; }

void Logger::set_urgency(LL ll) noexcept
{
  m_urgency_level = ll;
  WNDX_LOG(LL::NTFY, "forced urgency level = {}\n", ll);
}

/**
 * @brief cross-platform, thread-safe alternative to the std::strerror.
 */
[[nodiscard]] static auto strerror(int errnum) noexcept
{
  fmt::basic_memory_buffer<char, WNDX_LOG_INLINE_BUFFER_SIZE> obuf;
  fmt::format_system_error(obuf, errnum, "");
  return fmt::to_string(obuf);
}

void Logger::errnum(int errnum, std::string_view msg) noexcept
{
  WNDX_LOG(LL::CRIT, "{}\n\terrno: {}\n", msg, strerror(errnum));
}

} // namespace wndx
