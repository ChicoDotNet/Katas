# KATA-000005 — Mars Rover (Go)

[Original kata page](https://kata-log.rocks/mars-rover-kata), Kata-Log's own public-domain text. We used **no upstream starter code, test fixtures or image**. This Go solution, CLI and tests are original MIT material.

## Contract choices (make ambiguity explicit)
World is a 0-based W×H **toroidal grid**, as explicitly offered by Kata-Log. The page also discusses a *polar/spherical* interpretation: **this solution does not claim to implement polar geometry**. Heading is N/E/S/W, y increases to the north. f and b move forward/backward; l/r rotate 90°. Each move checks the destination for an obstacle before entering it. On obstacle, halt, report last safe pose, attempted destination and count of successfully applied command characters. Input is validated before any execution; starting on an obstacle is permitted as starting state (no movement occurs until next command). Empty command stream is valid.

## Choice of language
Go's small domain value structs and explicit error results make atomic input validation and deterministic state transitions readily reviewable. Julia/Fortran would fit numeric grids, but Fortran already covered a different grid problem. Rust offers stronger type constraints but would shift this iteration into toolchain complexity. Python is used exclusively as an independent transition-table oracle.

## Reproduction

~~~bash
cd katas/KATA-000005
go test ./...  # GREEN
if go test -tags kata_red ./... > /tmp/ninja-rover-red.log 2>&1; then exit 1; fi
grep -q 'wrong pose or stop' /tmp/ninja-rover-red.log  # behavioral RED
go build -o /tmp/ninja-rover-cli ./cmd/rover
python3 tests/differential.py /tmp/ninja-rover-cli
~~~

A newline JSON array of scenarios is fed to the CLI; each scenario provides World{Width,Height,Obstacles}, Pose{X,Y,Facing}, Commands. Response contains Result{Pose,Blocked,Obstacle,Applied} and Error string, enabling one process for all tests.

## Evidence and limitations

- RED: deliberately wrong compiled implementation using build tag \`kata_red\` with shared domain types, proven to fail a behavior assertion, **not a compile error**.
- GREEN: Go unit tests for movement, rotation, wrap, obstacle halt, invalid dimensions, invalid initial heading and commands.
- Oracle: 360 deterministic Python reference transitions tested against compiled Go CLI.
- Toolchain: Go 1.23.2 and Python 3.13.5 were used for local authoring; remote CI still required.
- Complexity: O(commands + obstacles); obstacle lookup O(1) expected.
- Preliminary rubric 90/100, difficulty 5/5 (both author estimates, not independently calibrated).
- Ninja note: validate commands up front while allowing intended partial progress on obstacles; explicitly document geometry choices.

[RED evidence](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [skill review](evidence/skill_review.md) · [CI](evidence/ci.txt)

## Additional metamorphic hardening (2026-10-17)

The prior 360-scenario Python oracle and the Go implementation both encode cardinal coordinates and toroidal movement. Merely translating their algorithms into a third language would not independently challenge shared conventions. The additional `metamorphic_test.go` checks **different mathematical relations** against the same implementation, preserving the published Go solution and its KATA-ID:

- Eight **absolute cardinal/edge anchors** fix north = +Y, east = +X, and wrapping in both dimensions, so relational invariances alone cannot bless a shared reversed-axis mistake.
- 320 deterministic worlds verify four rotations, inverse commands, and a complete dimension of forward steps (2,240 composed paths).
- 300 worlds with obstacles verify **translation equivariance**: shifting the whole torus, start and obstacles shifts the result and obstacle witness, but does not change heading, blocked status or applied-command count.
- 300 more obstacle-bearing worlds verify **composition of command prefixes and suffixes**, including earliest-stop preservation and the applied-command counter. This is a direct executable invariant, not a second copy of the Go transition loop.

**Verification strategies compared:** (A) the existing independently coded Python transition table can give precise expected poses but may share geometry assumptions; (B) Go-native metamorphic transformations and composition do not independently calculate an entire journey, but can expose path-ordering, witness, translation, inverse and wrap errors without implementing the same transition table. Both are retained. Go is appropriate for this test layer because it exercises the original public API and its typed Result directly; the existing Python oracle remains the cross-language reference. No new language is used merely for variety.

Local pre-CI reproduction with Go 1.23.2: `go test ./... -count=1` PASS; `go test -tags kata_red ./...` fails on a **behavioral** cardinal anchor as intended. These are local checks, not a claim of GitHub CI success. The PR's exact-head workflow is required before integration. The input generator is deterministic; the assertions are relational and do not prove the entire polar/spherical interpretation, concurrent effects, or exhaustive geometry. Ninja review: **confirmed OBS-006, no new universal rule**; the lesson is to complement differential models with mathematically distinct invariants and absolute convention anchors when a shared semantic error is plausible.
