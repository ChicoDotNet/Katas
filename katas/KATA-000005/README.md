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
