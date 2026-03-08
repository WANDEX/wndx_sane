#pragma once
/// platform specific cross-platform compatibility/safety code.
///
/// ref: https://stackoverflow.com/a/22622250
/// __linux__       Defined on Linux
/// __sun           Defined on Solaris
/// __FreeBSD__     Defined on FreeBSD
/// __NetBSD__      Defined on NetBSD
/// __OpenBSD__     Defined on OpenBSD
/// __APPLE__       Defined on Mac OS X
/// __hpux          Defined on HP-UX
/// __osf__         Defined on Tru64 UNIX (formerly DEC OSF1)
/// __sgi           Defined on Irix
/// _AIX            Defined on AIX
/// _WIN32          Defined on Windows
///   https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170
///
/// Preprocessor macros are handled per translation unit.  Each .c/.cpp file
/// (plus headers it includes) is preprocessed independently. A #define
/// in one translation unit does not automatically propagate to others.
///
/// WIN32_LEAN_AND_MEAN - consider defining it globally for the whole project!
///   It is defined here (in the source/header) exactly for this purpose,
///   to not alter default behavior globally for all users of the library.
///   Such behavior may be unexpected and harmful for the projects which
///   do not include all required project headers manually, but rely on the
///   default behavior while they include one of the Windows OS API headers.
/// \see:
///   https://devblogs.microsoft.com/oldnewthing/20091130-00/?p=15863
///   https://news.ycombinator.com/item?id=36578047

// clang-format off
/// Clang on Windows is missing the Windows target architecture macro.
/// Windows SDK headers (winnt.h) require at least one of the target architectures
/// to be defined before including any Windows headers.
/// \see:
///   https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170
#ifdef  _MSC_VER // clang on Windows define _MSC_VER!
#ifndef _WIN32   // => define required missing defaults
#define _WIN32 1
#define _WIN64 1
#endif//_WIN32
#ifndef _M_AMD64
#define _M_AMD64 100
#define _M_X64 100
#endif//_M_AMD64
#endif//_MSC_VER

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
/// https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess
#include <processthreadsapi.h> // ExitProcess()
#elif defined(__linux__) || defined(__APPLE__)
/// https://www.man7.org/linux/man-pages/man2/exit.2.html
#include <unistd.h>            // _exit()
#else // fallback to stdlib (less res. cleaning, not thread safe, impl. defined)
/// https://en.cppreference.com/w/cpp/header/cstdlib.html
#include <cstdlib>             // std::exit, EXIT_FAILURE
#endif//SYSLIBS includes

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
