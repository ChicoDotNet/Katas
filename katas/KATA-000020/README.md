# KATA-000020 — Race Car Telemetry, original Java 21 laboratory

Original clean-room diagnostic transport exercise, inspired only by the concept of Race Car Telemetry (https://kata-log.rocks/race-car-katas-telemetry). No external starter, fixture, test or legacy code was copied. The authored implementation, tests and fixtures are MIT under this repository LICENSE; the external Kata-Log page is a conceptual reference only. This is NOT a refactoring of upstream TelemetryDiagnosticControls.

## Domain, invariants, and failure modes

A controller receives a TelemetryPort interface and never constructs a network socket, sleeps or accesses secrets. After successful connect it sends exactly DIAG, accepts only DIAG-OK, retries at most three times on connect/write/read errors or wrong responses, disconnects exactly once after each successful connection (even if send/read fails), never disconnects a failed connection, and stops immediately on success. Five scripted outcomes: C connect error, S send error, R receive error, B bad response, O accepted response. Example S,O,C yields 1|c+,s!,d,c+,s+,r=OK,d. It must never execute the third attempt after success.

## Language selection before infrastructure

- Java 21 chosen for original implementation and native tests: checked IOException, interface substitution, finally cleanup and explicit dependency seams are the core learning goals.
- Go considered: excellent interface/error-value alternative, but shifts the learning toward error-value plumbing rather than checked exceptions and legacy object substitution.
- C# considered: IDisposable and dependency injection are equally idiomatic; Java is preferable here to explore Java's checked-exception boundaries. C# was not rejected merely for unavailable CI.
- Counterfactual: selecting the familiar Go/C# every time would miss the distinctive Java checked-exception and finally contract, while selecting a numerical language by quota would obscure the seam.

## Independent verification

| Layer | Technique | Language | Why |
| --- | --- | --- | --- |
| Implementation | Stateful injectable I/O port, retry and finally | Java 21 | Cleanup and checked exceptions |
| RED/GREEN | Compilable wrong-result mutant and seven native trace assertions | Java 21 | Exercise Java behavior and side effects |
| Oracle | Declarative event grammar, exhaustive 5^3 and seeded traces | Node.js 22 | Distinct from retry loop, detects wrong order, leaks and early stop |

Verification strategies compared: a second imperative retry loop risks copying the implementation's bug; checking only a success boolean misses incorrect connection/disconnection and event ordering. A declarative trace grammar yields 125 exhaustive three-outcome scripts plus 800 seeded cases, 925 total. Shared assumptions remain about the five-token model, expected event vocabulary and three-attempt limit. This is not an actual network reliability test, nor a security guarantee.

## Reproduction

Run: bash katas/KATA-000020/tests/run.sh
Requires Java 21 and Node.js 22. Compiles with javac -Xlint:all -Werror, checks that RED fails behaviorally with "wrong result", runs seven native GREEN cases, then compares 925 traces. No third-party dependencies, network, or external fixtures. GitHub Actions job: .github/workflows/java-telemetry-kata.yml. Local checkpoint passed on OpenJDK 21.0.12.1 and Node 22.16.0 on 2026-10-19; remote exact-head CI remains to be established.

## Ninja review and status

Outcome confirmed with no skill edit: injectable transport plus explicit cleanup invariant makes retries testable, while a trace grammar catches ordering errors. Single self-authored example, not a demonstrated transfer effect. Status green + development_complete=true means locally validated only, never verified/published until CI exact-head, PR review and squash merge to dev. No new publication or migration is implied.
