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
