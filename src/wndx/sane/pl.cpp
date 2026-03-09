/// platform specific cross-platform compatibility/safety code.

#include "wndx/sane/pl.hpp"


namespace wndx::sane {

/// \brief platform specific exit - clean, thread safe.
///
/// \see:
///   https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess
///   https://www.man7.org/linux/man-pages/man2/exit.2.html
///   https://en.cppreference.com/w/cpp/header/cstdlib.html
/// other ref:
///   https://pubs.opengroup.org/onlinepubs/7908799/xsh/_exit.html
///   https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/exit-exit-exit?view=msvc-170
void exit(int status)
{
#if defined(_WIN32)
  ExitProcess(static_cast<unsigned int>(status)); // UINT
#elif defined(__linux__) || defined(__APPLE__)
  _exit(status);
#else // fallback for not explicitly specified platforms
  std::exit(status); // NOLINT(concurrency-mt-unsafe)
#endif
}

} // namespace wndx::sane
