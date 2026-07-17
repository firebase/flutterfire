# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "firebase_auth")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "firebase_auth_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "include/firebase_auth/firebase_auth_plugin.h"
  "firebase_auth_plugin.cc"
  "messages.g.cc"
  "messages.g.h"
)

# Read version from pubspec.yaml
file(STRINGS "../pubspec.yaml" pubspec_content)
foreach(line ${pubspec_content})
  string(FIND ${line} "version: " has_version)

  if("${has_version}" STREQUAL "0")
    string(FIND ${line} ": " version_start_pos)
    math(EXPR version_start_pos "${version_start_pos} + 2")
    string(LENGTH ${line} version_end_pos)
    math(EXPR len "${version_end_pos} - ${version_start_pos}")
    string(SUBSTRING ${line} ${version_start_pos} ${len} PLUGIN_VERSION)
    break()
  endif()
endforeach(line)

configure_file(plugin_version.h.in ${CMAKE_BINARY_DIR}/generated/firebase_auth/plugin_version.h)
include_directories(${CMAKE_BINARY_DIR}/generated/)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
#
# This is deliberately a STATIC library (unlike the SHARED library in the
# Flutter Linux plugin template) to mirror the Windows implementation; see the
# explanation in firebase_core/linux/CMakeLists.txt. The Firebase C++ SDK is
# added (via add_subdirectory) by the firebase_core plugin, which also exports
# the SDK include directories through the firebase_core_plugin target, so it
# is not re-added here — mirroring how the Windows CMakeLists consumes the
# SDK targets set up by firebase_core.
add_library(${PLUGIN_NAME} STATIC
  ${PLUGIN_SOURCES}
  ${CMAKE_BINARY_DIR}/generated/firebase_auth/plugin_version.h
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(${PLUGIN_NAME} PUBLIC FLUTTER_PLUGIN_IMPL)

# Enable firebase-cpp-sdk's platform logging api.
target_compile_definitions(${PLUGIN_NAME} PRIVATE -DINTERNAL_EXPERIMENTAL=1)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
#
# The firebase_auth SDK target carries its own Linux-specific interface
# dependencies (libsecret-1 for credential persistence) via the SDK's own
# CMakeLists.txt, so they do not need to be repeated here.
set(firebase_libs firebase_core_plugin firebase_auth)
set(ADDITIONAL_LIBS pthread)
target_link_libraries(${PLUGIN_NAME} PRIVATE "${firebase_libs}" "${ADDITIONAL_LIBS}")

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(firebase_auth_bundled_libraries
  ""
  PARENT_SCOPE
)
