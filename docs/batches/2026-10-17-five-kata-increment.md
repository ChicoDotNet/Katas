# Ninja EXP-001: five-kata development and release checkpoint

Date: 2026-10-17. Before this batch, 14/90 were published; Fortran Knapsack was verified in PR #24 and recorded as the 15th publication.

All five new katas were developed sequentially while CI overlapped: KATA-000044 Dominoes (Go, 952 independent scenarios); KATA-000039 SGF Parsing (Perl, 340); KATA-000046 Word Search (Swift, 400); KATA-000047 VLQ (PHP, 1003); KATA-000056 Circular Buffer (C11, 600). Total 3295 independent reference scenarios; every kata has behavioral RED, GREEN, reproducible oracle, original MIT solution, attribution and bounded Ninja observation. Ninja advanced from v0.1.14 to v0.1.19. These are engineering observations, NOT controlled skill transfer results.

Exact certified code SHA: efbd61ce18f97eb224d31a51d6251b57d6d4c1d3. All 22 GitHub workflows passed on this SHA, then PR #25 merged into dev at fd7e2abe0decefd5762a7badb23ed9281ab1ebcf. Promotion of five kata records to published takes the count to 20/90 when this publication PR merges. This crosses the first 18-kata mandatory main milestone: create a reviewed dev-to-main release PR promptly, then verify/synchronize ancestry according to docs/governance/delivery.md. Do not promote unfinished red/green work. Next mandatory promotion is 36 published.
