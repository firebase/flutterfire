# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

set(FIREBASE_SDK_VERSION "13.5.0")

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
    # There is no Linux-specific archive; the full firebase_cpp_sdk zip ships
    # prebuilt Linux x86_64 static libraries (both C++11 and legacy ABI
    # variants) and a CMakeLists.txt that selects the correct variant when
    # consumed via add_subdirectory, just like the Windows archive does.
    set(firebase_sdk_url "https://dl.google.com/firebase/sdk/cpp/firebase_cpp_sdk_${FIREBASE_SDK_VERSION}.zip")
    set(firebase_sdk_filename "${CMAKE_BINARY_DIR}/firebase_cpp_sdk_${FIREBASE_SDK_VERSION}.zip")
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
    set(FIREBASE_CPP_SDK_DIR "${extracted_path}/firebase_cpp_sdk")
endif()

# Project-level configuration.
set(PROJECT_NAME "firebase_core")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "firebase_core_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "include/firebase_core/firebase_core_plugin.h"
  "include/firebase_core/flutter_firebase_plugin.h"
  "firebase_core_plugin.cc"
  "messages.g.cc"
  "messages.g.h"
  "flutter_firebase_plugin_registry.h"
  "flutter_firebase_plugin_registry.cc"
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
#
# This is deliberately a STATIC library (unlike the SHARED library in the
# Flutter Linux plugin template) to mirror the Windows implementation:
#  - The Firebase C++ SDK ships prebuilt static libraries. If each FlutterFire
#    plugin were a separate shared library, every plugin .so would embed its
#    own copy of firebase_app and its global app registry, breaking the
#    cross-plugin sharing of firebase::App instances. Linking everything
#    statically into the runner keeps a single copy of the SDK state.
#  - Other FlutterFire plugins link against this target and reuse the
#    FlutterFirebasePluginRegistry defined here, which requires a single
#    static registry in the final executable.
# The Flutter tooling links the plugin target into the runner directly
# (target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)), so a
# STATIC library resolves at the final link. POSITION_INDEPENDENT_CODE is
# enabled below because the runner executable is built as PIE.
add_library(${PLUGIN_NAME} STATIC
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
  CXX_VISIBILITY_PRESET hidden
  POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(${PLUGIN_NAME} PUBLIC FLUTTER_PLUGIN_IMPL)

# Enable firebase-cpp-sdk's platform logging api.
target_compile_definitions(${PLUGIN_NAME} PRIVATE -DINTERNAL_EXPERIMENTAL=1)

add_subdirectory(${FIREBASE_CPP_SDK_DIR} bin/ EXCLUDE_FROM_ALL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${FIREBASE_CPP_SDK_DIR}/include")

# Note: unlike the Windows CMakeLists there is no Debug->Release
# IMPORTED_LOCATION fixup here. The Linux SDK archive does not split its
# prebuilt libraries into Debug/Release directories; the SDK's own
# CMakeLists.txt selects the correct library variant
# (libs/linux/<arch>/<abi>/*.a) when consumed via add_subdirectory.

# --- Firebase SDK link strategy ---------------------------------------------
# The prebuilt Firebase static archives have circular symbol dependencies:
#  - the product libraries (app_check, remote_config, storage, ...) call
#    firebase::rest::* helpers that live in libfirebase_app.a, and
#  - libfirebase_firestore.a references firebase::g_auth_initializer defined
#    in libfirebase_auth.a.
# A plain ordered link line cannot satisfy every plugin combination, so this
# target - which every FlutterFire Linux plugin links against - owns the SDK
# link and wraps ALL desktop product archives in a single
# --start-group/--end-group so the linker rescans the group until every
# reference resolves, regardless of order. Archives that no plugin actually
# references contribute nothing to the final binary.
set(FIREBASE_SDK_TARGETS
  firebase_auth
  firebase_app_check
  firebase_database
  firebase_firestore
  firebase_functions
  firebase_remote_config
  firebase_storage
  firebase_app
)
set(firebase_sdk_lib_paths "")
foreach(firebase_lib IN LISTS FIREBASE_SDK_TARGETS)
  if(TARGET ${firebase_lib})
    get_target_property(firebase_lib_path ${firebase_lib} IMPORTED_LOCATION)
    if(firebase_lib_path)
      list(APPEND firebase_sdk_lib_paths "${firebase_lib_path}")
    endif()
  endif()
endforeach()

target_link_libraries(${PLUGIN_NAME} PUBLIC
  "-Wl,--start-group" ${firebase_sdk_lib_paths} "-Wl,--end-group")

# System library dependencies of the archives above, placed after the group:
#  - libsecret for Auth credential persistence. The SDK's CMakeLists attaches
#    it to the imported firebase_auth target as INTERFACE_LINK_LIBRARIES, so
#    forward that usage requirement here (the imported targets themselves are
#    only used to resolve archive paths and are not linked directly).
#  - OpenSSL for Realtime Database (TLS websockets) and Firestore (LevelDB
#    encryption); the prebuilt Linux archives reference system OpenSSL
#    symbols, matching the Firebase desktop setup documentation.
if(TARGET firebase_auth)
  get_target_property(firebase_auth_iface_libs firebase_auth
    INTERFACE_LINK_LIBRARIES)
  if(firebase_auth_iface_libs)
    target_link_libraries(${PLUGIN_NAME} PUBLIC ${firebase_auth_iface_libs})
  endif()
endif()
find_package(OpenSSL QUIET)
if(OPENSSL_FOUND)
  target_link_libraries(${PLUGIN_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)
else()
  message(WARNING "OpenSSL development libraries not found; linking may fail \
for apps using firebase_database or cloud_firestore. Install libssl-dev \
(Debian/Ubuntu) or openssl (Arch/Fedora).")
endif()

target_link_libraries(${PLUGIN_NAME} PUBLIC pthread)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(firebase_core_bundled_libraries
  ""
  PARENT_SCOPE
)
