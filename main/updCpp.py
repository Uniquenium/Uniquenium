import os
os.system("c++ -O3 -Wall -shared -std=c++11 -fPIC $(python -m pybind11 --includes) UniDesk/cpp/calculator.cpp -o build/example$(python -m pybind11 --extension-suffix)")