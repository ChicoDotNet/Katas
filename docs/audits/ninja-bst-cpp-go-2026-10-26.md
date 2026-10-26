# Ninja KATA-000055 — binary search tree, 26 Oct 2026

Baseline at start: dev 0d97c338cb8702265ad6fda4381cbd9336197f61; main c52ca4262066782f7e5046458da630335110c6f1. dev catalog 26 published / 4 green / 31 discovered / 61 total; PR #45–#49 remain unmerged. This audit creates no new ID and does not count publication.

Selected existing discovered candidate after checking Exercism MIT license for the specific description blob. Domain invariants and C++/Rust/Ada/Haskell trade-offs characterized before inspecting C++ CI. Implementation C++20 unique_ptr and iterative traversal; native RED/GREEN C++20; independent oracle Go stable sequence partition + multiset sorting + permutation metamorphism. No Python.

Local execution repeated: GCC 14.2, Go 1.23.2; 6,876 native assertions, 355+355 Go cases, 2/2 compiled mutants killed, RED compiled and failed behaviorally, Go race and C++ ASan/UBSan successful. Full run exit 0. Initial self-referential permutation check replaced with real second CLI query. Shared duplicate-placement semantics remain a limitation. Independent holdout still required at 90 published.

Ninja v0.1.29: confirmed, no skill mutation. Time not instrumented, no causal claims. GREEN local only; PR/CI exact-head and independent review required. No push to dev/main.
