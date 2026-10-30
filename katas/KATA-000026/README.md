# KATA-000026 — Task List: typed Kotlin domain and Go event-replay oracle

**Status: GREEN on feature branch, remote CI and independent review pending; NOT published.** Source `dev` HEAD at investigation: `0d97c338cb8702265ad6fda4381cbd9336197f61`; KATA-000026 remains `discovered` on dev. Original clean-room adaptation of the [Task List kata](https://kata-log.rocks/task-list-kata), inspired by Codurance. Kata-Log's public-domain declaration applies to its own description, not linked starter repositories. No upstream starter, fixtures, tests, images or code imported. All source/tests original MIT.

## Domain and invariants

A task belongs to an existing project and has a typed alphanumeric ID, nonempty title, optional ISO deadline, completion status, and immutable creation order. Commands: `project|Name`, `add|Project|ID|Title`, `done|ID`, `deadline|ID|YYYY-MM-DD`, `delete|ID`, `today|YYYY-MM-DD`, `view|project`, `view|date`, `view|deadline`. This is a **local test protocol**, not a verbatim upstream interface. CLI receives one Base64 UTF-8 multiline scenario per input line and returns one Base64 UTF-8 result per line. Each command emits `OK`, `ERR:code` or `LIST:` followed by task records; errors do not mutate the book. IDs are unique among live tasks; deleted IDs may be reused. `today` excludes completed tasks; `view|date` includes undated tasks last; `view|deadline` excludes undated tasks; `view|project` preserves project/task insertion order. Dates are strictly parsed. Invalid project names, IDs, titles and arity are rejected.

## Language choice before CI inspection

Compared **Kotlin 1.9**, **Ada**, **Java 21** and **Ruby**. Kotlin inline value classes (`TaskId`, `ProjectName`, `DueDate`, `TaskTitle`) and immutable task snapshots reveal primitive obsession while preserving an imperative aggregate. Ada could enforce subtypes/ranges but toolchain was unavailable locally; Java records are viable but more verbose; Ruby lacks compile-time type boundaries. Kotlin was not chosen for existing CI. Genkidama `dev` `eng/ci/registry.json` (JVM family, blob `24bde39c748dd3903789fd20eace80894a4735fb`) was consulted after this decision. A habitual Java implementation would lose concise value-class modeling.

## Separate verification choices

| Role | Language | Structural approach |
| --- | --- | --- |
| Implementation | Kotlin 1.9/JDK 21 | Mutable aggregate with typed value classes and defensive task copies |
| Native RED/GREEN | Kotlin 1.9 | Compilable wrong stub, 21 behavioral assertions |
| Independent oracle | Go 1.23 | **Event-sourced fold**: replay accepted commands from scratch at every observation versus incremental Kotlin mutations |
| Metamorphism | Go invoking real Kotlin CLI | Consistent project renaming in 200 transformed histories |
| Mutation controls | Python orchestrator + Kotlin compiler | 3 compiled defects: reused sequence, completed tasks in `today`, undated tasks in deadline view |

Compared a **second mutable map implementation** with **immutable event replay**. The latter does not share Kotlin's sequence counter or incremental updates; it caught an actual ordering bug after deleting two tasks. Both models share the written command contract; independence is structural, not formal proof. The deterministic 500 generated histories include invalid transitions and views; an explicit deletion witness is separate. Python computes no expected result.

## Reproduction and limitations

Run `bash tests/run.sh` in this directory. Kotlin/JDK, Go and Python are required. Locally used Kotlin 1.9.0, JDK 21.0.12.1, Go 1.23.2, Python 3.13.5. The runner compiles RED and verifies behavioral failure, executes 21 native GREEN assertions, compares 701 real Kotlin scenarios with Go event replay, compiles and kills three Kotlin mutants, and runs `go vet`. 2026-10-30 follow-up repeated RED/GREEN/Go (all passed), then mutation gate separately (3/3 passed); the combined run hit a local wall-time limit after Go, so do not count it as one complete uninterrupted rerun. See `evidence/local-2026-10-30.md`.

**Retrabajo:** Go event replay found a genuine Kotlin ordering defect: assigning `sequence=tasks.size` after deleting A and B made newly added D precede surviving C. Fixed with monotonic `nextSequence`, added native regression, reran differential model. No performance or causal Ninja claim.

## Ninja and publication gate

Ninja v0.1.29, review `confirmed local`: the ordering witness supports independent representations but does not establish transferable causal benefit. No skill modification/holdout. Feature branch must pass actual Kotlin/Go toolchains in CI at exact SHA, catalog/governance, independent review and squash merge before any verified/published claim. Next main promotion at 36 published.
