#include "Truncate.hpp"
#include <iostream>
#include <string>

namespace {
int nibble(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}
std::optional<std::string> from_hex(const std::string& line) {
    if (line.size() % 2 != 0) return std::nullopt;
    std::string out;
    out.reserve(line.size() / 2);
    for (std::size_t i = 0; i < line.size(); i += 2) {
        const int a = nibble(line[i]);
        const int b = nibble(line[i + 1]);
        if (a < 0 || b < 0) return std::nullopt;
        out.push_back(static_cast<char>((a << 4) | b));
    }
    return out;
}
void print_hex(std::string_view s) {
    static constexpr char digits[] = "0123456789abcdef";
    for (const unsigned char c : s) {
        std::cout << digits[c >> 4] << digits[c & 0x0F];
    }
    std::cout << '\n';
}
}
int main() {
    std::string line;
    while (std::getline(std::cin, line)) {
        const auto bytes = from_hex(line);
        if (!bytes) { std::cout << "ERR\n"; continue; }
        const auto answer = microblog::truncate(*bytes);
        if (!answer) { std::cout << "ERR\n"; continue; }
        print_hex(*answer);
    }
    return 0;
}
