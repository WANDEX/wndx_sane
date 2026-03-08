/// handler of the system signals.
/// main purpose of which -> finish program gracefully (correctly)
/// upon receiving one of the known signals.
///
/// The default action for an unhandled real-time signal is
/// to terminate the receiving process.
/// ref: signal(7) https://man7.org/linux/man-pages/man7/signal.7.html
///
/// other relevant refs:
/// https://pubs.opengroup.org/onlinepubs/7908799/xsh/unistd.h.html
/// https://pubs.opengroup.org/onlinepubs/7908799/xsh/_exit.html
/// https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/exit-exit-exit?view=msvc-170

#include "wndx/sane/aliases.hpp" // IWYU pragma: keep

#include "wndx/sane/pl.hpp"
#include "wndx/sane/sig.hpp" // IWYU pragma: keep

#include <csignal>           // IWYU pragma: keep | sigaction, SIGRTMAX
#include <string_view>

// clang-format off
#ifndef SIGRTMAX
/// Darwin macOS see: https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/signal.h
#define SIGRTMAX 32
#ifdef  warning
#warning "<signal.h> does not provide SIGRTMAX, assuming SIGRTMAX=32"
#endif//warning
#endif//SIGRTMAX
// clang-format on


namespace wndx::sane::sig {

static constexpr auto fmt{ "\nSIG {:2}: [{}] {} {}\n\n" };

void print(LL ll, int sig, std::string_view const extra_msg)
{
  WNDX_LOG(ll, fmt, sig, SIG{ sig }, "received.", extra_msg);
}

void print(int sig, std::string_view const extra_msg)
{
  WNDX_LOG(LL::NTFY, fmt, sig, SIG{ sig }, "received.", extra_msg);
}

/// ref: sigaction(2), sigaction(3p)
/// SIGKILL or SIGSTOP "cannot be caught or ignored",
/// ancestors probably meant: should not be caught and ignored!?.
/// So that even the most disgusting program can be killed etc.
void handlers(int sig)
{
  switch (SIG{ sig }) {
  // default behavior for the all not explicitly handled signals =>
  // print caught signal and finish program gracefully.
  default: print(sig, "FINISH HIM!");
  }
}

/// \brief set the handler function as the handler for all possible signals.
/// (except SIGKILL & SIGSTOP) ref: sigaction(2), signal(2), signal(7).
/// descriptions took from the signal(7).
void handlers_set_defaults(void (*handler)(int sig))
{
  struct sigaction siga{};
  siga.sa_handler = handler;
  for (int sig = 1; sig < SIGRTMAX; sig++) {
    // skip / do not install handlers on the specific signals:
    switch (SIG{ sig }) {      // NOLINTNEXTLINE(bugprone-branch-clone)
    case SIG::WTF32: continue; // ? Attach to a running process for debug?
    case SIG::WTF33: continue; // ?
    case SIG::TRAP : continue; // Trace/breakpoint trap
    case SIG::KILL : continue; // Kill signal  (should not be caught)
    case SIG::CONT : continue; // Continue if stopped
    case SIG::STOP : continue; // Stop process (should not be caught)
    case SIG::TSTP : continue; // Stop typed at terminal
    case SIG::TTIN : continue; // Term in  for background process
    case SIG::TTOU : continue; // Term out for background process Ign signals
    case SIG::CHLD : continue; // Child stopped or terminated
    case SIG::URG  : continue; // Urgent condition on socket
    case SIG::WINCH: continue; // Window resize signal (TERMINAL resize event)
    default        :;
    }
    // default in order to silence [-Wswitch].
    // And also, we do not want to list all members of the enum.
    // finish our program gracefully (correctly) on all other signals.
    if (sigaction(sig, &siga, nullptr) == -1) {
      print(sig, "-> FAILED to set handler for this system signal! EXIT.");
      wndx::sane::exit(EXIT_FAILURE);
    }
  }
}

} // namespace wndx::sane::sig
