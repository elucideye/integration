#include <iostream> // std::cout

#include "mylib/mylib.hpp"

int main()
{
    std::cout << "hello from baz" << std::endl;

    mylib::bar();
    mylib::crashsim(100);
    mylib::bar();
    
    std::cout << "FOBAR" << std::endl;
}
