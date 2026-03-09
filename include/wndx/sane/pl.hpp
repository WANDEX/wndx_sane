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
///
/// #include <windows.h>
///   required to be included before all other WIN32 API headers!
///     otherwise -> winnt.h: #error: "No Target Architecture"
///
/// \see:
///   https://devblogs.microsoft.com/oldnewthing/20091130-00/?p=15863
///   https://news.ycombinator.com/item?id=36578047
///   https://stackoverflow.com/a/71591534 - order of includes matters!

// clang-format off
#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif//WIN32_LEAN_AND_MEAN
#include <windows.h>           // required before WIN32 API headers!
#include <processthreadsapi.h> // ExitProcess()
#elif defined(__linux__) || defined(__APPLE__)
#include <unistd.h>            // _exit()
#else // fallback to stdlib (less res. cleaning, not thread safe, impl. defined)
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
