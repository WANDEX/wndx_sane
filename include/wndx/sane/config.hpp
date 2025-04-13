#pragma once

#include "aliases.hpp"

#include "log_level.hpp"

namespace wndx {
namespace cfg {

// log urgency level
// inline static constexpr LL urgency{ LL::NTFY }; // default for the basic users
inline static constexpr LL urgency{ LL::DBUG }; // development level (all messages)

// default log file path
inline static constexpr std::string_view log_fpath{ "/tmp/wndx/logs/default.log" };

// default (client UID / device MAC) unique to the client/device.
inline static constexpr std::string_view def_uid{ "f000::f000:f000:f000:f000" };

} // namespace cfg
} // namespace wndx

