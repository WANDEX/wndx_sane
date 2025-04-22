cmake_minimum_required(VERSION 3.23)

## ^ POLICIES
project(
  wndx_sane
  VERSION       0.0.2
  LANGUAGES     CXX
  # LANGUAGES     C CXX # XXX
  DESCRIPTION   ""
  HOMEPAGE_URL  "https://github.com/WANDEX/wndx_sane"
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(WNDX_SANE_DISABLE_TOP_PROJECT OFF)
if(PROJECT_IS_TOP_LEVEL AND NOT WNDX_SANE_DISABLE_TOP_PROJECT)
  set(WNDX_SANE_IS_TOP_PROJECT ON)
else()
  set(WNDX_SANE_IS_TOP_PROJECT OFF)
endif()

## search path for cmake modules to be loaded by: include() find_package().
## NOTE: works properly only if defined at the top-level CMakeLists.txt.
list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ## project modules
)

function(targets_and_linking)
  include(wndx_sane_modules)
  include(wndx_sane_create_targets)
  ## library targets & compilation options/flags
  wndx_sane_create_targets(PFX wndx LIB sane
    CXX_STD cxx_std_20
    PHD "include/wndx/sane"
  )

  ## link core library with the libc -lc (to work with the BSD API: socket, signal)
  # target_link_libraries(sane_core INTERFACE c) # XXX: project is linking to libc by itself

  ## link sources with project dependencies from the core library target
  target_link_libraries(sane_src INTERFACE wndx::sane::core)

  ## link sources with project dependencies
  target_link_libraries(sane_src PUBLIC wndx::sane::deps)

  ## link sources with project dev interface (for the compilation flags/options)
  target_link_libraries(sane_src PRIVATE wndx::sane::dev)

  if(WNDX_SANE_BUILD_SRC OR NOT WNDX_SANE_IS_TOP_PROJECT)
    ## find/fetch dependencies:
    find_package(fmt REQUIRED)
    add_subdirectory(src/wndx/sane)
  endif()
endfunction(targets_and_linking)

if(NOT WNDX_SANE_IS_TOP_PROJECT)
  targets_and_linking()
endif()

if(WNDX_SANE_IS_TOP_PROJECT)
  option(WNDX_SANE_BUILD_SRC        "whether or not src should be built"          ON)
  option(WNDX_SANE_BUILD_TESTS      "whether or not tests should be built"        OFF) # TODO: UNIMPLEMENTED
  option(WNDX_SANE_BUILD_PACKAGE    "whether or not the package should be built"  ON)
  option(WNDX_SANE_COVERAGE_ENABLE  "whether or not to enable the tests coverage" OFF)
  option(WNDX_SANE_COVERAGE_CLEAN   "clean coverage data before taking new"       ON)
  option(WNDX_SANE_INSTALL_ENABLE   "whether or not to enable the install rule"   ON)
  option(WNDX_SANE_MEMCHECK_ENABLE  "detect leaks via valgrind memcheck tool"     OFF)
  option(WNDX_SANE_SNTZ_ADDR        "whether or not to enable address sanitizer"  OFF) # TODO: UNIMPLEMENTED

  ## for the list of supported compilers visit:
  ## https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_WARNING_AS_ERROR.html
  option(CMAKE_COMPILE_WARNING_AS_ERROR "treat compilation warnings as errors"  OFF)

  ## output dir is correct by default for most build setups.
  ## however, when building lib as a DLL, it is important to have the DLL in the same dir
  ## as the executable using it. Thus, we put all executables in a single /bin dir.
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
  ## On macOS, property ignored for the linker import files
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

  targets_and_linking()

  if(WNDX_SANE_BUILD_TESTS)
    find_package(gtest REQUIRED)
    add_subdirectory(tests/units)
  endif(WNDX_SANE_BUILD_TESTS)

  if(WNDX_SANE_BUILD_PACKAGE)
    include(wndx_sane_package)
    wndx_sane_package(TGT_NAME src_package FILES
      include/ src/ cmake/ CMakeLists.txt LICENSE README.md
    )
  endif(WNDX_SANE_BUILD_PACKAGE)

  if(WNDX_SANE_COVERAGE_ENABLE)
    if(${GNU_COMP})
      add_library(code_coverage INTERFACE)
      add_dependencies(code_coverage tests_units)
      ## NOTE: without optimizations
      ## => other optimization levels/options obviously ruin coverage report.
      target_compile_options(code_coverage INTERFACE -g -O0 --coverage)
      target_link_options(code_coverage INTERFACE --coverage)
      if(WNDX_SANE_COVERAGE_CLEAN)
        ### before taking new coverage analysis data:
        ## find all coverage files in the project binary dir
        file(GLOB_RECURSE prev_cov_files LIST_DIRECTORIES false
          ABSOLUTE "${CMAKE_BINARY_DIR}" *.gcda) # XXX *.gcno
        ## clean from the previous coverage data files (if any)
        if(NOT prev_cov_files STREQUAL "")
          file(REMOVE ${prev_cov_files})
          message(NOTICE ">> Cleared of previous coverage data files.")
        else()
          message(NOTICE ">> Nothing to clean up. (no coverage data files found)")
        endif()
      endif(WNDX_SANE_COVERAGE_CLEAN)
      message(NOTICE ">> Code Coverage will be collected!")
    else()
      message(WARNING "Code Coverage analysis enabled only on the GNU/GCC toolchain!")
    endif()
  endif(WNDX_SANE_COVERAGE_ENABLE)

  if(WNDX_SANE_MEMCHECK_ENABLE)
    add_custom_target(memcheck
      COMMAND valgrind --tool=memcheck -s --leak-check=full --show-leak-kinds=all
                      --error-exitcode=73 # --exit-on-first-error=yes
                      -- ./tests_units --gtest_brief=1
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
      DEPENDS tests_units
    )
    add_dependencies(memcheck tests_units)
  endif(WNDX_SANE_MEMCHECK_ENABLE)

  if(WNDX_SANE_INSTALL_ENABLE)
    include(wndx_sane_install)
    wndx_sane_install(
      TARGETS
        # _sane_base sane_core sane_dev
        # sane_deps sane_src
        sane
      PATTERNS "*.hpp"
    )
  endif(WNDX_SANE_INSTALL_ENABLE)
endif(WNDX_SANE_IS_TOP_PROJECT)

