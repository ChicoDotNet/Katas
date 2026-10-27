# Ninja v0.1.29 review — KATA-000040

Conclusion: **confirmed**, no skill edit. SHA of skill inspected in dev:
`32cb01f2e088453762f5c79239d1f11e6991bf83`.

The discipline of independent oracles detected a transport mismatch (Go nil slices
marshal as JSON `null`, but Swift correctly requires arrays). We corrected the
Go generator to use non-nil empty arrays rather than weaken the Swift contract.
A second failure arose from a mutation anchor matching two different branches;
we tightened the anchor to the union-specific branch before rerunning the full suite.
The RED stub compiles and fails at the first incorrect contract assertion;
Swift `fatalError` terminates via illegal instruction in this Linux toolchain,
which is an expected *behavioral* RED failure, not an installation failure.

This is one kata's observation, not proof of transfer or Ninja causal improvement.
No new rule is proposed without independent holdout evaluation.
