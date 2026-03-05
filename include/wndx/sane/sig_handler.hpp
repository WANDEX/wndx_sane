#pragma once

#include <string_view>

namespace wndx::sane::sig {

void print(int sig, std::string_view extra_msg);

void handler(int sig);

void handler_set(void (*handler)(int sig));

void handler();

} // namespace wndx::sane::sig
