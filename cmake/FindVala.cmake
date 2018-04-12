##
# Find module for the Vala compiler (valac)
#
# This module determines whether a Vala compiler is installed on the current
# system and where its executable is.
#
# Call the module using "find_package(Vala) from within your CMakeLists.txt.
#
# The following variables will be set after an invocation:
#
#  VALA_FOUND       Whether the vala compiler has been found or not
#  VALA_EXECUTABLE  Full path to the valac executable if it has been found
#  VALA_VERSION     Version number of the available valac
#  VALA_USE_FILE    Include this file to define the vala_precompile function
##

##
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
# Copyright 2010-2011 Daniel Pfeifer
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of Jakob Westhoff
##

# Search for the valac executable in the usual system paths
# Some distributions rename the valac to contain the major.minor in the binary name
find_program(VALA_EXECUTABLE NAMES valac valac-0.20 valac-0.18 valac-0.16 valac-0.14 valac-0.12 valac-0.10)
mark_as_advanced(VALA_EXECUTABLE)

# Determine the valac version
if(VALA_EXECUTABLE)
    execute_process(COMMAND ${VALA_EXECUTABLE} "--version"
                    OUTPUT_VARIABLE VALA_VERSION
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REPLACE "Vala " "" VALA_VERSION "${VALA_VERSION}")
endif(VALA_EXECUTABLE)

# Handle the QUIETLY and REQUIRED arguments, which may be given to the find call.
# Furthermore set VALA_FOUND to TRUE if Vala has been found (aka.
# VALA_EXECUTABLE is set)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Vala
    REQUIRED_VARS VALA_EXECUTABLE
    VERSION_VAR VALA_VERSION)

set(VALA_USE_FILE "${CMAKE_CURRENT_LIST_DIR}/UseVala.cmake")
