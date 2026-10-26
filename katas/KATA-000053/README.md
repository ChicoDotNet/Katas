# KATA-000053 — POV: immutable tree rerooting and paths (Swift + Go)

**Status: GREEN locally on 2026-10-26, NOT verified or published.** This PR proposes the existing discovered candidate as `green + development_complete`; exact-head CI and independent review are separate certification gates. The dev catalog remains authoritative until reviewed squash merge.

## Domain, invariants and contract

A rooted, uniquely labelled tree is viewed from another vertex. `fromPov(target)` produces a new tree rooted at that vertex; all original vertices and undirected edges are preserved, only their orientation changes. The original tree is immutable. `path(from:to:)` returns the unique simple path inclusive of both endpoints. Missing labels and ambiguous duplicate labels return `nil`. Sibling ordering is intentionally not part of the contract: the upstream canonical specification permits a former parent before or after existing children.

Invariants: `|V|=n`, `|E|=n-1`, connected, unique labels, no missing/repeated edges, correct root, unique simple path. Metamorphic: reroot twice at the original root preserves the undirected graph; path reversal reverses endpoint order. Single reroot O(n) time/memory, path O(n); recursive depth O(h) may overflow on extreme trees.

## Independent language decisions, before inspecting CI

**Implementation: Swift 6.2.** Recursive value-semantic `Tree` struct with `[Tree]` children, Codable JSONL and persistent ancestor-context rebuilding. Swift tests concrete value-copy semantics without parent pointers, mutation or shared references. **Haskell** offers elegant functional algebraic trees; **OCaml** immutable ADTs; **Go** adjacency graphs and BFS. All viable, but Swift's value semantics are the distinctive learning objective; CI convenience was not a selection criterion. Using Go as implementation would lose this focus.

**Native RED/GREEN: Swift.** Explicit examples and generated trees; 15,355 assertions, structural edge preservation, reversible reroot, missing/duplicate labels and paths. `-D KATA_RED` compiles and fails by behavior; `DROP_SIBLINGS` and `REVERSE_PATH` mutations killed.

**Independent oracle: Go 1.23.2.** Undirected adjacency graph + BFS to orient edges and reconstruct shortest paths. 1,540 JSONL requests to a real Swift process across 70 independently generated trees. Unlike Swift ancestor reconstruction, this is a graph traversal. Alternative strategy: directly reverse the parent chain and compare recursive trees; rejected as too close to Swift. Additional metamorphic reversibility and path-reversal properties complement BFS. Both models share unique-label assumptions, JSON schema and sibling-order insensitivity; independent holdouts still needed. Python is not used.

## Executed local commands

```bash
cd katas/KATA-000053
bash tests/run.sh
# Includes swiftc -swift-version 6 -D KATA_RED src/POV.swift tests/Native.swift
# swiftc -swift-version 6 src/POV.swift tests/Native.swift
# swiftc -swift-version 6 -O src/POV.swift src/Main.swift
# go test -race tests/oracle.go tests/oracle_test.go
# go run tests/oracle.go /path/to/pov-cli
# swiftc -swift-version 6 -D KATA_MUTANT_DROP_SIBLINGS ...
# swiftc -swift-version 6 -D KATA_MUTANT_REVERSE_PATH ...
```

Swift 6.2.1, Go 1.23.2 Linux x86_64: **exit 0**; RED behavioral failure; 15,355 native assertions; 1,540 Go→Swift calls; 2/2 mutants killed; Go race detector PASS. Reran the full suite in this integration after fixing Go oracle's premature EOF masking: EOF is now a failure. No remote CI success is inferred.

## License and provenance

Conceptual contract: Exercism `problem-specifications/exercises/pov/canonical-data.json`, blob `b10d346bd6c0061b09e9b4593cca4e06659bb43e`; MIT repository LICENSE blob `6813d6298df9a46da6485050e8a5fcd61ab79879`, Exercism copyright 2014/2019/2021. Both blobs checked directly. No upstream source code, starters, fixtures, canonical JSON cases or example trees copied. Original Swift, Go and tests are MIT Katas material; Exercism attributed for the concept.

## Ninja and limitations

Ninja v0.1.29 review `confirmed`; no skill change or causal attribution. Provisional difficulty 4/5, score 87/100 (single author, not calibrated). Retrabajo: Swift 6 concurrency harness, path-copy optimization, and Go EOF hardening. Active engineering time not instrumented. Require exact-head CI, independent review and squash merge into dev before publication; next main release at 36 published.
