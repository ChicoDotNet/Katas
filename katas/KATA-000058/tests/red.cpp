// SPDX-License-Identifier: MIT
// RED is intentionally behaviorally wrong but compiles and runs.
#include <iostream>
#include <vector>
#include <string>
std::vector<std::string> format_stub() { return {"Date       | Description               | Change       "}; }
int main() {
  auto actual=format_stub();
  if(actual.size()!=2) { std::cerr<<"EXPECTED RED: missing formatted entry\n"; return 1; }
  return 0;
}
