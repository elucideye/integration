#include "mylib.hpp"

#include <iostream> // std::cout
#include <string>
#include <vector>

namespace mylib
{
    void foo() {}
    void boo() {}

#if TEST_STRING
    std::string bar()
    {
        foo();
        boo();
        std::string result("Hello from bar.framework!");
        std::cout << result << std::endl;
        return result;
    }
#else
    std::vector<int> bar()
    {
        foo();
        boo();
        std::cout << "Hello world" << std::endl;
        return std::vetor<int>{1,2,3,4};
    }
#endif

    void crashsim(std::size_t n)
    {
        int *buffer = nullptr;
        for(int i = 0; i < n; i++)
        {
            buffer[i] = i;
        }
    }
    
}

