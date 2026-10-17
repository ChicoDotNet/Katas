# KATA-000042 — Tree Building (PHP 8)

Concept: https://github.com/exercism/problem-specifications/tree/main/exercises/tree-building; root license MIT https://github.com/exercism/problem-specifications/blob/main/LICENSE. Independent PHP source, fixtures and Python oracle MIT. The linked exercise mentions refactoring a legacy implementation; this kata uses an **original clean-room reconstruction**, NOT the externally hosted legacy starter.

A collection of n=1..1000 unsorted records must contain each id 0..n-1 exactly once, with root (0,0). Every nonroot record has an integer parent 0<=parent<id. Return a recursively nested tree with all siblings ordered by ascending id; reject duplicate, missing or invalid IDs and parents. Input order does not affect output. No network/database layer, actual original legacy refactor or authorization to copy upstream starters is implied.

PHP chosen for JSON-like records and nested arrays. The implementation validates a dense set, constructs parent-child adjacency, then recursively builds canonical ordered nodes. Python independently assembles nodes from highest id downwards. Complexity O(n), memory O(n), bounded input 1000. Parent ordering excludes cycles by construction. Deep nesting may require a stricter recursion budget in production.

~~~sh
cd katas/KATA-000042
php -l src/TreeBuilding.php
php tests/test_tree.php
python3 tests/differential.py src/cli.php
if KATA_RED=1 php tests/test_tree.php >/tmp/tree-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/tree-red.log
~~~

Locally: 4 deterministic trees, 7 invalid inputs, 1000 independently generated scenarios and behavioral RED. The invalid fixture generator initially sometimes produced valid trees and was repaired before GREEN. Provisional author score 89/100 difficulty 4/5, not calibrated. Evidence under evidence/, Ninja OBS-030.
