// SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <stdexcept>
namespace yatzy {
using Scores=std::array<int,15>;
class Roll { public: explicit Roll(std::array<int,5>) {} Scores score() const { return {}; } };
}
