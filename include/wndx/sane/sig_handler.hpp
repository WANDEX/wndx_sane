#pragma once

#include <string_view>

namespace wndx::sane::sig {

void print(int sig, std::string_view extra_msg);

void handlers(int sig);

void handlers_set_defaults(void (*handler)(int sig));

} // namespace wndx::sane::sig
