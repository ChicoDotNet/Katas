# KATA-000054 — Satellite Tree Reconstruction (Java 21)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/satellite, MIT https://github.com/exercism/problem-specifications/blob/main/LICENSE. Original Java source, tests and Python generator under MIT; no starter or canonical fixture imported.

Given preorder and inorder traversals of unique integers, reconstruct immutable binary tree. Render as value(left)(right), using . for empty. Reject mismatched lengths, duplicates, distinct value sets or impossible subtrees. Empty traversal yields .; integers can be negative. CLI protocol: two comma-delimited traversals separated by |, one scenario per line. Java21 record and hash-based inorder positions yield O(n) construction time and O(n) space for valid input.

Python independently generates expected trees first, serializes their preorder/inorder traversals, and compares Java's result to the known original. No competing reconstruction routine is used.

Commands in katas/KATA-000054: `mkdir -p /tmp/satellite && javac --release 21 -Xlint:all -Werror -d /tmp/satellite src/*.java tests/TestSatellite.java && java -cp /tmp/satellite TestSatellite && python3 tests/differential.py /tmp/satellite`. RED: `KATA_RED=1 java -cp /tmp/satellite TestSatellite` must fail behaviorally.

Local JDK21/Python3: 6 fixed reconstructions, 4 invalid checks, 905 generator-first differential scenarios; behavioral RED confirmed. Author provisional difficulty 5/5 and score 92/100, not independently calibrated. Highly skewed trees can reach runtime call-stack limits; production inputs require depth budgeting.

Evidence files under evidence/; Ninja observation OBS-024.
