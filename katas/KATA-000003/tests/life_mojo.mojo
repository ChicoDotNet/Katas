# SPDX-License-Identifier: MIT
# Original fixed-size packed-cell stencil; Fortran's matrix implementation is unchanged.
def next_bits(bits: Int, height: Int, width: Int) -> Int:
    var evolved = 0
    for r in range(height):
        for c in range(width):
            var neighbors = 0
            for dr in range(-1, 2):
                for dc in range(-1, 2):
                    if dr == 0 and dc == 0:
                        continue
                    var nr = r + dr
                    var nc = c + dc
                    if nr >= 0 and nr < height and nc >= 0 and nc < width:
                        var index = nr * width + nc
                        if ((bits >> index) & 1) == 1:
                            neighbors += 1
            var position = r * width + c
            var living = ((bits >> position) & 1) == 1
            if neighbors == 3 or (living and neighbors == 2):
                evolved |= 1 << position
    return evolved

def emit_exhaustive(height: Int, width: Int):
    for bits in range(1 << (height * width)):
        print(next_bits(bits, height, width))

def main():
    emit_exhaustive(1, 1)
    emit_exhaustive(2, 3)
    emit_exhaustive(3, 3)
    var seed = 20261017
    for _ in range(100):
        seed = (seed * 1103515245 + 12345) % 2147483647
        print(next_bits(seed % (1 << 24), 4, 6))
