#include "../../src/Truncate.hpp"
#include <cassert>
#include <cstddef>
#include <iostream>
#include <string>
#include <string_view>

static int assertions = 0;
static void eq(std::string_view input, std::string_view expected, std::size_t n = 5) {
    const auto got = microblog::truncate(input, n);
    assert(got.has_value());
    assert(*got == expected);
    assertions += 2;
}
static void invalid(std::string_view input) {
    assert(!microblog::truncate(input).has_value());
    ++assertions;
}
int main() {
    eq("", "");
    eq("abcdef", "abcde");
    eq("abcde", "abcde");
    eq("abc", "abc");
    eq("a\xC3\xA9\xE6\x97\xA5\xF0\x9F\x98\x9B" "bcd", "a\xC3\xA9\xE6\x97\xA5\xF0\x9F\x98\x9B" "b");
    eq("a\xCC\x81" "bcde", "a\xCC\x81" "bcd"); // combining mark is a scalar
    eq("\xF0\x9F\x91\xA9\xE2\x80\x8D\xF0\x9F\x92\xBB" "abc", "\xF0\x9F\x91\xA9\xE2\x80\x8D\xF0\x9F\x92\xBB" "ab");
    eq("abcdef", "", 0);
    eq("abcdef", "abcdef", 99);
    eq("\x00" "abcdef", "\x00" "abcd");
    invalid("\xC0\xAF");
    invalid("\xE0\x80\x80");
    invalid("\xED\xA0\x80");
    invalid("\xF4\x90\x80\x80");
    invalid("\xF0\x9F\x98");
    invalid("abcde\xFF"); // validation is whole-input, not only truncated prefix
    invalid("abcde\xE0\x80\x80");
    invalid("\x80");
    for (int n = 0; n <= 100; ++n) {
        const std::string input(static_cast<std::size_t>(n), 'z');
        const std::string expected(static_cast<std::size_t>(n < 5 ? n : 5), 'z');
        eq(input, expected);
    }
    std::cout << "NATIVE_PASS assertions=" << assertions << '\n';
}
