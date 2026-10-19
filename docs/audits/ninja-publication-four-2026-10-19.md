# Ninja certification reconciliation — 2026-10-19

Base dev SHA: 0d97c338cb8702265ad6fda4381cbd9336197f61. Catalog before: 26 published, 4 green/development_complete, 31 discovered. No README snapshot used.

The four katas were authored in PR #31 (head e561dc55700771fd5cc8800b07f093cfd5918fd6), squash merged as 12653c1f9b9281eb1e3495f8171dd161e19e0353. GitHub compare from that merge to the audited dev SHA reports no modifications to these four kata directories, catalog, or Ninja skill. Original code and fixtures are locally authored under Katas MIT LICENSE; Exercism MIT specification URLs are concept references only, not copied starters. Per-artifact claims rely on the existing authored evidence, not on a forensic plagiarism audit.

| Kata | Implementation | Native tests | Independent model | Differential cases | Exact PR-head CI | Post-merge CI |
| --- | --- | --- | --- | ---: | --- | --- |
| KATA-000042 | PHP 8.4 | PHP | Python bottom-up assembly versus PHP recursive adjacency | 1000 | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39067317574) | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39069984374) |
| KATA-000043 | Java 21 | Java | Python modular pow versus Java BigInteger.modPow, Alice/Bob symmetry | 1005 | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39067317653) | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39069984486) |
| KATA-000050 | Fortran 2018 | Fortran | Python itertools combinations versus bitmask enumeration | 2525 | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39067317487) | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39069984378) |
| KATA-000057 | Go 1.23 | Go, race detector | Python sequential Counter versus concurrent worker/reducer | 907 | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39067317500) | [pass](https://github.com/ChicoDotNet/Katas/actions/runs/39069984492) |

All eight named workflow jobs and their native RED/GREEN/oracle steps have completed with success, not skipped. The four RED tests are intentionally behaviorally incorrect and are asserted to fail by a known failure message. Alternative oracle strategies considered and rejected: tree-shape-only assertions (miss ordering), custom modular exponent (shared arithmetic risk), second bitmask enumerator (same indexing bug), and second parallel counter (same race/partition risk). Structural differences improve fault detection, but shared specification assumptions remain.

Limits: Tree Building is not a legacy starter refactor; Java Diffie-Hellman is educational only, not secure protocol engineering; Killer Sudoku is a cage helper, not a board solver; Go's simple Unicode lowercase differs from full casefold and a passing race detector is not proof of race freedom. Ninja OBS-030/029/027/028 remain individual observations, not demonstrated transfer.

Publication becomes effective only after this metadata PR passes its own exact-head catalog and all four kata workflows, is squash-merged to dev, and the resulting dev HEAD and 30/90 count are verified. This does not create four new katas or new language migrations. Next mandatory main release is 36 published; independent pilot gate remains 90.
