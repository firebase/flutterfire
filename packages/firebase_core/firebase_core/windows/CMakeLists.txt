# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

set(FIREBASE_SDK_VERSION "12.7.0")

if (EXISTS $ENV{FIREBASE_CPP_SDK_DIR}/include/firebase/version.h)
    file(READ "$ENV{FIREBASE_CPP_SDK_DIR}/include/firebase/version.h" existing_version)

    string(REGEX MATCH "FIREBASE_VERSION_MAJOR ([0-9]*)" _ ${existing_version})
    set(existing_version_major ${CMAKE_MATCH_1})

    string(REGEX MATCH "FIREBASE_VERSION_MINOR ([0-9]*)" _ ${existing_version})
    set(existing_version_minor ${CMAKE_MATCH_1})

    string(REGEX MATCH "FIREBASE_VERSION_REVISION ([0-9]*)" _ ${existing_version})
    set(existing_version_revision ${CMAKE_MATCH_1})

    set(existing_version "${existing_version_major}.${existing_version_minor}.${existing_version_revision}")
endif()

if(existing_version VERSION_EQUAL FIREBASE_SDK_VERSION)
    message(STATUS "Found Firebase SDK version ${existing_version}")
    set(FIREBASE_CPP_SDK_DIR $ENV{FIREBASE_CPP_SDK_DIR})
else()
    set(firebase_sdk_url "https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_windows_${FIREBASE_SDK_VERSION}.zip")
    set(firebase_sdk_filename "${CMAKE_BINARY_DIR}/firebase_cpp_sdk_windows_${FIREBASE_SDK_VERSION}.zip")
    set(extracted_path "${CMAKE_BINARY_DIR}/extracted")
    if(NOT EXISTS ${firebase_sdk_filename})
        file(DOWNLOAD ${firebase_sdk_url} ${firebase_sdk_filename}
             SHOW_PROGRESS
             STATUS download_status
             LOG download_log)
        list(GET download_status 0 status_code)
        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "Download failed: ${download_log}")
        endif()
    else()
        message(STATUS "Using cached Firebase SDK zip file")
    endif()

    if(NOT EXISTS ${extracted_path})
        file(MAKE_DIRECTORY ${extracted_path})
        file(ARCHIVE_EXTRACT INPUT ${firebase_sdk_filename}
             DESTINATION ${extracted_path})
    else()
        message(STATUS "Using cached extracted Firebase SDK")
    endif()
    set(FIREBASE_CPP_SDK_DIR "${extracted_path}/firebase_cpp_sdk_windows")
endif()

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

configure_file(plugin_version.h.in ${CMAKE_BINARY_DIR}/generated/firebase_core/plugin_version.h)
include_directories(${CMAKE_BINARY_DIR}/generated/)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} STATIC
  "include/firebase_core/firebase_core_plugin_c_api.h"
  "firebase_core_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
  ${CMAKE_BINARY_DIR}/generated/firebase_core/plugin_version.h
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
if(NOT MSVC_RUNTIME_MODE)
  set(MSVC_RUNTIME_MODE MD)
endif()

add_subdirectory(${FIREBASE_CPP_SDK_DIR} bin/ EXCLUDE_FROM_ALL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${FIREBASE_CPP_SDK_DIR}/include")

set(FIREBASE_RELEASE_PATH_LIBS firebase_app firebase_auth firebase_storage firebase_firestore)
foreach(firebase_lib IN ITEMS ${FIREBASE_RELEASE_PATH_LIBS})
    get_target_property(firebase_lib_path ${firebase_lib} IMPORTED_LOCATION)
    string(REPLACE "Debug" "Release" firebase_lib_release_path ${firebase_lib_path})
    set_target_properties(${firebase_lib} PROPERTIES
      IMPORTED_LOCATION_DEBUG "${firebase_lib_path}"
      IMPORTED_LOCATION_RELEASE "${firebase_lib_release_path}"
    )
endforeach()

set(FIREBASE_LIBS firebase_app)
set(ADDITIONAL_LIBS advapi32 ws2_32 crypt32 rpcrt4 ole32 icu)

target_link_libraries(${PLUGIN_NAME} PUBLIC "${FIREBASE_LIBS}" "${ADDITIONAL_LIBS}")

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PUBLIC flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(firebase_core_bundled_libraries
  ""
  PARENT_SCOPE
)
