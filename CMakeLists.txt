cmake_minimum_required(VERSION 3.19)

## ^ POLICIES
project(
    wndx_sane
    VERSION       0.0.0.1
    LANGUAGES     C CXX
    DESCRIPTION   ""
    HOMEPAGE_URL  "https://github.com/WANDEX/wndx_sane"
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

## GUARD: check the real root of the source tree.
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(WNDX_SANE_REAL_ROOT_OF_SRC_TREE ON)
else()
    set(WNDX_SANE_REAL_ROOT_OF_SRC_TREE OFF)
    ## library targets & compilation options/flags
    include(cmake/comp_opts_cxx.cmake)
    ## find/fetch dependecies:
    include(cmake/fmt.cmake)
    add_subdirectory(src)
endif()

if(WNDX_SANE_REAL_ROOT_OF_SRC_TREE)
    option(WNDX_SANE_BUILD_TESTS      "whether or not tests should be built"        OFF) # TODO: UNIMPLEMENTED
    option(WNDX_SANE_BUILD_PACKAGE    "whether or not the package should be built"  ON)
    option(WNDX_SANE_COVERAGE_ENABLE  "whether or not to enable the tests coverage" OFF)
    option(WNDX_SANE_COVERAGE_CLEAN   "clean coverage data before taking new"       ON)
    option(WNDX_SANE_MEMCHECK_ENABLE  "detect leaks via valgrind memcheck tool"     OFF)
    option(WNDX_SANE_SNTZ_ADDR        "whether or not to enable address sanitizer"  OFF) # TODO: UNIMPLEMENTED

    ## For the list of supported compilers visit:
    ## https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_WARNING_AS_ERROR.html
    option(CMAKE_COMPILE_WARNING_AS_ERROR "treat compilation warnings as errors"  OFF)

    ## library targets & compilation options/flags
    include(cmake/comp_opts_cxx.cmake)
    ## find/fetch dependecies:
    include(cmake/fmt.cmake)
    add_subdirectory(src)

    if(WNDX_SANE_BUILD_PACKAGE)
        set(package_files include/ src/ cmake/ CMakeLists.txt LICENSE)
        set(fpath_zip ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-src.zip)
        add_custom_command(
            OUTPUT  ${fpath_zip}
            COMMAND ${CMAKE_COMMAND} -E tar c ${fpath_zip} --format=zip -- ${package_files}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            DEPENDS ${package_files}
        )
        add_custom_target(${PROJECT_NAME}_package DEPENDS ${fpath_zip})
    endif(WNDX_SANE_BUILD_PACKAGE)

    if(WNDX_SANE_COVERAGE_ENABLE)
        if(${GNU_COMP})
            add_library(code_coverage INTERFACE)
            ## NOTE: without optimizations
            ## => other optimization levels/options obviously ruin coverage report.
            target_compile_options(code_coverage INTERFACE -g -O0 --coverage)
            target_link_options(code_coverage INTERFACE --coverage)

            if(WNDX_SANE_COVERAGE_CLEAN)
                ### before taking new coverage analysis data:
                ## find all coverage files in the project binary dir
                file(GLOB_RECURSE prev_cov_files LIST_DIRECTORIES false
                    ABSOLUTE "${PROJECT_BINARY_DIR}" *.gcda) # XXX *.gcno
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

    if(WNDX_SANE_BUILD_TESTS)
        ## prefer GoogleTest version installed in the system || fetch if not found
        include(cmake/gtest.cmake)
        add_subdirectory(tests/units)
    endif(WNDX_SANE_BUILD_TESTS)

    if(WNDX_SANE_MEMCHECK_ENABLE)
        set(dpath_units "${PROJECT_BINARY_DIR}/tests/units")
        add_custom_target(memcheck
            COMMAND valgrind --tool=memcheck -s --leak-check=full --show-leak-kinds=all
            --error-exitcode=73 # --exit-on-first-error=yes
            -- ./tests_units --gtest_brief=1
            WORKING_DIRECTORY "${dpath_units}"
            DEPENDS tests_units
        )
    endif(WNDX_SANE_MEMCHECK_ENABLE)
endif(WNDX_SANE_REAL_ROOT_OF_SRC_TREE)

