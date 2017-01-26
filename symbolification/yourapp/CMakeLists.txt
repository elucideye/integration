cmake_minimum_required(VERSION 3.3)

project(yourapp VERSION 1.2.3)

message("MYLIB_DIR : ${MYLIB_DIR}")


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

if(XCODE)

  add_executable(yourapp MACOSX_BUNDLE yourapp.cpp)

  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE No)  
  
  target_compile_options(yourapp PUBLIC "-F" "${MYLIB_DIR}")
  target_link_libraries(yourapp "-F ${MYLIB_DIR} -framework mylib")
  
  set_target_properties(
    yourapp
    PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/plist.in"  
    XCODE_ATTRIBUTE_PRODUCT_NAME "yourapp"
    XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER  "com.example.integration.yourapp"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2" # iPhone/iPad
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks"  # http://stackoverflow.com/a/39042153
    )

  # Additional code signing required?
  # See: http://stackoverflow.com/a/39042153
  add_custom_command(
    TARGET yourapp
    PRE_BUILD
    COMMAND
    "${CMAKE_COMMAND}" -E copy_directory "${MYLIB_DIR}/mylib.framework" "$<TARGET_FILE_DIR:yourapp>/Frameworks/mylib.framework"
    )

else()

  add_executable(yourapp yourapp.cpp)

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
  
  set(mylib_DIR "${MYLIB_DIR}")
  find_package(mylib CONFIG REQUIRED)
  target_link_libraries(yourapp mylib::mylib)
  install(TARGETS yourapp DESTINATION bin)

  # Reinstall the shared lib folder to CMAKE_INSTALL_PREFIX
  add_custom_command(
    TARGET yourapp
    POST_BUILD
    COMMAND
    "${CMAKE_COMMAND}" -E copy_directory "${MYLIB_DIR}/../../../lib" "${CMAKE_INSTALL_PREFIX}/lib"
    )
  
endif()

set_target_properties(
  yourapp
  PROPERTIES
  INSTALL_RPATH "@executable_path/../Frameworks"
  BUILD_WITH_INSTALL_RPATH YES
  )
