/// Logger using fmtlib impl.

#include "wndx/sane/log.hpp"

// clang-format off
#ifndef WNDX_LOG_INLINE_BUFFER_SIZE
#define WNDX_LOG_INLINE_BUFFER_SIZE 250
#endif//WNDX_LOG_INLINE_BUFFER_SIZE
// clang-format on


namespace wndx::sane {

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

[[nodiscard]] fs::path Logger::get_log_fpath() noexcept { return m_log_fpath; }

[[nodiscard]] LL Logger::get_urgency() noexcept { return m_urgency_level; }

void Logger::set_urgency(LL ll) noexcept
{
  m_urgency_level = ll;
  WNDX_LOG(LL::NTFY, "forced urgency level = {}\n", ll);
}

/// \brief cross-platform, thread-safe alternative to the std::strerror.
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

} // namespace wndx::sane
