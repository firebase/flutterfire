# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

set(FIREBASE_SDK_VERSION "10.5.0")
set(FIREBASE_SDK_URL "https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_${FIREBASE_SDK_VERSION}.zip")
set(FIREBASE_SDK_FILENAME "${CMAKE_BINARY_DIR}/firebase_cpp_sdk_${FIREBASE_SDK_VERSION}.zip")
set(EXTRACTED_PATH "${CMAKE_BINARY_DIR}/extracted")

if(NOT EXISTS ${FIREBASE_SDK_FILENAME})
    file(DOWNLOAD ${FIREBASE_SDK_URL} ${FIREBASE_SDK_FILENAME}
         SHOW_PROGRESS
         STATUS download_status
         LOG download_log)
    list(GET download_status 0 status_code)
    if(NOT status_code EQUAL 0)
        message(FATAL_ERROR "Download failed: ${download_log}")
    endif()
endif()

if(NOT EXISTS ${EXTRACTED_PATH})
    file(MAKE_DIRECTORY ${EXTRACTED_PATH})
    file(ARCHIVE_EXTRACT INPUT ${FIREBASE_SDK_FILENAME}
         DESTINATION ${EXTRACTED_PATH})
endif()
set(FIREBASE_CPP_SDK_DIR "${EXTRACTED_PATH}/firebase_cpp_sdk")


# Project-level configuration.
set(PROJECT_NAME "firebase_core")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "firebase_core_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "firebase_core_plugin.cpp"
  "firebase_core_plugin.h"
  "messages.g.cpp"
  "messages.g.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/firebase_core/firebase_core_plugin_c_api.h"
  "firebase_core_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
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
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
set(MSVC_RUNTIME_MODE MD)
add_subdirectory(${FIREBASE_CPP_SDK_DIR} bin/ EXCLUDE_FROM_ALL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${FIREBASE_CPP_SDK_DIR}/include")
set(firebase_libs firebase_auth firebase_database firebase_app)
target_link_libraries(${PLUGIN_NAME} PRIVATE "${firebase_libs}")

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(firebase_core_bundled_libraries
  ""
  PARENT_SCOPE
)
