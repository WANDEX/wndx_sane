#pragma once
/// platform specific cross-platform compatibility/safety code.

#if defined(_WIN32)
/// https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess
#include <processthreadsapi.h> // ExitProcess()
#elif defined(__linux__) || defined(__APPLE__)
/// https://www.man7.org/linux/man-pages/man2/exit.2.html
#include <unistd.h>            // _exit()
#else
/// https://en.cppreference.com/w/cpp/header/cstdlib.html
#include <cstdlib>             // std::exit, EXIT_FAILURE
#endif

// clang-format off
/// implementation defined!
/// https://en.cppreference.com/w/cpp/utility/program/EXIT_status.html
#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif//EXIT_FAILURE
///
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif//EXIT_SUCCESS
// clang-format on

namespace wndx::sane {

/// \brief platform specific exit - clean, thread safe.
void exit(int status);

} // namespace wndx::sane
