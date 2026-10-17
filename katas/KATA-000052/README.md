# KATA-000052 — Immutable Binary Tree Zipper (TypeScript)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/zipper (MIT: https://github.com/exercism/problem-specifications/blob/main/LICENSE). This is an original TypeScript implementation with original Python oracle, no copied starter or canonical fixtures.

Zipper = focus plus crumbs (parent value, sibling tree, traversed side), supporting left, right, up, setValue, setLeft, setRight, toRoot and unchanged original trees. Navigation into absent child returns null. Edits produce new values without mutating old zippers. CLI accepts JSON tree and valid command histories; this is a binary-tree subset, not a general rose-tree deletion API.

TypeScript structural tree types/readonly breadcrumb frames suit persistent reconstruction. Independent Python reference directly mutates a copied full root at the current path, not crumbs. O(depth) parent reconstruction. Caller-side mutation of shared JavaScript objects is out of scope (not deep frozen).

Local Node22/tsc strict: 12 assertions, 420 independently generated tree-edit histories, behaviorally failing RED. Run `cd katas/KATA-000052 && tsc -p . && node build/tests/test_zipper.js && python3 tests/differential.py build/src/cli.js`; KATA_RED=1 node build/tests/test_zipper.js should fail. Provisional author difficulty 5/5, score 93/100, not independently calibrated.

Evidence under evidence/, Ninja OBS-026. Compiled build/ is excluded from Git.
