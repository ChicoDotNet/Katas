# KATA-000061 — Micro Blog, strict Unicode scalar truncation

**Status: GREEN LOCAL, development complete; NOT remotely certified, reviewed or published.** Existing catalog identity `KATA-000061` / `exercism-spec-micro-blog`. Prepared 2026-10-27 against `dev` SHA `0d97c338cb8702265ad6fda4381cbd9336197f61`; `catalog/candidates.json` blob `9e303fc1eb0fe964d84e10fb85b19e43148ca4ee`. No direct writes to dev/main.

## Contract and invariants

Return at most five Unicode **scalar values** (code points), not bytes, UTF-16 code units or grapheme clusters. A combining mark or zero-width joiner counts as a separate scalar; this matches the upstream exercise's explicit codepoint requirement, even though a different product might prefer grapheme-aware truncation. Preserve original UTF-8 bytes of the retained prefix, never cut a multi-byte encoding, and reject any malformed UTF-8 **anywhere in the input**, including after the fifth scalar. Input is a hex-encoded byte string per line; output is lowercase hex of the truncated valid bytes or `ERR` for malformed hex/UTF-8. This ASCII transport is original to the experiment and permits testing invalid byte sequences without lossy console conversions. The pure library function accepts a configurable scalar limit; the CLI fixes it to five. Complexity O(input bytes) time for full validation and O(prefix bytes) output memory. No normalization, grapheme segmentation, locale-dependent case folding or concurrency.

## Source and rights, per artifact

Concept only: [Exercism micro-blog description.md](https://github.com/exercism/problem-specifications/blob/main/exercises/micro-blog/description.md), Git blob `d6c6cf65613fcc07cf362aaaf2031f7414380d0d`; [repository MIT LICENSE](https://github.com/exercism/problem-specifications/blob/main/LICENSE), blob `6813d6298df9a46da6485050e8a5fcd61ab79879`. Copyright (c) 2014, 2019, 2021 Exercism, MIT terms apply to the source conceptual description. Original C++ source, CLI protocol, native tests, Ruby oracles, random scenarios and mutation definitions are authored here. **No upstream canonical-data.json, starters, fixtures, tests or copied instructions**. Existing catalog URL/fingerprint retained; no new source scan.

## Language decision, before examining CI

Compared **C++20**, **Swift**, **Rust** and **Ruby**. Swift `UnicodeScalarView` and Rust `chars()` provide robust scalar iteration but conceal the byte-validation boundary; Ruby `codepoints` similarly makes the exercise short. C++20 deliberately exposes the UTF-8 state machine, overlong encodings, surrogate exclusion and truncation boundary, providing a valuable security/encoding lesson. Its downside is more code and an elevated risk of validator bugs; native tests, sanitizers, mutations and independent Ruby models address that risk. Reusing a usual Go/Python string slice would obscure the codepoint-versus-byte distinction; using Swift again would reduce the focus on validation. This is an affinity decision, not a diversity quota or CI convenience.

Only after the selection: checked Genkidama `dev` `eng/ci/registry.json` blob `24bde39c748dd3903789fd20eace80894a4735fb`, native family and its adapters. Prepared explicit C++20/Ruby GitHub Actions workflow; local compilers are GCC 14.2.0 and Ruby 3.3.8. No claim that Genkidama runs this kata automatically.

## Independent verification choices

| Responsibility | Language | Technique | Risk / independence |
| --- | --- | --- | --- |
| Implementation | C++20 | Strict manual UTF-8 decoding, scalar counter, byte boundary | Overlong/surrogate/truncated input and off-by-one |
| Native RED/GREEN | C++20 | Compile a deliberately incorrect byte-slice variant; assert behavior, then sanitizer GREEN | Exercises the actual library, not the oracle |
| Oracle A | Ruby 3.3 | Generate a list of Unicode scalar tokens, concatenate them, derive expected prefix from the **token list**, never parse bytes to compute the expected result | Detects C++ decoder and boundary errors without copying its algorithm |
| Oracle B | Ruby 3.3 | Generate arbitrary valid Unicode scalars; Ruby's `String#codepoints` provides independent runtime decoding | Shares Unicode scalar definition, but not parser implementation |
| Metamorphic | Ruby → C++ | Re-run C++ on outputs (idempotence) and with appended scalar after >=5 scalars (suffix invariance) | Verifies actual process twice; limited to specified transformation |
| Mutations | C++20 + Ruby | Compile off-by-one and permissive-overlong variants; reject through differential oracle | Two targeted defects, not an exhaustive mutation score |

Alternative strategies evaluated: (1) a second manual byte-state decoder in Ruby, rejected as structurally duplicated; (2) a token-first generator and a runtime Unicode decoder with metamorphic execution, selected. Grapheme-cluster counting was explicitly **rejected** because it would violate the conceptual contract. Ruby and C++ may still share Unicode-standard assumptions; targeted malformed-byte cases and generator expectations mitigate but do not prove full correctness.

## Commands and executed evidence

From `katas/KATA-000061`: `bash tests/run.sh`. It compiles a behavioral RED stub with `g++ -std=c++20`, compiles and runs native GREEN under ASan/UBSan, executes the C++ CLI from Ruby with two independent reference strategies, reruns the CLI for idempotence/suffix invariance, and compiles two mutants. Actual local execution **twice** on GCC 14.2.0 / Ruby 3.3.8: RED expected failure, 230 native assertions, 2,541 oracle cases (1,800 token-first; 700 independent runtime; 36 malformed UTF-8; 5 malformed hex), 2,500 idempotence checks, 2,152 suffix checks, 2/2 mutants killed, full exit 0. See `evidence/local-run.txt`. The RED abort is expected and not an infrastructure failure. GitHub CI **not executed** for this kata as of this checkpoint; no remote certification.

## Ninja and limitations

Ninja v0.1.29 skill blob `32cb01f2e088453762f5c79239d1f11e6991bf83` reviewed with conclusion `confirmed`: explicit byte/codepoint distinction and adversarial encodings reinforce existing principles. No skill modification, general causal claim or independent calibration. Provisional difficulty 4/5; score 78/100 (transfer 16, depth 14, oracle 16, TDD 12, novelty 7, pedagogy 7, portability 3, maintenance 3). No Unicode conformance suite, Unicode-version reconciliation, fuzz coverage guarantee or performance benchmark; do not infer production readiness from this kata.
