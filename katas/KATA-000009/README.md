# KATA-000009 — Ten-pin Bowling (C11)

Reference: https://kata-log.rocks/bowling-game-kata. Kata-Log states its own page content is public domain; NO third-party starter code, libraries, or test fixtures imported. Original MIT implementation written independently.

**Contract:** Ten frames, strikes (10 pins on first roll) award next two rolls, spares award next one, final frame allows exactly the required bonus rolls, open frames have two rolls. A complete valid game returns an integer score 0..300. Invalid/incomplete games return -1. Reject pin values outside 0..10 and frames exceeding the 10-pin total. Roll API accepts individual events; score is computed only when a complete game is present. No per-ball timestamps or persistence.

**Why C:** stateful low-level parsing, capacity bounds and rolling score bonuses make C11's fixed-size records and explicit error returns a useful exercise in memory-safe boundaries without runtime allocation. Alternatives COBOL and Pascal suit frame records; C exposes off-by-one and array-index errors. Python's independent oracle models 10 frames separately rather than duplicating the C index scanner.

~~~sh
cd katas/KATA-000009
cc -std=c11 -Wall -Wextra -Werror -pedantic src/bowling.c tests/test.c -o /tmp/bowl-test
/tmp/bowl-test
cc -std=c11 -Wall -Wextra -Werror -pedantic src/bowling.c src/main.c -o /tmp/bowl-cli
python3 tests/differential.py /tmp/bowl-cli
cc -std=c11 -Wall -Wextra -Werror -pedantic tests/red_stub.c tests/test.c -o /tmp/bowl-red
if /tmp/bowl-red > /tmp/bowl-red.log 2>&1; then exit 1; fi
grep -q 'Assertion' /tmp/bowl-red.log
~~~

Locally: 8 fixed behavioral checks; 600 random *valid, complete* games independently scored by a Python frame model; RED compiled but failed due to wrong score. Compiler GCC14.2.0 with -Werror. Memory complexity O(1) with 21 roll slots, time O(1) for 10 frames. Provisional author rating 88/100 and difficulty 5/5; calibration pending.

Evidence: evidence/red.txt, green.txt, oracle.txt, ci.txt, skill_review.md.
