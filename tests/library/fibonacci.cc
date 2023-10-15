/**
 * @file fibonacci.cc
 * @author your name (you@domain.com)
 * @brief The Fibonacci library.
 * @version 0.1
 * @date 2023-10-13
 *
 * @copyright Copyright (c) 2023
 *
 */

#include "fibonacci.h"

namespace fibonacci {

/**
 * @brief Returns the nth Fibonacci number
 *
 * @param n The nth Fibonacci number to return
 *
 * @return The nth Fibonacci number
 */
std::uint64_t fibonacci(std::uint64_t n) {
    if (n < 2) {
        return n;
    }

    std::uint64_t n1 = 0;
    std::uint64_t n2 = 1;
    for (std::uint64_t i = 1; i < n; ++i) {
        std::uint64_t sum = n1 + n2;
        n1 = n2;
        n2 = sum;
    }

    return n2;
}

}  // namespace fibonacci
