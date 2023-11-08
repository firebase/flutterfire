# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "firebase_auth")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "firebase_auth_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "firebase_auth_plugin.cpp"
  "firebase_auth_plugin.h"
  "messages.g.cpp"
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
add_library(${PLUGIN_NAME} STATIC
  "include/firebase_auth/firebase_auth_plugin_c_api.h"
  "firebase_auth_plugin_c_api.cpp"
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
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PUBLIC FLUTTER_PLUGIN_IMPL)
# Enable firebase-cpp-sdk's platform logging api.
target_compile_definitions(${PLUGIN_NAME} PRIVATE -DINTERNAL_EXPERIMENTAL=1)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
set(MSVC_RUNTIME_MODE MD)
set(firebase_libs firebase_core_plugin firebase_auth)
target_link_libraries(${PLUGIN_NAME} PRIVATE "${firebase_libs}")

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PUBLIC flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(firebase_auth_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===
# These unit tests can be run from a terminal after building the example, or
# from Visual Studio after opening the generated solution file.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Add the Google Test dependency.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
FetchContent_MakeAvailable(googletest)

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/firebase_auth_plugin_test.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()
