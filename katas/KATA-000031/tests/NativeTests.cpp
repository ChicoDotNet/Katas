// SPDX-License-Identifier: MIT
#include "../src/yatzy.hpp"
#include <array>
#include <iostream>
#include <stdexcept>
#include <cstdlib>
using yatzy::Roll;
int checks = 0;
void eq(int actual, int expected) {
  ++checks;
  if (actual != expected) { std::cerr << "assertion " << checks << ": got " << actual << " expected " << expected << "\n"; std::exit(1); }
}
int main() {
  auto s = Roll({1,2,3,4,5}).score();
  eq(s[6],15); eq(s[12],15); eq(s[13],0); eq(s[7],0);
  s = Roll({2,3,4,5,6}).score(); eq(s[13],20); eq(s[12],0);
  s = Roll({6,6,6,6,6}).score(); eq(s[7],50); eq(s[11],24); eq(s[14],0); eq(s[8],12);
  s = Roll({2,2,3,3,3}).score(); eq(s[8],6); eq(s[9],10); eq(s[10],9); eq(s[14],13); eq(s[7],0);
  s = Roll({1,1,3,3,6}).score(); eq(s[8],6); eq(s[9],8); eq(s[14],0);
  s = Roll({4,4,4,4,1}).score(); eq(s[10],12); eq(s[11],16); eq(s[14],0);
  s = Roll({1,1,1,1,1}).score(); eq(s[0],5); eq(s[6],5);
  bool rejected = false; try { (void)Roll({0,1,2,3,4}); } catch (const std::invalid_argument &) { rejected = true; }
  eq(rejected,1);
  std::cout << "GREEN C++20 " << checks << " native assertions PASS\n";
}
