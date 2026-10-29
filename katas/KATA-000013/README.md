# KATA-000013 — Clock-in: Promise ordering without timers

**State:** local `green` / `development_complete=true`. This is NOT verified/published until exact-head CI and a reviewed squash PR into dev.

## Source and rights

Conceptual reference: https://kata-log.rocks/clock-in-kata — Kata-Log explicitly places **its own page** in the public domain. No third-party starter, fixtures, code or diagrams were copied. The JavaScript implementation, Go oracle and test data are original and MIT under the Katas repository license. This is a clean-room exercise, **not** a refactor of the upstream legacy code.

## Domain and invariants

`clockIn({mode,now,getGps,send})` returns a Promise. `mode` is `time`, `optional` or `required`. `now()` is sampled once; its result must be a safe integer. `time` posts `{at}` without GPS. `optional` awaits one GPS request; on rejection or invalid coordinates it posts time-only. `required` awaits up to three **sequential** GPS requests; it retries rejection or invalid coordinates, rejects `RequiredGpsError` after exhaustion and never posts without valid GPS. Latitude and longitude must be finite and in [-90,90]/[-180,180]. After a valid GPS result, send is invoked once with `{at,position}`; otherwise `{at}`. The send receipt or rejection is propagated. There is no sleeping, network, browser GPS or global clock.

The scripted CLI accepts `G` (valid GPS), `F` (GPS failure), `I` (latitude 95), `J` (longitude 181), `K` (fractional latitude 90.5), and server `O` (success) or `F` (failure). It reports observable `gps`, `post+gps` and `post+time` events. A pending GPS Promise must prevent POST from starting.

## Three language candidates, selected BEFORE inspecting workflows

| Language | Domain affinity | Decision / counterfactual |
|---|---|---|
| **JavaScript ESM** | Native Promise semantics, async/await, deferred microtasks, Node `node:test` with no real timers | **Selected**: the task is explicitly Promise ordering. Dynamic types require input checks. |
| **C#** | Tasks, dependency injection and cancellation | Strong for production I/O, but would teach Task rather than JS Promise semantics; no local .NET runtime. |
| **Kotlin** | Coroutines, structured concurrency and virtual dispatchers | Excellent cancellation lesson, but different async model and additional runtime for this particular contract. |
| **Go** | Deterministic decision-table model and simple CLI interoperability | **Selected as independent oracle**, not primary, because goroutines/channels are not Promises. |

After the domain ranking, inspected Genkidama `eng/ci/registry.json` and `.github/workflows/polyglot.yml`. Local versions: Node 22.16.0 / Go 1.23.2; proposed CI pins from Genkidama: Node 24.18.1 / Go 1.26.5. No claim of executing the proposed remote versions.

## Separate RED/GREEN and oracle strategies

| Role | Technique and evidence |
|---|---|
| Implementation | JavaScript async/await retry policy, validated coordinates, injected GPS and server |
| Native RED | Node `node:test`; compilable mutant posts before awaiting required GPS, producing `POST began before required GPS completed` |
| Native GREEN | Nine Node tests: deferred GPS ordering, time-only, optional fallback, required retries/exhaustion, server rejection, invalid inputs, coordinates and timestamp sampling |
| **Independent oracle** | Go **decision table** locates first valid GPS token in a finite script, derives expected GPS call count, POST mode and terminal status, and compares JS CLI traces |
| Alternative strategy | Metamorphic unused-tail substitutions after first success and pending-Promise ordering; exhaustive finite oracle covers unused-tail combinations, native deferred test covers ordering |
| Rejected alternative | Rewriting the JS async retry loop in Go/JavaScript would risk duplicating the same control-flow error |
| Shared error risk | Both use the same invented five-token contract and three policy modes; neither is a third-party specification or tests real GPS, TCP, cancellation or browser behavior |

Go checks **750 exhaustive** mode × GPS-triple × server combinations and **800 seeded** additional scenarios (1,550 comparisons total). A boolean-only test would miss ordering and call-count bugs. The Go oracle is independent in *technique* but not completely independent in assumptions.

## Commands (executed locally)

```bash
bash katas/KATA-000013/tests/run.sh
# from katas/KATA-000013:
NINJA_RED=1 node --test tests/test-clock-in.mjs  # intentionally exits nonzero, semantic failure
node --test tests/test-clock-in.mjs                # 9 PASS
go run tests/oracle.go src/cli.mjs                # 1,550 PASS
go vet tests/oracle.go                           # PASS
```

No third-party packages or network required. Proposed workflow: `.github/workflows/javascript-clock-in-kata.yml`; CI must run on exact reviewed SHA before publication.

## Ninja review and limits

Outcome: **confirmed**, no Ninja edit. Deterministic deferred Promises and independent decision-table traces reveal premature POST and incorrect fallback without timing sleeps. This original exercise does not characterize the upstream implementation and is not causal evidence of improved delivery or transfer. Source and test license claims are per artifact; holdout gate remains at 90 published.

## Adversarial oracle boundary expansion — 2026-10-19

The Go reference now distinguishes valid GPS, failure, latitude 95, longitude 181 and fractional latitude 90.5, including 750 exhaustive mode/script/server combinations and 800 seeded cases. These new cases check strict coordinate bounds without translating the JavaScript retry loop. Local Node RED/GREEN (9 tests), Go decision oracle (1,550 cases) and `go vet` passed on 2026-10-19. Remote CI is required on this exact SHA before any verification or publication claim. Native Node deferred-Promise tests still cover timing and single clock sampling that CLI traces cannot observe.
