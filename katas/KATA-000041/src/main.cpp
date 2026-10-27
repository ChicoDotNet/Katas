#include "DoublyList.hpp"
#include <charconv>
#include <cstdint>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

static bool parse_int(const std::string& text, std::int64_t& v) {
    const char* begin = text.data();
    auto [end, error] = std::from_chars(begin, begin + text.size(), v);
    return error == std::errc{} && end == begin + text.size();
}
static void print_values(const std::vector<std::int64_t>& values) {
    std::cout << "LIST " << values.size();
    for (auto v : values) std::cout << ' ' << v;
    std::cout << '\n';
}
int main() {
    DoublyList list;
    std::string line;
    while (std::getline(std::cin, line)) {
        std::istringstream in(line);
        std::string command, arg, extra;
        in >> command;
        const bool takes_value = command == "PUSH_FRONT" || command == "PUSH_BACK" || command == "ERASE";
        std::int64_t value = 0;
        if (takes_value) {
            if (!(in >> arg) || (in >> extra) || !parse_int(arg, value)) {
                std::cerr << "invalid integer command\n"; return 2;
            }
        } else if (in >> extra || (command != "POP_FRONT" && command != "POP_BACK" &&
                     command != "SNAP" && command != "REV" && command != "SIZE" && command != "CHECK")) {
            std::cerr << "invalid command\n"; return 2;
        }
        if (command == "PUSH_FRONT") { list.push_front(value); std::cout << "OK\n"; }
        else if (command == "PUSH_BACK") { list.push_back(value); std::cout << "OK\n"; }
        else if (command == "ERASE") { std::cout << (list.erase_first(value) ? "FOUND" : "MISS") << '\n'; }
        else if (command == "POP_FRONT" || command == "POP_BACK") {
            auto result = command == "POP_FRONT" ? list.pop_front() : list.pop_back();
            if (result) std::cout << "VALUE " << *result << '\n'; else std::cout << "MISS\n";
        }
        else if (command == "SNAP") print_values(list.values());
        else if (command == "REV") print_values(list.reverse_values());
        else if (command == "SIZE") std::cout << "SIZE " << list.size() << '\n';
        else if (command == "CHECK") std::cout << (list.valid() ? "VALID" : "INVALID") << '\n';
        if (!list.valid()) { std::cerr << "corrupted linked-list invariants\n"; return 3; }
    }
}
