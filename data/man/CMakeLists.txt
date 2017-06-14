find_program(TXT2MAN txt2man)
find_program(GZIP gzip)

# It's not a requirement that we make man pages.
if (NOT TXT2MAN)
  message(WARNING "txt2man not found; man pages will not be generated.")
elseif (NOT GZIP)
  message(WARNING "gzip not found; man pages will not be generated.")
else ()
  # We have the tools.  We can make them.
  message(STATUS "Found txt2man and gzip; man page will be built and installed")
  string(TOUPPER ${PROJECT_NAME} MAN_TITLE)
  add_custom_command(
      OUTPUT ${PROJECT_NAME}.1.gz
      COMMAND ${TXT2MAN}
        -t ${MAN_TITLE}
        -r ${PEEK_VERSION_MAJOR}.${PEEK_VERSION_MINOR}.${PEEK_VERSION_PATCH}
        -s 1
        -v "\"User commands\""
        ${CMAKE_SOURCE_DIR}/data/man/${PROJECT_NAME}.1.txt
        | ${GZIP}
        > ${CMAKE_BINARY_DIR}/data/man/${PROJECT_NAME}.1.gz
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  add_custom_target(build-manpage ALL DEPENDS ${PROJECT_NAME}.1.gz)

  # Set the rules to install the documentation.
  install(FILES ${CMAKE_BINARY_DIR}/data/man/${PROJECT_NAME}.1.gz DESTINATION share/man/man1/)
endif ()
