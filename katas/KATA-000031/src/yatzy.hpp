// SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <stdexcept>
#include <algorithm>
#include <numeric>

namespace yatzy {
using Scores = std::array<int, 15>;
class Roll {
 public:
  explicit Roll(std::array<int, 5> dice) : dice_(dice) {
    for (int die : dice_) if (die < 1 || die > 6) throw std::invalid_argument("die outside [1,6]");
  }
  [[nodiscard]] Scores score() const {
    std::array<int, 6> counts{};
    for (int die : dice_) ++counts[die - 1];
    Scores out{};
    for (int face = 1; face <= 6; ++face) out[face - 1] = face * counts[face - 1];
    out[6] = std::accumulate(dice_.begin(), dice_.end(), 0); // chance
    out[7] = *std::max_element(counts.begin(), counts.end()) == 5 ? 50 : 0; // yatzy
    const auto highest_group = [&](int n) {
      for (int face = 6; face >= 1; --face) if (counts[face - 1] >= n) return face;
      return 0;
    };
    const int pair = highest_group(2);
    out[8] = 2 * pair;
    int first = 0, second = 0;
    for (int face = 6; face >= 1; --face) {
      if (counts[face - 1] >= 2) {
        if (!first) first = face;
        else if (!second) second = face;
      }
    }
    out[9] = second ? 2 * (first + second) : 0;
    out[10] = 3 * highest_group(3);
    out[11] = 4 * highest_group(4);
    out[12] = counts[5] == 0 && std::all_of(counts.begin(), counts.begin() + 5, [](int n){return n == 1;}) ? 15 : 0;
    out[13] = counts[0] == 0 && std::all_of(counts.begin() + 1, counts.end(), [](int n){return n == 1;}) ? 20 : 0;
    int trip = 0, exact_pair = 0;
    for (int face = 1; face <= 6; ++face) {
      if (counts[face - 1] == 3) trip = face;
      if (counts[face - 1] == 2) exact_pair = face;
    }
    out[14] = trip && exact_pair && trip != exact_pair ? 3 * trip + 2 * exact_pair : 0;
    return out;
  }
 private:
  std::array<int, 5> dice_;
};
}
