#pragma once
/// Unix signals related code headers


// clang-format off
/// exclude code from the build on not supported platforms:
#ifndef _WIN32

/// enum class SIG with fmt format specialization
#include "sig_to_str.hpp"  // IWYU pragma: keep

#include "sig_handler.hpp" // IWYU pragma: keep

#endif//_WIN32
// clang-format on
