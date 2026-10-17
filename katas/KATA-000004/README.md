# KATA-000004 — Gossiping Bus Drivers (Erlang/OTP 28)

- **Original source:** https://kata-log.rocks/gossiping-bus-drivers-kata
- **Description rights:** Kata-Log's own content declared public domain (Unlicense); no linked starter code, tests or assets copied.
- **This source, tests, and documentation:** original MIT, governed by the root LICENSE.

## Independently worded contract

Each bus driver runs a nonempty periodic sequence of stop identifiers and initially knows one distinct rumor. At a simultaneous stop visit, all drivers at the same stop exchange their *entire* knowledge. Count the **starting stop encounter as visit 1**. After at most 480 such visits, return the first count where every driver has every rumor, otherwise return \`never\`.

Source examples: the three routes \`[3,1,2,3]\`, \`[3,2,3,1]\`, \`[4,2,3,4,5]\` converge at visit **5**; \`[2,1,2]\` and \`[5,2,8]\` never converge. This off-by-one convention is deliberate.

## Language choice

Erlang's immutable values and pure round-to-round transitions fit a synchronous information-propagation model, while map-based grouping of simultaneous stops and integer bitmasks expose algebraic join and fixed-point invariants. Genkidama's BEAM CI already demonstrates Erlang/OTP toolchain setup, which is adapted here without importing implementation code.

**Alternatives:** Elixir provides similar BEAM semantics; Haskell emphasizes typed pure transformations; Go emphasizes concurrent workers. Erlang is a productive contrast to the existing Java/PHP/Fortran katas and keeps the distinction between a **synchronous simulation** and actual concurrent actor messaging explicit.

## Tests and local replay

~~~bash
cd katas/KATA-000004
mkdir -p /tmp/ninja-gossip-red /tmp/ninja-gossip-green
erlc -o /tmp/ninja-gossip-red tests/red_stub/gossip.erl tests/gossip_tests.erl
if erl -noshell -pa /tmp/ninja-gossip-red -s gossip_tests run -s init stop > /tmp/ninja-gossip-red.txt 2>&1; then exit 1; fi
grep -q 'assertion_failed' /tmp/ninja-gossip-red.txt
erlc -o /tmp/ninja-gossip-green src/gossip.erl src/gossip_cli.erl tests/gossip_tests.erl
erl -noshell -pa /tmp/ninja-gossip-green -s gossip_tests run -s init stop
python3 tests/differential.py /tmp/ninja-gossip-green
~~~

RED is an intentionally nonfunctional yet compilable \`gossip\` implementation; GREEN uses the actual original implementation. Fixed tests cover original examples, initial sharing, 1 driver, delayed sharing, the 480-visit horizon through parameterization, and malformed inputs.

Python differential oracle enumerates **1521 two-driver route pairs** (all lengths 1–3 over three stop IDs), **729 three-driver route triples** (length two) and **128 seeded random cases** = **2378** independent comparisons. The Python algorithm uses sets; Erlang uses bitmask union.

## Limits and invariants

- API \`gossip:solve(Routes)\` or \`gossip:solve(Routes, MaxVisits)\`, returning a positive integer or the atom \`never\`.
- Between 1 and 16 drivers; 1–64 nonnegative integer stop IDs per route.
- Time O(V × N × L) worst-case with V ≤ 480, N drivers and L maximum route length (\`lists:nth\` list indexing); transient space O(N + distinct stops in one round) beyond input.
- Stop groups merge from the **previous** round; knowing all rumors is monotone, but a static route intersection is not enough.
- Line-oriented CLI uses routes separated by \`|\`, stop IDs separated by comma. Example: \`3,1,2,3|3,2,3,1|4,2,3,4,5\`; output \`5\`.

## Evaluation and evidence

Provisional weighted rubric: transfer 19/20, depth 19/20, oracle 15/15, TDD 14/15, novelty 9/10, pedagogy 9/10, portability 4/5, maintenance 4/5 = **93/100**. Difficulty **5/5 provisional**, motivated by graph propagation, periodic routes, simultaneous transactions and time-origin edge cases. These are **single-reviewer judgments**, not an independent ranking.

Evidence: [RED](evidence/red.txt), [GREEN](evidence/green.txt), [oracle](evidence/oracle.txt), [CI](evidence/ci.txt), [Ninja skill review](evidence/skill_review.md). No \`verified\` or \`published\` claim until remote CI and reviewed merge.
