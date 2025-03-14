## fmt fetch
## XXX: prefer fmtlib version installed in the system || fetch if not found

cmake_path(APPEND dep_dir ${PROJECT_BINARY_DIR} "3rdparty")

cmake_path(APPEND fmt_dir ${dep_dir} "fmt") # lib dir root
cmake_path(APPEND fmt_sub ${fmt_dir} "sub")
cmake_path(APPEND fmt_src ${fmt_dir} "src")
cmake_path(APPEND fmt_bin ${fmt_dir} "bin")

# find_package(fmt 9.1.0)
# if(NOT fmt_FOUND)
if(TRUE)
    message(">> fetching fmt of required version!")
    include(FetchContent)
    FetchContent_Declare(fmt
        GIT_REPOSITORY   https://github.com/fmtlib/fmt.git
        GIT_TAG          9.1.0
        SUBBUILD_DIR     ${fmt_sub}
        SOURCE_DIR       ${fmt_src}
        BINARY_DIR       ${fmt_bin}
    )
    # option(FMT_INSTALL "" ON)
    option(FMT_OS "" OFF)
    FetchContent_MakeAvailable(fmt)
else()
    message(">> found fmt of required version!")
endif()

target_include_directories(wndx_sane_deps PUBLIC "${fmt_src}/include")

## link with the static library libfmtd.a
## which is found in the fetched locally lib dir.
target_link_libraries(wndx_sane_deps PRIVATE -L"${fmt_bin}" -lfmtd)

