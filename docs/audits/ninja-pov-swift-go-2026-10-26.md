# Ninja audit — KATA-000053 POV — 2026-10-26

- Identity: existing KATA-000053 / exercism-spec-pov. No new scan or ID.
- Rights: Exercism conceptual canonical-data blob b10d346bd6c0061b09e9b4593cca4e06659bb43e and MIT LICENSE blob 6813d6298df9a46da6485050e8a5fcd61ab79879. No starter, fixture or canonical case copied; original Swift and Go MIT.
- Domain: persistent rooted-tree reorientation and unique simple paths, preserving nodes and undirected edges.
- Language comparison before CI: Swift (value semantics), Haskell (functional ADT), OCaml (persistent variant), Go (graph). Swift chosen for immutable Swift structs and Codable; Go independently for graph/BFS reference, not diversity quota.
- Tests: Swift native RED/GREEN, structural/metamorphic edge preservation, reversibility, path invariants. Go graph/BFS orientation and shortest-path oracle. Parent-chain reversal reference rejected as structurally too similar to Swift. Shared risk: unique labels, tree contract, JSON schema and sibling order.
- Genkidama reference: Swift family in Polyglot CI; this Katas workflow uses authentic Swift 6.2 and Go 1.23.2.
- Executed locally: Swift 6.2.1, Go 1.23.2; RED compiles/fails behaviorally; GREEN 15,355 assertions; Go -race PASS; 1,540 differential/metamorphic JSONL calls across 70 generated trees; 2/2 mutants killed; bash tests/run.sh exit 0.
- Hardening this integration: Go oracle previously ignored io.EOF from Swift child; fixed to reject premature EOF; full suite rerun.
- Ninja v0.1.29 confirmed, no skill edit or causal inference. Holdout pending.
- GREEN local only; exact-head CI, independent review and squash merge pending. No publication, release or new scan.
- Provisional difficulty 4/5 and score 87/100 uncalibrated. Retrabajo: Swift concurrency harness, path optimization, Go EOF. Active time unmeasured.
