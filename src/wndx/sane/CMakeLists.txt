
target_sources(sane_src
  PRIVATE
    log.cpp
)

## XXX: only to make sane_deps target archive not empty =>
## AppleClang will not compile static library without objects in archive.
target_sources(sane_deps PRIVATE log.cpp)

