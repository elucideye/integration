#include "mylib.hpp"

#include <iostream> // std::cout
#include <string>
#include <vector>
#include <memory>

namespace mylib
{
    int some_bad_func(int n)
    {
        int *buffer = nullptr;
        for(int i = 0; i < n; i++)
        {
            buffer[i] = i;
        }
        return n*n;
    }
    
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

    /*
     * Produce a nice stack trace
     */

    int some_func_name_d(int a)
    {
        return some_bad_func(a);
    }    

    int some_func_name_c(int a)
    {
        return some_func_name_d(a);
    }    

    int some_func_name_b(int a)
    {
        return some_func_name_c(a);
    }

    int some_func_name_a(int a)
    {
        return some_func_name_b(a);
    }

    int private_crashsim(int n)
    {
        return some_func_name_a(n);
    }
    
    class SomeClass
    {
        class Impl
        {
        public:
            
            Impl(int n)
            {
                symbols.resize(n); // do stuff
            }

            void crash(int n)
            {
                crashsim(n);
            }

        protected:
            
            std::vector<int> symbols;
        };
        
    public:

        SomeClass(int n)
        {
            m_pImpl = std::make_shared<Impl>(n);
        }

        void crash()
        {
            m_pImpl->crash(1024);
        }
        
        std::shared_ptr<Impl> m_pImpl;
    };

    class CrashClass
    {
    public:
        
        CrashClass()
        {
            m_some = std::make_shared<SomeClass>(1024);
        }

        void crash()
        {
            m_some->crash();
        }
        
        std::shared_ptr<SomeClass> m_some;
    };
    
    int crashsim(int n)
    {
        CrashClass crasher;
        crasher.crash();
        return 0;
    }
}

