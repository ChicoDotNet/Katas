#pragma once
#include <cstddef>
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>

namespace microblog {
// Return nullopt for malformed UTF-8. Count Unicode scalar values, not bytes,
// UTF-16 code units or extended grapheme clusters.
inline std::optional<std::string> truncate(std::string_view input, std::size_t max_scalars = 5) {
#ifdef RED_STUB
    return std::string(input.substr(0, max_scalars));
#else
    std::size_t i = 0;
    std::size_t boundary = 0;
    std::size_t scalars = 0;
    while (i < input.size()) {
        const auto lead = static_cast<unsigned char>(input[i]);
        std::uint32_t cp = 0;
        std::size_t width = 0;
        if (lead < 0x80) { cp = lead; width = 1; }
        else if (lead >= 0xC2 && lead <= 0xDF) { cp = lead & 0x1F; width = 2; }
        else if (lead >= 0xE0 && lead <= 0xEF) { cp = lead & 0x0F; width = 3; }
        else if (lead >= 0xF0 && lead <= 0xF4) { cp = lead & 0x07; width = 4; }
        else { return std::nullopt; }
        if (width > input.size() - i) return std::nullopt;
        for (std::size_t j = 1; j < width; ++j) {
            const auto b = static_cast<unsigned char>(input[i + j]);
            if ((b & 0xC0) != 0x80) return std::nullopt;
            cp = (cp << 6) | (b & 0x3F);
        }
        if ((width == 2 && cp < 0x80) ||
#ifndef MUTANT_ACCEPT_OVERLONG
            (width == 3 && cp < 0x800) ||
#endif
            (width == 4 && cp < 0x10000) ||
            (cp >= 0xD800 && cp <= 0xDFFF) || cp > 0x10FFFF) return std::nullopt;
        i += width;
#ifndef MUTANT_OFF_BY_ONE
        if (scalars < max_scalars) boundary = i;
#else
        if (scalars + 1 < max_scalars) boundary = i;
#endif
        ++scalars;
    }
    return std::string(input.substr(0, boundary));
#endif
}
}
