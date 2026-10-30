# KATA-000031 — Yatzy: C++20 and Go oracle

Status: GREEN locally, NOT published. Conceptual source: https://kata-log.rocks/yahtzee-kata. Kata-Log declares its own page text public domain; linked third-party starter code is NOT included or assumed public domain. Implementation and tests original under MIT.

## Contract

Five dice, each integer 1–6. Each input line holds exactly five dice. Output fifteen integers in this order: ones, twos, threes, fours, fives, sixes, chance, yatzy, highest pair, two distinct pairs, highest triple, highest quadruple, small straight (1–5), large straight (2–6), full house (exact 3+2 distinct faces). Yatzy scores 50. Highest eligible group is selected. Invalid input produces ERR and processing continues. Scoring categories are alternatives, not accumulated scorecard state.

## Language selection, before CI

Compared C++20, Ada, Haskell, Ruby. C++20 chosen for typed bounded std::array and explicit Roll invariant; Ada stronger subtypes but GNAT not installed locally; Haskell pattern matching but GHC absent; Ruby compact yet less static checking. Habitual Java would obscure the compact fixed-size representation. Workflow adapted only after language choice, using Genkidama registry as toolchain reference.

## Verification strategies

Implementation: C++20 six-face histogram. RED/GREEN: native C++20 with compilable behavioral RED stub and 24 GREEN assertions. Independent Go oracle: enumerate subsets of physical dice indices (not face histogram), choose disjoint pairs and triple/complement; sorted dice for straights. Rejected alternative: second histogram scorer because it could share implementation defects. Metamorphism: 1,000 shuffled rolls compared with actual C++ outputs. Mutation gate: Python orchestrates three independently compiled C++ mutants; Go oracle rejects all three. Python is not a differential oracle. Shared risk: both models implement this locally specified Yatzy variant and same category order, not a formally independent published specification.

7,776 exhaustive ordered rolls plus 1,000 permutations yield 8,776 × 15 = 131,640 differential assertions. Eight malformed lines rejected. 3/3 mutants killed.

Reproduce: bash katas/KATA-000031/tests/run.sh (GCC C++20, Go 1.23.2, Python 3). Workflow: .github/workflows/cpp-yatzy-kata.yml. Local evidence: evidence/local-run.txt. CI exact-head is required before verified, independent review and squash merge before published.

Ninja v0.1.29 review: no_change; useful independent verification in this case, no causal skill claim or holdout change.
