
#include "wndx/sane/aliases.hpp" // IWYU pragma: keep

#include "wndx/sane/file.hpp"

#include <filesystem>
#include <system_error> // ec - error_code


namespace wndx::sane::file {

/**
 * @brief check that the file is regular file.
 *
 * @param  fpath - file path to the file.
 * @return 0 on success or return code based on the failed check.
 */
[[nodiscard]] rc is_r(fs::path const& fpath) noexcept
{
  static constexpr auto fn{ "file::is_r()" };
  std::error_code       ec{};
  fs::file_status       s{ fs::status(fpath, ec) }; // for the noexcept
  if (ec) {
    WNDX_LOG(LL::CRIT, "{} {} fs::status error v:{} m:{}\n", fn, fpath.c_str(),
             ec.value(), ec.message());
    return rc::FILE_STATUS_GENERIC_ERRO;
  }
  if (!fs::is_regular_file(s)) {
    WNDX_LOG(LL::ERRO, "{} is NOT a regular file: {}\n", fn, fpath.c_str());
    return rc::FILE_SPECIAL;
  }
  WNDX_LOG(LL::INFO, "{} is a regular file: {}\n", fn, fpath.c_str());
  // TODO: check file permissions (maybe it is a good idea to have)
  return rc::SUCCESS;
}

/**
 * @brief make dir and set required perms. (should be safe)
 *
 * @param  new dir path.
 * @param  new dir permissions.
 * @param  force/insist on importance of the access rights to the dir.
 * @return 0 on success, else non zero return code.
 */
[[nodiscard]] rc mkdir(fs::path const& dpath, fs::perms const& perms,
                       bool force) noexcept
{
  static constexpr auto fn{ "file::mkdir()" };
  std::error_code       ec{};
  fs::path const        npath{ wndx::sane::path::trim(dpath) };
  fs::path const        parent_dir{ npath.parent_path() };
  if (fs::is_directory(npath, ec)) {
    WNDX_LOG(LL::DBUG, "{} Directory exist, and will be used as is\n", fn);
    if (force) {
      // TODO: validate that directory permissions are set as requested.
    }
  } else {
    if (!fs::exists(npath, ec)) { // expected branch
      if (fs::create_directory(npath, parent_dir, ec)) {
        fs::permissions(npath, perms, ec);
        if (ec.value() == 0) {
          WNDX_LOG(
              LL::NTFY,
              "{} Created new directory with requested access permissions.\n",
              fn);
        } else {
          WNDX_LOG(
              LL::ERRO,
              "{} Created new directory, but failed to set requested perms.\n",
              fn);
          if (fs::remove(npath, ec)) {
            WNDX_LOG(
                LL::NTFY,
                "{} Removed empty directory created with incorrect perms.\n",
                fn);
            return rc::FILE_RM_DIR_EMPTY_SUCCESS;
          } else {
            WNDX_LOG(LL::CRIT,
                     "{} {}\n^ failed to remove this dir\n"
                     "that was created with incorrect access rights.\n"
                     "Because of the perms, do it yourself manually!\n"
                     "Additionally take a look at the origin of the error:\n"
                     "v:{} m:{}\n",
                     fn, npath.c_str(), ec.value(), ec.message());
            return rc::FILE_RM_DIR_PERMS_ERRO;
          }
        }
      } else {
        WNDX_LOG(LL::CRIT,
                 "{} If your intent was to make this dir under current cwd:\n"
                 "{}\n^ precede your path with './' i.e. ./{}\n"
                 "Additionally take a look at the origin of the error:\n"
                 "fs::create_directory error:\nv:{} m:{}\n",
                 fn, npath.c_str(), npath.c_str(), ec.value(), ec.message());
        return rc::FILE_MKDIR_GENERIC_ERRO;
      }
    } else { // path already exist
      auto realpath{ fs::canonical(npath, ec) };
      if (ec) {
        WNDX_LOG(LL::CRIT, "{} {}\n^ canonical path error:\nv:{} m:{}\n", fn,
                 npath.c_str(), ec.value(), ec.message());
        return rc::FILE_PATH_CANONICAL_ERRO;
      }
      WNDX_LOG(LL::CRIT, "{} {}\n^ path cannot be used as the new directory!\n",
               fn, realpath.c_str());
      return rc::FILE_PATH_UNEXPECTED_ERRO;
    }
  }
  return rc::SUCCESS;
}

} // namespace wndx::sane::file
