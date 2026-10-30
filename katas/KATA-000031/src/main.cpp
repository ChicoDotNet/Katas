// SPDX-License-Identifier: MIT
#include "yatzy.hpp"
#include <iostream>
#include <sstream>
#include <string>
int main() {
  std::string line;
  while (std::getline(std::cin, line)) {
    std::istringstream input(line);
    std::array<int, 5> dice{};
    bool valid = true;
    for (int &die : dice) if (!(input >> die)) { valid = false; break; }
    std::string extra;
    if (input >> extra) valid = false;
    if (!valid) { std::cout << "ERR\n"; continue; }
    try {
      auto scores = yatzy::Roll(dice).score();
      for (size_t i = 0; i < scores.size(); ++i) std::cout << (i ? " " : "") << scores[i];
      std::cout << '\n';
    } catch (const std::invalid_argument &) { std::cout << "ERR\n"; }
  }
}
