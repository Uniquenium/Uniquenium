# CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(CalculatorProject)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- 1. 获取 pybind11 ---
# 推荐使用 FetchContent，它会自动下载并配置好 pybind11
include(FetchContent)
FetchContent_Declare(
    pybind11
    GIT_REPOSITORY git@github.com:pybind/pybind11.git
    GIT_TAG        v3.0.0 # 使用一个稳定版本
)
FetchContent_MakeAvailable(pybind11)
# --- 2. 定义我们的 C++ 库 ---
# 把核心逻辑编译成一个静态库，方便管理
add_library(calculator_lib STATIC UniDesk/cpp/calculator.cpp)
# 确保头文件路径被包含
target_include_directories(calculator_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/UniDesk/cpp)
# --- 3. 创建 Python 模块 ---
# pybind11_add_module 是 pybind11 提供的 CMake 函数，专门用于创建 Python 扩展模块
# 它会生成一个 .so (Linux) 或 .pyd (Windows) 文件
pybind11_add_module(my_calculator MODULE UniDesk/cppbindings/pybind.cpp)
# --- 4. 链接依赖 ---
# 告诉我们的 Python 模块，它需要链接到 calculator_lib 的代码
target_link_libraries(my_calculator PRIVATE calculator_lib)
