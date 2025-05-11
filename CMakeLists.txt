cmake_minimum_required(VERSION 3.29)

## ^ POLICIES
project(
  wndx_sane
  VERSION       0.0.4
  LANGUAGES     CXX
  DESCRIPTION   "wndx::sane lib - handcrafted CMake modules, modern CMake targets"
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
  option(WNDX_SANE_BUILD_TESTS      "whether or not tests should be built"        OFF)
  option(WNDX_SANE_BUILD_PACKAGE    "whether or not the package should be built"  ON)
  option(WNDX_SANE_COVERAGE_ENABLE  "whether or not to enable the tests coverage" OFF)
  option(WNDX_SANE_COVERAGE_CLEAN   "clean coverage data before taking new"       ON)
  option(WNDX_SANE_INSTALL_ENABLE   "whether or not to enable the install rule"   ON)
  option(WNDX_SANE_MEMCHECK_ENABLE  "detect leaks via memcheck tool"              OFF)
  option(WNDX_SANE_SNTZ_ADDR        "whether or not to enable address sanitizer"  OFF) # TODO: UNIMPLEMENTED

  ## for the list of supported compilers visit:
  ## https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_WARNING_AS_ERROR.html
  option(CMAKE_COMPILE_WARNING_AS_ERROR "treat compilation warnings as errors"  OFF)

  ## output dir is correct by default for most build setups.
  ## however, when building lib as a DLL, it is important to have the DLL in the same dir
  ## as the executable using it. Thus, we put all executables in a single /bin dir.
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
  ## on macOS, property ignored for the linker import files
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

  targets_and_linking()

  if(WNDX_SANE_BUILD_TESTS)
    find_package(gtest REQUIRED)
    add_subdirectory(tests/units)
  endif(WNDX_SANE_BUILD_TESTS)

  if(WNDX_SANE_BUILD_PACKAGE)
    include(wndx_sane_package)
    wndx_sane_package(SUFFIX src FILES
      cmake/ include/ scripts/ src/ tests/ CMakeLists.txt LICENSE README.md
    )
  endif(WNDX_SANE_BUILD_PACKAGE)

  if(WNDX_SANE_COVERAGE_ENABLE)
    include(wndx_sane_coverage)
    wndx_sane_coverage(TGT_NAME code_coverage TGT_DEPS tests_units
      CLEAN WNDX_SANE_COVERAGE_CLEAN
    )
  endif(WNDX_SANE_COVERAGE_ENABLE)

  if(WNDX_SANE_MEMCHECK_ENABLE)
    include(wndx_sane_memcheck)
    wndx_sane_memcheck(TGT_NAME memcheck
      TGT_EXEC tests_units --gtest_brief=1
      # VALGRIND_OPTS --read-var-info=yes --show-leak-kinds=definite --track-origins=yes
      # EXIT_ON_FIRST_ERROR # valgrind only option
      # FORCE_DRMEMORY
    )
  endif(WNDX_SANE_MEMCHECK_ENABLE)

  if(WNDX_SANE_INSTALL_ENABLE)
    include(wndx_sane_install)
    wndx_sane_install(
      TARGETS
        # _sane_base sane_core sane_dev
        # sane_deps sane_src
        sane
      PHD "include/wndx/sane"
      PATTERNS "*.hpp"
    )
  endif(WNDX_SANE_INSTALL_ENABLE)
endif(WNDX_SANE_IS_TOP_PROJECT)

