# Used for GResource.
#
# resource_dir: Directory where the .gresource.xml is located.
# resource_file: Filename of the .gresource.xml file (just the
# filename, not the complete path).
# output_dir: Directory where the C output file is written.
# output_file: This variable will be set with the complete path of the
# output C file.

function (gresource resource_dir resource_file output_dir output_source)

_pkgconfig_invoke("glib-2.0" GLIB2 PREFIX
  "" "--variable=prefix")
find_program(GLIB_COMPILE_RESOURCES
             NAMES glib-compile-resources
             HINTS ${GLIB2_PREFIX})

if (NOT GLIB_COMPILE_RESOURCES)
message(FATAL "Could not find glib-compile-resources")
endif()

# Get the output file path
set (output_c "${output_dir}/src/resources.c")
set (${output_source} ${output_c} PARENT_SCOPE)

# Command to compile the resources
add_custom_command (
	OUTPUT ${output_c}
	WORKING_DIRECTORY ${resource_dir}
	COMMAND ${GLIB_COMPILE_RESOURCES} --generate-source --target=${output_c} ${resource_file}
)
endfunction ()
