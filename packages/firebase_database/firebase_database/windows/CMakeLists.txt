cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "flutterfire_database")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "firebase_database_plugin")

list(APPEND PLUGIN_SOURCES
  "firebase_database_plugin.cpp"
  "firebase_database_plugin.h"
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

configure_file(plugin_version.h.in ${CMAKE_BINARY_DIR}/generated/firebase_database/plugin_version.h)
include_directories(${CMAKE_BINARY_DIR}/generated/)

add_library(${PLUGIN_NAME} STATIC
  "include/firebase_database/firebase_database_plugin_c_api.h"
  "firebase_database_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
  ${CMAKE_BINARY_DIR}/generated/firebase_database/plugin_version.h
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PUBLIC FLUTTER_PLUGIN_IMPL)
target_compile_definitions(${PLUGIN_NAME} PRIVATE -DINTERNAL_EXPERIMENTAL=1)

set(MSVC_RUNTIME_MODE MD)
set(firebase_libs firebase_core_plugin firebase_database)
set(ADDITIONAL_LIBS advapi32 ws2_32 crypt32 rpcrt4 ole32 shell32 Bcrypt.lib DbgHelp.lib)
set(RTDB_ADDITIONAL_LIBS iphlpapi psapi userenv)
target_link_libraries(${PLUGIN_NAME} PRIVATE "${firebase_libs}" "${ADDITIONAL_LIBS}" "${RTDB_ADDITIONAL_LIBS}")

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(firebase_database_bundled_libraries
  ""
  PARENT_SCOPE
)
