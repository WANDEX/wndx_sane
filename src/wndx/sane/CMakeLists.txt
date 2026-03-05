
target_sources(sane_src
  PRIVATE
    file.cpp
    ll.cpp
    log.cpp
    path.cpp
)

## to make sane_deps target archive not empty, for the macOS =>
## will not compile static library without objects in archive.
## PUBLIC to propagate on depending targets for the same reason.
target_sources(sane_deps PUBLIC ll.cpp)

