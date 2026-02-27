cmake_minimum_required(VERSION 3.21)
project(cpp_bridge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FetchContent)

FetchContent_Declare(
    taocpp_json
    GIT_REPOSITORY https://github.com/taocpp/json.git
    GIT_TAG 330129305f15fbfba5e0716db25e245f0b4d8b0f
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(taocpp_json)

add_library(cpp_bridge STATIC
    src/bridge.cpp
)

target_include_directories(cpp_bridge
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${taocpp_json_SOURCE_DIR}/include
        ${taocpp_json_SOURCE_DIR}/external/PEGTL/include
)
