#pragma once
/// Unix signals related code headers
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


// clang-format off
/// exclude code from the build on not supported platforms:
#ifndef _WIN32

/// enum class SIG with fmt format specialization
#include "sig_to_str.hpp"  // IWYU pragma: keep

#include "sig_handler.hpp" // IWYU pragma: keep

#endif//_WIN32
// clang-format on
