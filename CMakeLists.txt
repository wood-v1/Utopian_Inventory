cmake_minimum_required(VERSION 3.10.0)
project(UtopianInventory VERSION 0.1.0 LANGUAGES C CXX)

if(CMAKE_SIZEOF_VOID_P AND NOT CMAKE_SIZEOF_VOID_P EQUAL 4)
    message(FATAL_ERROR "UtopianInventory must be built as Win32/x86 to hook Pathologic Game.exe.")
endif()

set(OYNONTOOLS_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../OynonTools" CACHE PATH "Path to the OynonTools repository root")
set(OYNONTOOLS_INCLUDE_DIR "${OYNONTOOLS_ROOT}/include")
set(OYNONTOOLS_LIBRARY_DIR "${OYNONTOOLS_ROOT}/lib/Win32")

if(NOT EXISTS "${OYNONTOOLS_INCLUDE_DIR}/OynonToolsApi.h")
    message(FATAL_ERROR "OynonToolsApi.h not found. Set OYNONTOOLS_ROOT to the OynonTools repository.")
endif()

add_library(UtopianInventory SHARED
    bootstrap.cpp
    dllmain.cpp
)

target_compile_features(UtopianInventory PRIVATE cxx_std_17)
target_compile_definitions(UtopianInventory PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_include_directories(UtopianInventory PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${OYNONTOOLS_INCLUDE_DIR})
target_link_libraries(UtopianInventory PRIVATE
    "$<$<CONFIG:Debug>:${OYNONTOOLS_LIBRARY_DIR}/Debug/OynonTools.lib>"
    "$<$<CONFIG:Release>:${OYNONTOOLS_LIBRARY_DIR}/Release/OynonTools.lib>"
    "$<$<CONFIG:MinSizeRel>:${OYNONTOOLS_LIBRARY_DIR}/MinSizeRel/OynonTools.lib>"
    "$<$<CONFIG:RelWithDebInfo>:${OYNONTOOLS_LIBRARY_DIR}/RelWithDebInfo/OynonTools.lib>")
set_target_properties(UtopianInventory PROPERTIES PREFIX "" SUFFIX ".dll")

if(MSVC)
    target_compile_options(UtopianInventory PRIVATE /W4 /EHsc)
    target_link_options(UtopianInventory PRIVATE /SUBSYSTEM:WINDOWS)
endif()

add_custom_command(
    TARGET UtopianInventory POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${OYNONTOOLS_ROOT}/bin/Win32/$<CONFIG>/OynonTools.dll"
        "$<TARGET_FILE_DIR:UtopianInventory>/OynonTools.dll")
