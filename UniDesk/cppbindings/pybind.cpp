// bindings/py_bindings.cpp
#include <pybind11/pybind11.h>
#include "../cpp/calculator.h" // 包含我们要绑定的 C++ 头文件

namespace py = pybind11;

// PYBIND11_MODULE 是一个特殊的宏，它会创建 Python 模块的入口点
// 第一个参数 (my_calculator) 是 Python 中 `import` 时使用的模块名
// 第二个参数 (m) 是一个 py::module_ 对象，代表了这个模块本身
PYBIND11_MODULE(my_calculator, m) {
    // 可选：为模块添加文档字符串
    m.doc() = "A simple calculator module made with pybind11";

    // py::class_ 是一个模板，用于将 C++ 类暴露给 Python
    // 尖括号里是你要绑定的 C++ 类名
    py::class_<Calculator>(m, "Calculator") // 在 Python 中，这个类的名字将是 "Calculator"
        .def(py::init<>()) // 绑定构造函数。py::init<>() 表示绑定无参构造函数
        .def("add", &Calculator::add, "Adds a value to the current result") // 绑定 add 方法
        .def("subtract", &Calculator::subtract, "Subtracts a value") // 绑定 subtract 方法
        .def("get_result", &Calculator::getResult, "Returns the current result"); // 绑定 getResult 方法
}
