# Ninja v0.1.29 review — KATA-000010

2026-11-02 checkpoint. Outcome **no_change**: private validated construction in Ada is a hypothesis for eliminating invalid game states, not a proven general principle. GNAT was unavailable locally, but GitHub Actions job 125515236221 on ee3f5d932bfae3adfc0c3dce207ba094ae015245 executed GNAT 13.3.0, RED/GREEN (12 assertions), independent Go history oracle (301 baseline + 535 metamorphic sessions) and 3/3 compiled mutants successfully. No causal claim. Distinct from KATA-000001 legacy Trivia characterization. No holdouts or Ninja skill modifications.

2026-11-02 follow-up: adversarial CLI audit found non-atomic partial stdout on invalid later turn; added pre-validation and independent oracle regression. Conclusion remains `no_change`. Await exact-head GNAT CI.
