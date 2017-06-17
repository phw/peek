# GSettings.cmake, CMake macros written for Marlin, feel free to re-use them.

option (GSETTINGS_LOCALINSTALL "Install GSettings Schemas locally instead of to the GLib prefix" ON)

option (GSETTINGS_COMPILE "Compile GSettings Schemas after installation" ${GSETTINGS_LOCALINSTALL})

if(GSETTINGS_LOCALINSTALL)
    message(STATUS "GSettings schemas will be installed locally.")
endif()

if(GSETTINGS_COMPILE)
    message(STATUS "GSettings shemas will be compiled.")
endif()

macro(add_schema SCHEMA_NAME)

    set(PKG_CONFIG_EXECUTABLE pkg-config)
    # Have an option to not install the schema into where GLib is
    if (GSETTINGS_LOCALINSTALL)
        SET (GSETTINGS_DIR "${CMAKE_INSTALL_DATAROOTDIR}/glib-2.0/schemas/")
    else ()
        execute_process (COMMAND ${PKG_CONFIG_EXECUTABLE} glib-2.0 --variable prefix OUTPUT_VARIABLE _glib_prefix OUTPUT_STRIP_TRAILING_WHITESPACE)
        SET (GSETTINGS_DIR "${_glib_prefix}/share/glib-2.0/schemas/")
    endif ()

    # Run the validator and error if it fails
    execute_process (COMMAND ${PKG_CONFIG_EXECUTABLE} gio-2.0 --variable glib_compile_schemas  OUTPUT_VARIABLE _glib_comple_schemas OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process (COMMAND ${_glib_comple_schemas} --dry-run --schema-file=${CMAKE_CURRENT_SOURCE_DIR}/${SCHEMA_NAME} ERROR_VARIABLE _schemas_invalid OUTPUT_STRIP_TRAILING_WHITESPACE)

    if (_schemas_invalid)
      message (SEND_ERROR "Schema validation error: ${_schemas_invalid}")
    endif (_schemas_invalid)

    # Actually install and recomple schemas
    message (STATUS "GSettings schemas will be installed into ${GSETTINGS_DIR}")
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${SCHEMA_NAME} DESTINATION ${GSETTINGS_DIR} OPTIONAL)

    if (GSETTINGS_COMPILE)
        install (CODE "message (STATUS \"Compiling GSettings schemas\")")
        install (CODE "execute_process (COMMAND ${_glib_comple_schemas} ${GSETTINGS_DIR})")
    endif ()

    build_schema(${SCHEMA_NAME})
endmacro()


macro(build_schema SCHEMA_NAME)
  message (STATUS "Copying schema to build directory ${CMAKE_BINARY_DIR}/data")
  get_filename_component (SCHEMA_FILE_NAME ${SCHEMA_NAME} NAME)
  configure_file(${SCHEMA_NAME} ${SCHEMA_FILE_NAME} COPYONLY)

  set(PKG_CONFIG_EXECUTABLE pkg-config)
  message (STATUS "Building development schema in ${CMAKE_BINARY_DIR}/data")
  execute_process (COMMAND ${PKG_CONFIG_EXECUTABLE} gio-2.0 --variable glib_compile_schemas  OUTPUT_VARIABLE _glib_comple_schemas OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process (COMMAND ${_glib_comple_schemas} ${CMAKE_BINARY_DIR}/data)
endmacro()
