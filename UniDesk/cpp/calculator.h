// src/calculator.h
#pragma once

class Calculator {
private:
    int last_result_;

public:
    Calculator();
    void add(int value);
    void subtract(int value);
    int getResult() const;
};
