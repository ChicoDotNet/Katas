# KATA-000039 — SGF Tree Parsing (Perl 5)

Conceptual reference: [Exercism SGF Parsing](https://github.com/exercism/problem-specifications/tree/main/exercises/sgf-parsing) and its [MIT repository license](https://github.com/exercism/problem-specifications/blob/main/LICENSE). Source, fixtures, implementation and independent tests here were **written from scratch**; no upstream canonical test data or starter source copied.

**Explicit contract subset:** accept exactly one parenthesized SGF game tree, with at least one semicolon-delimited node. Each node has zero or more uppercase-keyed properties with one or more bracket values, preserving all values (including repeated property keys); semicolon sequences create a single-child chain; parenthesized variations branch from the last sequence node. Bracket-escaped closing brackets and backslashes produce literal characters, and escaped physical line continuations are removed. Unescaped content inside values is preserved. Invalid syntax, trailing material, node-count/depth limits and input over 8192 characters yield no tree. Full SGF semantics, Unicode normalization, and domain-specific property validation are **not** implemented.

Perl 5 was chosen for character scanning, nested data structures and core JSON::PP/Test::More availability without dependencies; JavaScript/TypeScript is plausible but covered by Forth. A **generator-first Python oracle** constructs ASTs, serializes them with controlled escaping and compares Perl's parsed AST to the original; it does not trust a second parser's agreement.

~~~sh
cd katas/KATA-000039
perl -Ilib tests/test_sgf.t
KATA_RED=1 perl -Ilib tests/test_sgf.t > /tmp/sgf-red.log 2>&1 && exit 1
grep -q 'not ok 1' /tmp/sgf-red.log
python3 tests/differential.py cli.pl
~~~

GREEN: 15 deterministic acceptance/invalid tests, plus 330 independently generated ASTs and 10 invalid documents = **340** oracle cases. RED is an importable, behaviorally wrong variant that declines every input; no compilation failure. Provisional author difficulty 5/5, score 91/100; neither is externally calibrated.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md).

## Extensión políglota de verificación — 17-oct-2026

**OCaml AST-first**, `tests/sgf_ast_ocaml.ml`, genera 180 árboles tipados y los serializa a SGF con escapes; el parser Perl debe recuperar el mismo AST. Contrasta el generador previo Python sin reescribir la implementación. Se compararon Haskell (ADT), F# (tipos suma) y OCaml; OCaml destaca por el árbol tipado y el generador pequeño con stdlib. Workflow `ocaml-sgf-kata.yml`.

No se aumenta el número de katas publicadas por esta extensión. Mantener evidencia histórica y exigir CI exact-head.
