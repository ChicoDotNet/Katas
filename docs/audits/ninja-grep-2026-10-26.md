# Ninja KATA-000060 — remote integration audit, 2026-10-26

- Baseline dev: 0d97c338cb8702265ad6fda4381cbd9336197f61; catalog recomputed from JSON: 26 published, 4 green, 31 discovered (61). Recheck before any merge; no README counts used.
- Branch: kata/000060-grep-perl-go-20261022. Earlier source and native tests were uploaded 2026-10-22. This integration adds the Go differential oracle, unit tests, mutation driver, compilable RED stub, runner, CI workflow, README and skill review.
- Rights: Exercism MIT specification as conceptual reference; original MIT implementation/tests/models; no starter/fixtures copied.
- Three implementation languages considered before CI: Perl, Rust, Go, OCaml. Perl selected for text streaming, literal-vs-regex and argv Unicode learning.
- Separate roles: Perl implementation + Test::More; Go reference via strings.Contains and independently quoted RE2, complement metamorphism; Python mutation orchestration only.
- Actual local 2026-10-26 rerun: Perl 5.40.1, Go 1.23.2, Python 3.13.5, RED behavioral failure, 38 GREEN assertions, 900 differential cases, 1800 model checks, 200 complement pairs, 16 oracle self-tests, 7/7 syntax-valid mutants detected by both verifiers; exit 0 on warmed Go cache.
- Retrabajo: Unicode argv decoding, dash-prefixed literal after --, mutation environment forwarding. First cold build run timed out; retry passed. No active-time or independent holdout evidence, hence no causal attribution.
- Review of Ninja v0.1.29: confirmed; no skill edit. No published/verified claim until exact-head PR CI, review, squash merge, post-merge checks.
