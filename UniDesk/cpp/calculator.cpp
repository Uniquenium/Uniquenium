// src/calculator.cpp
#include "calculator.h"

Calculator::Calculator() : last_result_(0) {}

void Calculator::add(int value) {
    this->last_result_ += value;
}

void Calculator::subtract(int value) {
    this->last_result_ -= value;
}

int Calculator::getResult() const {
    return this->last_result_;
}
