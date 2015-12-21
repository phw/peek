project("gifcast" C)
cmake_minimum_required(VERSION 2.6)

# Include Vala macros
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/vala
)

include(FindVala)
include(UseVala)

# Check dependencies
find_package(Vala REQUIRED)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

pkg_check_modules(REQUIRED cairo gmodule-2.0)

# GResource
include(GResource)
gresource(${CMAKE_CURRENT_SOURCE_DIR}/ ${PROJECT_NAME}.gresource.xml
	${CMAKE_BINARY_DIR}/ RESOURCE_FILE)

# Compile Vala to C
vala_precompile(VALA_C
    src/gifcast.vala
    src/screen_recorder.vala
PACKAGES
    gtk+-3.0
    gmodule-2.0
)

# Compile C code
add_executable("gifcast" ${VALA_C} ${RESOURCE_FILE})
