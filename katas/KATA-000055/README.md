# KATA-000055 — Binary Search Tree (C++20, Go)

**GREEN local; NOT remotely certified, reviewed or published.** This branch is a proposed catalog transition. Do not count publication until exact-head CI, independent review, squash merge and post-merge verification.

## Domain and invariants

Insert signed integers into an unbalanced BST. Left descendants are <= their parent, right descendants strictly greater. Duplicate keys go left. Insertion order determines topology; inorder is the sorted multiset. Test empty trees, negatives, signed 32-bit extremes, duplicates, degenerate chains. Insertion O(h); iterative inorder O(n) time and O(h) auxiliary space. Worst-case insertion O(n²) for sorted input; balancing would change the kata.

## Language selection before workflow selection

| Role | Selected | Affinity and counterfactual |
| --- | --- | --- |
| Implementation | C++20 | RAII unique_ptr exposes ownership and null topology. Rust Box offers stronger compile-time borrow safety, Ada access types illuminate storage pools, Haskell ADTs favor immutable structure but not this mutable ownership experiment. |
| RED/GREEN | C++20 | Native assertions plus compile-time RED/mutants and ASan/UBSan exercise ownership and signed comparison boundaries. |
| Independent oracle | Go 1.23 | Stable recursive partition of the *input sequence* (<= vs >) derives topology without C++ incremental pointer insertion; independently sort the multiset and compare metamorphic shuffled input by a second real CLI execution. A second insertion-tree implementation risks common algorithm errors; sorting alone misses wrong topology. |

Risk: both languages share the duplicate-left interpretation, so independently designed holdouts remain necessary. Python is not used.

## Real local execution

Run from repository root: `cd katas/KATA-000055 && bash tests/run.sh`.

Toolchains GCC 14.2 and Go 1.23.2: RED compiles and fails behaviorally; GREEN 6,876 native assertions; Go oracle 355 original + 355 shuffled differential/metamorphic executions; two compiled mutants killed; Go race detector PASS; ASan/UBSan PASS. Full suite exit 0.

Commands:
```bash
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -O2 -D KATA_RED tests/Native.cpp -o .build/red
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -O2 tests/Native.cpp -o .build/native
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -O2 src/Main.cpp -o .build/cli
go test -race tests/oracle.go tests/oracle_test.go
go run tests/oracle.go "$(pwd)/.build/cli"
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer tests/Native.cpp -o .build/native-asan
ASAN_OPTIONS=detect_leaks=1 .build/native-asan
```

## Rights, Ninja and limits

Conceptual exercise: Exercism problem-specifications/exercises/binary-search-tree/description.md, blob 7625220e9a0fb2412ea4c5432e87b1309d425ff1, MIT LICENSE (copyright Exercism 2014, 2019, 2021). No upstream starter, fixtures or canonical tests imported. C++/Go and tests are original, MIT.

Ninja v0.1.29: confirmed, no skill change or causal transfer claim. Rework: replaced tautological Go-side permutation check with second authentic C++ execution. Active time not instrumented. Deep unbalanced trees can incur quadratic insertion and recursive unique_ptr destruction. Independent review, CI exact-head and 90-published holdout remain pending. Next main release gate: 36 published.
