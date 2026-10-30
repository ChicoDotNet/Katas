# KATA-000018 — Ohce (Perl 5.40 + Ruby 3.3)

**Status:** GREEN locally; `development_complete=true`. NOT verified or published. GitHub CI exact-head and independent review are required.

## Contract

Spanish reverse-echo streaming CLI: `--name NAME`, optional `--hour 0..23` for reproducibility. Night [20,06), morning [06,12), afternoon [12,20). Reverse each line by extended Unicode grapheme clusters (Perl `\X`), case/normalization-sensitive palindrome detection with `¡Bonita palabra!` for nonempty palindromes. Exact `Stop!` prints `Adios NAME` and terminates; lower-case `stop` is ordinary input. Malformed CLI arguments, duplicate flags, and malformed UTF-8 input rejected. Streaming implementation does not prebuffer the whole conversation.

## Language decision before CI

| Candidate | Distinctive benefit | Counterfactual |
| --- | --- | --- |
| **Perl 5.40 (chosen)** | Streaming text, grapheme regex, core Test::More | Dynamic runtime validation at boundaries |
| Swift 6 | Native grapheme-aware String | CLI boilerplate obscures the streaming exercise |
| Kotlin | Explicit typed state | JVM startup and IO overhead |
| Ruby 3.3 | Expressive transcript construction | Better deployed as independent oracle |

Selected language before inspecting Genkidama scripting-linux registry and adapting CI; CI availability did not drive choice.

## Independent verification matrix

| Role | Language | Strategy |
| --- | --- | --- |
| Implementation | Perl 5.40 | Streaming CLI and pure session functions |
| RED/GREEN | Perl Test::More | Parseable wrong implementation fails; 36 assertions pass real implementation |
| Oracle | Ruby 3.3 | Generate expected transcript from declarative command history, run real Perl process |
| Metamorphic | Ruby + Perl | Reverse twice returns original grapheme sequence (60 observed pairs) |
| Mutation | Ruby + Perl | 3 syntax-valid mutants, each killed by behavioral mismatch |

**Alternative oracle considered:** direct Ruby translation of the Perl streaming loop, rejected because it could share Stop! and control-flow defects. The transcript-first model derives expected events independently. **Shared-error risk:** both runtimes use Unicode grapheme segmentation rules; boundaries, combining marks and hour edges are anchored in native tests. No external holdout or causal Ninja attribution.

## Local commands and results

```bash
cd katas/KATA-000018
bash run.sh
OHCE_IMPL=OhceRed perl -I src tests/native.t  # expected RED failure
perl -I src tests/native.t                      # 36 GREEN assertions
ruby tests/oracle.rb                            # 604 transcript sessions, 60 metamorphic pairs, 8 invalid CLI cases plus malformed UTF-8 input
ruby tests/mutations.rb                         # 3/3 syntax-valid mutants killed
```

Local rerun 2026-10-30: Perl 5.40.1, Ruby 3.3.8, all gates passed. See `evidence/local-suite.txt` and `evidence/skill_review.md`.

## Rights and Ninja

Concept from https://kata-log.rocks/ohce-kata — only Kata-Log's own public-domain description used; no linked starter, fixtures, images or third-party implementation copied. Source/tests/workflow are original MIT. Ninja v0.1.29 review `no_change`; concrete encoding and empty-transcript issues were corrected without promoting a universal rule.
