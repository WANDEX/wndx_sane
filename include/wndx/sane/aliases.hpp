#pragma once
// project-wide type aliases

#include <cstdint>              // types, MIN/MAX, etc

#include <filesystem>
#include <string_view>

namespace wndx {

// @brief wrapper for forced computation at compile time.
// the destructor of the type used in the function must be constexpr.
inline consteval auto cmpl_time(auto value) { return value; }

namespace fs = std::filesystem; // NOLINT(misc-unused-alias-decls)

// easiest way to access the suffixes: s, sv, etc.
using namespace std::literals;

// alias for shortness & consistency across the project codebase.

using s8  = int8_t;
using s16 = int16_t;
using s32 = int32_t;
using s64 = int64_t;

using u8  = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

using sv_t = std::string_view;
using sz_t = std::size_t;

} // namespace wndx

/**
 * In the end of the file after defining project-wide aliases.
 * For the convenience:
 * To not include Logger declarations separately in each translation unit.
 */
#include "log.hpp"

