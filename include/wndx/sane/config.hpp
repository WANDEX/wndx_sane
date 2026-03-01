#pragma once

#include "aliases.hpp" // IWYU pragma: keep


namespace wndx::sane::cfg {

/// log urgency level
inline static constexpr LL urgency{
#ifndef NDEBUG
  LL::DBUG // development level (all messages)
#else
  LL::NTFY // default for the standard use
#endif
};

/// default log file path
inline static constexpr std::string_view log_fpath{
  "/tmp/wndx/logs/default.log"
};

/// default (client UID / device MAC) unique to the client/device.
inline static constexpr std::string_view def_uid{ "f000::f000:f000:f000:f000" };

} // namespace wndx::sane::cfg
