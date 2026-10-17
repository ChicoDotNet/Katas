# KATA-000048 — Connect / Hex Winner in C++20

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/connect (MIT: https://github.com/exercism/problem-specifications/blob/main/LICENSE). Original code/tests here under MIT; no upstream canonical data or starter imported.

Nonempty rectangular ASCII grid of ., O or X, up to 64×64. O wins by connecting top to bottom, X by connecting left to right, with six Hex neighbors: (r-1,c),(r-1,c+1),(r,c-1),(r,c+1),(r+1,c-1),(r+1,c). Boards may be unfair. Invalid grids rejected; a hypothetical dual winner rejected. One-cell O/X board yields corresponding winner. CLI rows separated by |.

C++20 BFS search is independently compared with Python union-find and virtual goal nodes. O(H×W) graph traversal and memory. Run in katas/KATA-000048: compile src/connect.cpp with tests/test_connect.cpp under g++ -std=c++20 -Wall -Wextra -Werror -pedantic; compile src/main.cpp plus src/connect.cpp, then python3 tests/differential.py /path/to/cli. RED compiles with -DKATA_RED and must fail a behavioral assertion.

Local: 12 fixed win checks, 2 invalid boards, 1500 independent DSU comparisons. Fixed a RED-only unused height warning before accepting RED under -Werror. Provisional author 5/5 difficulty, 92/100 score; not independently calibrated.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md).

## Extensión políglota de verificación — 17-oct-2026

**SWI-Prolog para conectividad Hex**, `tests/prolog_connect.pl`, expresa adyacencia como relación y evalúa 455 tableros con DFS declarativo; contrasta BFS C++ y complementa union-find Python. OCaml, Haskell y Prolog eran opciones; la unificación relacional permite explorar la existencia de caminos. Workflow `prolog-crosscheck-katas.yml`.

No se aumenta el número de katas publicadas por esta extensión. Mantener evidencia histórica y exigir CI exact-head.
