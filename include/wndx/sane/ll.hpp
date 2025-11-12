#pragma once
// Log Level message urgency.

#include <fmt/base.h>


namespace wndx {

// Log Level - log msg have Log Level.
// The higher the level, the fewer messages.
enum class LL
{
  DBUG = 1, // DEBUG
  INFO,     // INFO
  STAT,     // STATUS
  NTFY,     // NOTIFY
  WARN,     // WARNING
  ERRO,     // ERROR
  CRIT,     // CRITICAL
};

} // namespace wndx

// NOTE: fmt demands to specialize/declare this here!
// [template_spec_redecl_out_of_scope].
// @brief format enum log levels in the readable text form.
template <> struct
fmt::formatter<wndx::LL>: formatter<string_view>
{ // parse is inherited from formatter<string_view>.
  auto format(wndx::LL ll, format_context& ctx) const
    -> format_context::iterator;
};

