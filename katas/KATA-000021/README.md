# KATA-000021 — Roman Numerals (Prolog DCG + Go reference)

**Status:** unverified draft until actual SWI-Prolog RED/GREEN and Go oracle execute. Never count as published until independently reviewed, exact-head CI green, and squash merge to `dev`.

## Domain and rights

Original clean-room solution for modern **canonical** Roman numerals in the range 1..3999. The concept is described at https://kata-log.rocks/roman-numerals-kata, whose own content is declared public domain. The starter repositories linked from that page have NOT been copied or assumed public domain. Source, fixtures, scripts and tests in this directory were authored for Katas under MIT. Reject 0, negatives, values over 3999, leading zeros and non-decimal CLI input; reverse parsing rejects noncanonical Roman text. These are explicit local contract decisions, not claims about every historical Roman notation.

## Problem first, language second

Invariants: exactly one canonical representation per valid integer; place-wise subtractive forms limited to IV/IX, XL/XC, CD/CM; no illegal repetitions or inversions; encode/decode round-trip; CLI one response per input line. Complexity: bounded four-place grammar; 3999 inputs. Failure modes: noncanonical spellings, 4000+, accidental permissive input, malformed reverse parsing.

Compared before examining workflows:

- **Prolog**: DCG represents a grammar as a bidirectional relation, allowing both encoding and parsing without duplicating the syntax rules. This is the most distinctive semantic fit.
- **Haskell**: ADTs and parser combinators make canonical grammar explicit, but ordinary encoders and parsers require more machinery for a reversible relation.
- **COBOL**: decimal numeric editing is idiomatic but symbolic subtractive grammar less so; would teach formatting more than relational language design.
- **Ruby**: succinct tables, but the language does not itself make the grammar bidirectional.

Counterfactual: using Java/Go by habit would likely produce another greedy token loop and lose the opportunity to explore reversible DCGs. The compiler/runtime choice was NOT made because CI already existed.

## Independent testing decisions

| Role | Language | Technique |
|---|---|---|
| Implementation | SWI-Prolog | DCG with canonical digit-place productions, reversible numeral relation |
| RED/GREEN | SWI-Prolog `plunit` | Behaviorally wrong `red_stub`, fixed cases, invalid forms, 3999 round-trips |
| Oracle | Go 1.23 | Greedy integer subtraction with 13 value/token pairs, structurally different from DCG |
| Secondary check | Go 1.23 | Adjacent-symbol signed arithmetic decoder and +1000 metamorphic prefix |
| Mutation gate | SWI-Prolog + Go | Three compiled alternate DCGs, each must produce a differential mismatch |

Compared **DCG-first** canonical grammar (chosen implementation) with **greedy descending integer subtraction** (independent reference). The second is easier to inspect and detects wrong DCG productions. Numeric signed decoding detects arithmetic mismatch independently of the greedy loop, and +1000 metamorphism detects incorrect thousands placement. Shared risk: all three assume the same modern canonical 1..3999 convention and ASCII alphabet. Do not infer historical coverage or independent correctness from a different language alone.

## Reproducible commands

```bash
sudo apt-get update && sudo apt-get install --no-install-recommends -y swi-prolog-nox
bash katas/KATA-000021/tests/run.sh
```

Genkidama source consulted after language selection: `ChicoDotNet/Genkidama` `eng/ci/registry.json`, `eng/ci/run-family`, and `.github/workflows/polyglot.yml` (functional family installs `swi-prolog-nox` on Ubuntu 24.04). GitHub workflow: `.github/workflows/kata-000021-roman-prolog.yml`.

## Limitations and Ninja

A simple bounded kata, not a hardest-first replacement for higher-difficulty eligible work. All higher-priority candidates identified at the checkpoint already have development PRs; verify concurrency before integration. `Ninja v0.1.29`: `no_change` pending authentic SWI execution and independent review; no causal claim about skill benefit. No holdouts modified.
