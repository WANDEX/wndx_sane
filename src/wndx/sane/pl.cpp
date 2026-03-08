/// platform specific cross-platform compatibility/safety code.

#include "wndx/sane/pl.hpp"


namespace wndx::sane {

/// \brief platform specific exit - clean, thread safe.
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
