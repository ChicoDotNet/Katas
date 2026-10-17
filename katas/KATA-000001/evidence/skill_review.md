# KATA-000001: Ninja knowledge review

Conclusion: **incorporated as a bounded observation**, supported by GitHub-hosted checks; no controlled holdout validation yet. No claim of universal transfer improvement.

**OBS-004 candidate:** For entangled mutable programs where unit isolation is unsafe, controlling all sources of input and capturing observable outputs provides a characterization baseline *before* structural refactoring. An output Golden Master demonstrates observational equivalence only for the sampled traces. It can faithfully preserve existing defects; complement with independent contract examples and randomized scenarios.

Evidence layers:
1. An original deterministic legacy Java game with deliberately mixed presentation/state/control flow.
2. One human-authored fixed example checked for both legacy and new implementations.
3. A deliberately wrong substitute refactor that must fail *behaviorally*.
4. A distinct Python oracle which calculates the game rules without trusting the Java legacy implementation.
5. Reproducible GitHub-hosted CI: https://github.com/ChicoDotNet/Katas/actions/runs/39021656637 (GREEN).

Limits: This is an original clean-room game **similar in educational intent**, not a refactor of jbrains' GPL codebase. No quantified time improvement or Ninja transfer gain is claimed. Deeper mutation tests and a genuinely unknown legacy program would strengthen the hypothesis.
