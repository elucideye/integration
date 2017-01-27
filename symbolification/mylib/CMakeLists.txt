cmake_minimum_required(VERSION 3.3)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/Modules")

project(mylib VERSION 1.2.3)

##############

set(lib_name mylib)

add_library(${lib_name} SHARED mylib.cpp mylib.hpp)

include(split_debug_symbols)

##########
# use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH  FALSE)
# when building, don't use the install RPATH already
# (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(MYLIB_ORIGIN "$ORIGIN")
if (APPLE)
  set(MYLIB_ORIGIN "@loader_path")
endif()
set(CMAKE_INSTALL_RPATH "${MYLIB_ORIGIN}/../lib:${MYLIB_ORIGIN}/")
# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# the RPATH to be used when installing, but only if it's not a system directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif("${isSystemDir}" STREQUAL "-1")
##########

# TODO: NOT MSVC and NOT XCODE
# Need to construct compile time check for functionality below
if(ANDROID)

  set_target_properties(
    mylib
    PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    )

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g") # adding -g is required to force debug symbols
  strip_and_save_debug_symbols(${lib_name})

elseif(XCODE)

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g") # adding -g is required to force .dSYM
  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
  
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release;MinSizeRel;RelWithDebInfo")  
  set(CMAKE_XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym")
  set(CMAKE_XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Release] "dwarf-with-dsym")
  set(CMAKE_XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS "YES")
  set(CMAKE_XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS[variant=Release] "YES")

  set_target_properties(${lib_name}
    PROPERTIES
    
    XCODE_ATTRIBUTE_COPY_PHASE_STRIP "YES"
    XCODE_ATTRIBUTE_STRIP_INSTALLED_PRODUCT "YES"
    XCODE_ATTRIBUTE_STRIP_STYLE "non-global"
    XCODE_ATTRIBUTE_STRIPFLAGS "-x -u -r"
    XCODE_ATTRIBUTE_DEAD_CODE_STRIPPING "YES"
    XCODE_ATTRIBUTE_DEPLOYMENT_POSTPROCESSING "YES"
    # Note: Using this option in combination with thread_local and shared libraries crashes
    # the linker step with the following error:
    #
    # ld: Assertion failed: (0 && "need to handle arm64 -r reloc"), function encodeSectionReloc,
    # file /Library/Caches/com.apple.xbs/Sources/ld64/ld64-264.3.102/src/ld/LinkEditClassic.hpp, line 1907.
    #
    # This should can be enabled optionally for modules that do not require thread_local.
    XCODE_ATTRIBUTE_GENERATE_MASTER_OBJECT_FILE "YES" # "Perform Single-Object Prelink"

    # Visibility
    XCODE_ATTRIBUTE_GCC_INLINES_ARE_PRIVATE_EXTERN YES
    XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN YES
  )

endif()

include(GenerateExportHeader)
generate_export_header(mylib)

target_include_directories(
  mylib
  PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
  "$<INSTALL_INTERFACE:include>"
)

set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(targets_export_name "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

configure_file("cmake/Config.cmake.in" "${project_config}" @ONLY)

install(
    TARGETS mylib
    EXPORT "${targets_export_name}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "${include_install_dir}/mylib"
)

install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
    )

install(
  FILES "mylib.hpp"
  DESTINATION "include/mylib"
  )  

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/mylib_export.h"
  DESTINATION "${include_install_dir}/mylib/"
  )

install(
    EXPORT "${targets_export_name}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
)
