# KATA-000041 — Linked List: C++20 ownership and Ruby event-array oracle

**Status: GREEN LOCAL, development complete; NOT remotely verified or published.** Existing catalog ID KATA-000041 / fingerprint exercism-spec-linked-list. Work prepared on 2026-10-27 against dev SHA 0d97c338cb8702265ad6fda4381cbd9336197f61. No code copied from third-party starters.

## Domain and invariants

A doubly linked list represents an ordered train route with signed 64-bit station IDs (duplicates allowed). Operations: push_front, push_back, pop_front, pop_back, erase_first, size, forward/reverse traversal, deep copy, copy assignment, move, move assignment. Empty pops return no value; erase deletes the first occurrence. CLI reads one ASCII command per line, emits one deterministic response, rejects malformed commands with nonzero exit. A chain of unique_ptr owns successor nodes; non-owning prev and tail pointers must remain consistent. valid() verifies both directions and size. Iterative clear() avoids recursive destructor stack overflow for deep chains. Insertion/deletion at ends O(1), erase-first O(n), traversal/copy O(n), memory O(n). No concurrent access or iterator-stability contract.

## Rights audit

Concept only from Exercism MIT exercises/linked-list/instructions.md (blob edf4055b38ca35950a3600fa268e267763b69a17), root LICENSE blob 6813d6298df9a46da6485050e8a5fcd61ab79879. Original C++ code, tests, Ruby model, CLI protocol, generated scenarios and mutations authored for this kata. No upstream starter, canonical-data.json, fixtures, code, images or external tests copied. Attribution applies to conceptual source only.

## Language selection before workflow

Compared C++20, Rust, Swift, Haskell. C++20 selected for explicit unique ownership of next links, non-owning back links, move/copy rules and ASan/UBSan. Rust would require Rc/RefCell/Weak or arena indices and shift focus to borrow management. Swift ARC/value semantics simplify safe ownership; Haskell persistent singly linked lists do not teach in-place unlinking. Go slices would obscure pointer topology. No selection was made for CI convenience. Only afterward checked Genkidama dev eng/ci/registry.json blob 24bde39c748dd3903789fd20eace80894a4735fb, native and scripting families, and adapted C++20 + Ruby toolchains to Ubuntu 24.04 Actions.

## Independent verification matrix

| Role | Language | Method |
| --- | --- | --- |
| Implementation | C++20 | Owned pointer chain, raw non-owning back links, iterative teardown |
| RED/GREEN | C++20 | Compilable behavioral RED, 64,420 assertions, pointer topology, 50,000-node destruction |
| Oracle | Ruby 3.3.8 | Array event model, 90 histories, 21,150 commands against real C++ process |
| Metamorphic | Ruby driving C++ | Push/pop inverse and reverse traversal |
| Mutation | C++20 | Two compiled mutants: wrong erase position and pop from wrong end |

Compared an independent arena/graph model (shares link-topology assumptions) against Ruby Array event replay (chosen: no pointers) and inverse-operation metamorphism (complementary). Ruby and C++ share semantic contract for first occurrence and signed 64-bit values; deterministic seeds do not replace independent holdouts. Native C++ vector checks alone are not sufficient; Ruby drives the compiled process. No Python differential oracle.

## Reproduce

Run: cd katas/KATA-000041 && bash tests/run.sh

Actually executed GCC 14.2.0, Ruby 3.3.8 on Linux x86_64 with -std=c++20 -Wall -Wextra -Werror -pedantic -fsanitize=address,undefined. RED compiled and failed with NATIVE FAIL; GREEN 64,420 assertions; 50,000-node iterative destruction; Ruby 90 histories / 21,150 genuine C++ commands; six invalid commands rejected; 2/2 compiled mutants detected; exit 0. First full run passed with 64,419 assertions and one mutant; hardening added iterative teardown/deep-chain regression and second mutant, then full rerun PASS. Remote workflow prepared; certification requires exact-head CI and independent review.

## Ninja and governance

Ninja v0.1.29 SHA 32cb01f2e088453762f5c79239d1f11e6991bf83, confirmed; no skill edit or causal claim. Not a transfer holdout. Difficulty 4/5, ranking 79/100 provisional, not independently calibrated. Publication requires exact-head CI, substantive independent review, squash merge to dev, post-merge SHA/catalog/CI, and the 36-published release milestone before next mandatory main promotion. Existing PR #45 remains publication priority.
