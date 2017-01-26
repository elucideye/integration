cmake_minimum_required(VERSION 3.3)

project(yourapp VERSION 1.2.3)

message("MYLIB_DIR : ${MYLIB_DIR}")

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
  add_custom_command(
    TARGET yourapp
    PRE_BUILD
    COMMAND
    "${CMAKE_COMMAND}" -E copy_directory "${MYLIB_DIR}/mylib.framework" "$<TARGET_FILE_DIR:yourapp>/Frameworks/mylib.framework"
    )

else()

  add_executable(yourapp yourapp.cpp)
  
  set(mylib_DIR "${MYLIB_DIR}")
  find_package(mylib CONFIG REQUIRED)
  target_link_libraries(yourapp mylib::mylib)

  install(TARGETS yourapp DESTINATION bin)
  
endif()

set_target_properties(
  yourapp
  PROPERTIES
  INSTALL_RPATH "@executable_path/../Frameworks"
  BUILD_WITH_INSTALL_RPATH YES
  )
