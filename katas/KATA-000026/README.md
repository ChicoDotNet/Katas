# KATA-000026 — Task List: typed Kotlin domain and Go event-replay oracle

**Status: GREEN on feature branch, remote CI and independent review pending; NOT published.** Source `dev` HEAD at investigation: `0d97c338cb8702265ad6fda4381cbd9336197f61`; KATA-000026 remains `discovered` on dev. Original clean-room adaptation of the [Task List kata](https://kata-log.rocks/task-list-kata), inspired by Codurance. Kata-Log's public-domain declaration applies to its own description, not linked starter repositories. No upstream starter, fixtures, tests, images or code imported. All source/tests original MIT.

## Domain and invariants

A task belongs to an existing project and has a typed alphanumeric ID, nonempty title, optional ISO deadline, completion status, and immutable creation order. Commands: `project|Name`, `add|Project|ID|Title`, `done|ID`, `deadline|ID|YYYY-MM-DD`, `delete|ID`, `today|YYYY-MM-DD`, `view|project`, `view|date`, `view|deadline`. This is a **local test protocol**, not a verbatim upstream interface. CLI receives one Base64 UTF-8 multiline scenario per input line and returns one Base64 UTF-8 result per line. Invalid Base64 and malformed UTF-8 are rejected as `ERR:encoding`. Each valid command emits `OK`, `ERR:code` or `LIST:` followed by task records; errors do not mutate the book. IDs unique among live tasks; deleted IDs may be reused. `today` excludes completed tasks; `view|date` includes undated tasks last; `view|deadline` excludes undated tasks; `view|project` preserves project/task insertion order. Dates strictly parsed. Invalid project names, IDs, titles and arity rejected.

## Language choice before CI inspection

Compared **Kotlin 1.9**, **Ada**, **Java 21** and **Ruby**. Kotlin inline value classes (`TaskId`, `ProjectName`, `DueDate`, `TaskTitle`) and immutable task snapshots reveal primitive obsession while preserving an imperative aggregate. Ada could enforce subtypes/ranges but toolchain unavailable locally; Java records viable but more verbose; Ruby lacks compile-time type boundaries. Kotlin not chosen for existing CI. Genkidama `dev` `eng/ci/registry.json` (JVM family, blob `24bde39c748dd3903789fd20eace80894a4735fb`) consulted after this decision. Habitual Java implementation would lose concise value-class modeling.

## Separate verification choices

| Role | Language | Structural approach |
| --- | --- | --- |
| Implementation | Kotlin 1.9/JDK 21 | Mutable aggregate with typed value classes and defensive task copies |
| Native RED/GREEN | Kotlin 1.9 | Compilable wrong stub, 21 behavioral assertions |
| Independent oracle | Go 1.23 | **Event-sourced fold**: replay accepted commands from scratch at every observation versus incremental Kotlin mutations |
| Metamorphism | Go invoking real Kotlin CLI | Consistent project renaming in 200 transformed histories |
| Mutation controls | Python orchestrator + Kotlin compiler | 3 compiled defects: reused sequence, completed tasks in `today`, undated tasks in deadline view |
| CLI boundary | Python invoking real Kotlin CLI | Valid input and rejection of malformed Base64 / UTF-8; not a domain oracle |

Compared **second mutable map** with **immutable event replay**. The latter does not share Kotlin's sequence counter or incremental updates; it caught an actual ordering bug after deleting two tasks. Both models share written command contract; independence structural, not formal proof. Deterministic 500 generated histories include invalid transitions/views; explicit deletion witness separate. Python computes no domain expected result.

## Reproduction and limitations

Run `bash tests/run.sh` here. Kotlin/JDK, Go and Python required. Locally used Kotlin 1.9.0, JDK 21.0.12.1, Go 1.23.2, Python 3.13.5. Runner compiles RED and verifies behavioral failure, executes 21 native GREEN assertions, checks 3 CLI encoding inputs, compares 701 real Kotlin scenarios with Go event replay, compiles and kills 3 Kotlin mutants, runs `go vet`. 2026-10-30 follow-up RED/GREEN/Go passed, mutation gate separately passed; combined runner hit a local wall-time limit after Go. Later encoding hardening recompilation passed 3 CLI tests, Go 701 and mutations 3/3. See `evidence/local-2026-10-30.md` and `evidence/encoding-hardening-2026-10-30.md`.

**Retrabajo:** Go replay found Kotlin ordering defect: `sequence=tasks.size` after deleting A/B made D precede C; fixed monotonic `nextSequence`, added native regression. Separate adversarial test exposed silent malformed UTF-8 replacement; fixed strict decoder and added regression. No performance/causal Ninja claim.

## Ninja and publication gate

Ninja v0.1.29, review `confirmed local`: ordering witness supports independent representations but not transferable causal benefit. No skill modification/holdout. Feature branch requires actual Kotlin/Go CI exact SHA, catalog/governance, independent review and squash merge before verified/published. Next main promotion at 36 published.
