# Ninja KATA-000041 local certification checkpoint — 2026-10-27

- Original ID/fingerprint KATA-000041 / exercism-spec-linked-list; dev base 0d97c338cb8702265ad6fda4381cbd9336197f61, catalog 9e303fc1eb0fe964d84e10fb85b19e43148ca4ee.
- Rights: MIT Exercism exercises/linked-list/instructions.md blob edf4055b38ca35950a3600fa268e267763b69a17, root LICENSE blob 6813d6298df9a46da6485050e8a5fcd61ab79879; original C++/Ruby implementation and tests, no upstream code copied.
- Domain: doubly linked ordered route, duplicates, negative/Int64 bounds, bidirectional topology, copy/move and iterative destructor safety.
- Compared C++20/Rust/Swift/Haskell before checking Genkidama; C++20 selected for ownership and pointer semantics. Native C++ tests and Ruby Array oracle chosen independently. Graph/arena model rejected as sharing topology implementation; array event model plus inverse metamorphism chosen.
- Authentic local GCC 14.2.0 + Ruby 3.3.8: RED behavioral failure, GREEN 64,420 assertions with ASan/UBSan, 90 Ruby histories/21,150 C++ commands, six invalid requests, 2/2 compiled mutants detected, full exit 0. Hardening: iterative destruction of 50,000 nodes and second mutant after first full run.
- Ninja v0.1.29 skill SHA 32cb01f2e088453762f5c79239d1f11e6991bf83, conclusion confirmed; no skill change, no causal attribution.
- Provisional difficulty 4/5, score 79/100 (transfer 16, depth 15, oracle 16, TDD 12, novelty 6, pedagogy 7, portability 3, maintenance 4). No independent calibration.
- This record documents local evidence; remote branch and CI may follow separately. No independent review, merge, publication or new source scan in this checkpoint.
