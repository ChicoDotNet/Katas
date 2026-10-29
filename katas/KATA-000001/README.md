# KATA-000001 — Ugly Trivia: original legacy/refactor laboratory

**Public-domain kata topic:** [Kata-Log Ugly Trivia](https://kata-log.rocks/ugly-trivia-kata). **Original GPL starter (attribution only, NOT copied):** [jbrains/trivia](https://github.com/jbrains/trivia). Kata-Log's own page is public-domain; that status does **not** license the linked third-party starter.

This is **an independently designed trivia game** exercising the *Golden Master / characterization / refactoring* skill featured by Ugly Trivia. It is **not a faithful port or behavior-preserving refactor of jbrains/trivia**: that would require handling its GPL license. All source/tests/fixtures here are original MIT.

## Independent contract

A round-robin game with 2–6 named players starts everyone at station 0. A valid die roll is 1–6. There are 12 stations, four repeating question categories (LOGIC, NATURE, HISTORY, ARTS), each with independent increasing question IDs. Right answers yield one star; five wins and terminates the game. A wrong answer pauses that player; on a following turn an odd roll causes SKIP, while an even roll causes RETURN and allows them to move and answer. A roll moves clockwise with wrap-around. Output events (WELCOME, TURN, SKIP/RETURN, MOVE, ASK, RIGHT/WRONG, WIN/NO_WINNER) form the observable protocol.

These rules and strings were authored for this exercise. They are **not** a claim that the upstream GPL game uses the same protocol or game rules.

## Why Java?

Legacy enterprise OO code commonly interleaves control flow, mutations and output. Java 21-compatible source on a Java 25 CI runner makes a characterization-first refactor executable without extra dependencies. Java is also available in Genkidama's JVM family. Alternatives considered: COBOL (valuable for batch legacy processing, but less apt for this stateful OO exercise); Scala (functional refactoring useful, but a second abstraction jump obscures before/after contrast); PHP (previous Banking kata already exercised its OO ports).

## Reproduce a genuine behavioral RED, then GREEN

~~~bash
cd katas/KATA-000001
mkdir -p /tmp/trivia-red /tmp/trivia-green
javac --release 21 -d /tmp/trivia-red src/TriviaCli.java src/TriviaLegacy.java tests/RedStub.java tests/TestTrivia.java
if java -cp /tmp/trivia-red TestTrivia > /tmp/trivia-red.log 2>&1; then exit 1; fi
grep -q 'refactored behavioral golden master mismatch' /tmp/trivia-red.log
javac --release 21 -d /tmp/trivia-green src/*.java tests/TestTrivia.java
java -cp /tmp/trivia-green TestTrivia
python3 tests/differential.py /tmp/trivia-green
~~~

The RED stub compiles and **fails for the intended observable behavior**, not for a missing file. The fixed transcript is an authored reference example. The legacy simulator is an original deliberately tangled implementation (no third-party code imported). The refactored simulator uses explicit immutable participant values and a game boundary. A Python dictionary-based **independent oracle** verifies generated scenarios in *both* implementations, not merely Java-versus-Java agreement.

## Input

~~~text
PLAYERS Ada,Bea
2 C
1 W
5 C
~~~

First line names (2–6, unique), then lines \`roll C|W\`; call \`java -cp /tmp/trivia-green TriviaCli refactored\` or \`legacy\`. Empty scenario is valid. Invalid arguments/input cause a nonzero exit.

## Evidence

- Behavioral RED: [evidence/red.txt](evidence/red.txt)
- Golden Master GREEN: [evidence/green.txt](evidence/green.txt)
- Python oracle: [evidence/oracle.txt](evidence/oracle.txt)
- CI run: [evidence/ci.txt](evidence/ci.txt)
- Ninja lesson: [evidence/skill_review.md](evidence/skill_review.md)

Provisional score (not externally calibrated): transfer 19/20 + depth 19/20 + oracle 14/15 + TDD 14/15 + novelty 8/10 + pedagogy 9/10 + portability 4/5 + maintenance 4/5 = **91/100**. Difficulty 5/5 is a kata-program author estimate based on Kata-Log's Experienced, Golden Master and Refactoring labels, not an empirical population-ranked score.

Complexity: time O(P + T) for P participants and T scripted turns for refactored implementation (bounded questions/categories); memory O(P + transcript length). The intentionally ugly legacy implementation uses repeated string concatenation, which may be less efficient; speed is not a goal of Golden Master verification.

**Do not claim that this proves refactoring a GPL codebase without seeing that code**; it proves the technique on an original analogous system.

## Retroactive event-stream hardening (2026-10-29; pending independent review)

This is **KATA-000001 again**, not a new kata or language migration. The published Java implementation and original Python forward-model oracle remain unchanged. The new Ruby 3.3 contract monitor consumes emitted events, reconstructs state from the transcript, and checks round-robin order, stations, category numbering, pause/return, scores, winner termination and absence of trailing events. Unlike the Python oracle, it does not generate an expected full transcript first. It is complementary, **not mathematically independent of all game rules**, because both depend on the same authored contract.

| Role | Language | Technique and rationale |
| --- | --- | --- |
| Implementation | Java 21 | Original OO legacy/refactor contrast; no migration |
| RED/GREEN | Java 21 | Compilable failing stub and fixed Golden Master |
| Original oracle | Python 3 | Forward state simulation over generated scenarios |
| Additional contract monitor | Ruby 3.3 | Parse and validate actual event stream as a stateful protocol |
| Metamorphisms | Ruby 3.3 | Alpha-renaming of participants; prefix/terminal extension |
| Mutation controls | Java 21 + Ruby | Compile wrong rotation, category sequence, and score persistence |

Compared a **forward simulator** (Python, retained) against a **trace contract monitor + metamorphic relations** (Ruby, added). Considered Java (too easy to reuse the same event types) and Prolog (declarative constraints attractive but little advantage for line-oriented protocol parsing); Ruby's regex/string processing and Open3 process integration fit this test harness. Counterfactual: translating the Python simulator into Ruby would preserve its structural assumptions and add little detection power. Limits: test input generation is bounded; no external GPL code was imported; alpha-renaming assumes generated names P0..Pn and Q0..Qn. No causal Ninja claim.

Reproduction from repository root:

~~~bash
bash katas/KATA-000001/tests/run_trace_hardening.sh
# Optional expanded stochastic monitor (requires compiled classes):
TRIVIA_CASES=12 ruby katas/KATA-000001/tests/trace_contract.rb /tmp/trivia-green
~~~

The required runner compiles and checks RED/GREEN, runs five deterministic trace scenarios in both modes (550 event/metamorphic assertions), then compiles and detects three mutants. The original Java workflow separately runs the Python oracle (196 scripts x two implementations plus five rejected inputs). The optional extended monitor passed previously but its rerun on 2026-10-29 timed out in Open3, so its reliability needs further investigation and it is **not** a CI requirement. See [evidence/trace-hardening-2026-10-29.md](evidence/trace-hardening-2026-10-29.md).
