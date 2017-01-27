function(strip_and_save_debug_symbols lib_name)

  #https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html
  set(BUILDID "abcdef1234")
  string(SUBSTRING "${BUILDID}" 0 2 BUILDIDPREFIX)
  string(SUBSTRING "${BUILDID}" 2 8 BUILDIDSUFFIX)
  set_target_properties(${lib_name} PROPERTIES LINK_FLAGS "-Wl,--build-id=0x${BUILDID}")
  add_custom_command(TARGET ${lib_name}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${lib_name}> ${CMAKE_BINARY_DIR}/${lib_name}.debug
    
    # Prefer to strip via CMake install/strip target
    COMMAND ${CMAKE_STRIP} -g $<TARGET_FILE:${lib_name}>
    )

  message("CMAKE_STRIP = ${CMAKE_STRIP}")

  # Install the unstripped library itself via build-id:
  install(FILES
    ${CMAKE_BINARY_DIR}/${lib_name}.debug
    DESTINATION ${CMAKE_INSTALL_PREFIX}/.build-id/${BUILDIDPREFIX}
    RENAME ${BUILDIDSUFFIX}.debug
    )
  
endfunction(strip_and_save_debug_symbols)
