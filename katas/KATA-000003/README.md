# KATA-000003 — Conway's Game of Life (Fortran 2008)

Source: [Kata-Log Game of Life](https://kata-log.rocks/game-of-life-kata). The Kata-Log page states its own content is public domain. **No starter repos, licensed code, images or datasets were imported.** Original solution, tests and documentation: MIT.

## Contract

For a finite rectangular Boolean grid, a living cell survives with two or three living neighbors; a dead cell is born with exactly three. All other cells die/remain dead. Neighbors are the eight surrounding positions. Outside coordinates are always dead (no wrapping). Evaluate all new cells against the *previous* board, simultaneously; input remains unchanged.

## Language choice

GNU Fortran (2008) is selected for its native multidimensional arrays, index discipline and pure numeric transformations. Julia would offer concise array operations; Python is suitable as a reference implementation. We do not claim Fortran is universally better. Genkidama already has a gfortran toolchain job in its GNU family workflow; nothing was imported.

## Run

~~~sh
cd katas/KATA-000003
# Behavioral RED: deliberate all-dead stub fails the stable-block test
gfortran -std=f2008 -Wall -Wextra -fcheck=all tests/life_red_stub.f90 tests/test_life.f90 -o /tmp/ninja-red
! /tmp/ninja-red
# GREEN: original correct implementation, six fixed patterns
gfortran -std=f2008 -Wall -Wextra -fcheck=all src/life_core.f90 tests/test_life.f90 -o /tmp/ninja-lifetest
/tmp/ninja-lifetest
# Cross-implementation oracle: 677 boards
gfortran -std=f2008 -Wall -Wextra -fcheck=all src/life_core.f90 src/life_cli.f90 -o /tmp/ninja-life-cli
python3 tests/test_differential.py /tmp/ninja-life-cli
~~~

The CLI consumes a first line of rows and columns then one row of 0/1 characters per line; writes the next generation. The implementation takes O(rows×columns) time and space. It is bounded at 256×256 cells in CLI input.

## Evidence and rubric

- RED: [expected behavioral failure](evidence/red.txt) with an intentionally wrong, separately versioned [stub](tests/life_red_stub.f90).
- GREEN: [six fixed-pattern tests](evidence/green.txt) including static block, oscillator, corner and extinction.
- Oracle: [677 differential boards](evidence/oracle.txt): exhaustive 1×1, 2×3, 3×3 and 100 deterministically seeded 4×6 boards.
- Local toolchain and planned remote CI: [evidence](evidence/ci.txt). CI from GitHub Actions is a **separate verification gate**.
- Skill review: [observation confirmed](evidence/skill_review.md), no new transferable rule promoted.

Provisional rubric (out of 100): transfer 17/20 + depth 14/20 + oracle 14/15 + TDD 13/15 + novelty 7/10 + pedagogy 9/10 + portability 5/5 + maintenance 4/5 = **83**. This is a single-reviewer estimate to be calibrated, not an objectively validated ranking.

License evidence: [Kata-Log footer](https://kata-log.rocks/game-of-life-kata). The **original** MIT code in this folder does not derive from linked starter kits.

## Extensión políglota de verificación — 17-oct-2026

**Mojo 1.1 bitboard stencil (aditivo).** Nuevo `tests/life_mojo.mojo` usa celdas empaquetadas en bits y una vecindad independiente del arreglo Fortran. El verificador `tests/life_mojo_crosscheck.mjs` compara **678 tableros** exhaustivos/semillados; reproduce con el workflow `mojo-life-kata.yml` y Pixi fijado en `tests/pixi.toml`. No sustituye el núcleo Fortran ni el oráculo Python. Se consideraron Julia (matrices), Rust (bits) y Mojo (kernel/value computation); Mojo gana por el experimento de cómputo especializado.

No se aumenta el número de katas publicadas por esta extensión. Mantener evidencia histórica y exigir CI exact-head.
