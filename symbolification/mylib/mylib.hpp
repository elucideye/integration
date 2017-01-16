#ifndef MYLIB_MYLIB_HPP_
#define MYLIB_MYLIB_HPP_

#include <string>
#include <vector>

#include "mylib_export.h"

#define TEST_STRING 1

namespace mylib
{
#if TEST_STRING
    std::string MYLIB_EXPORT bar();
#else
    std::vector<int> MYLIB_EXPORT bar();
#endif

    void MYLIB_EXPORT crashsim(std::size_t n);
}

#endif // MYLIB_MYLIB_HPP_
