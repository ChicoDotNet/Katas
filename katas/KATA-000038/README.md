# KATA-000038 — REST API IOU Ledger (Go + Ruby)

**Status: GREEN locally; submitted on a reviewable feature branch. NOT remotely certified, reviewed or published.** GitHub `dev» is authoritative. CI must pass on the PR exact head before any promotion.

## Domain and invariants

A small HTTP API maintains roommate IOUs. `GET /users» lists all or a selected subset sorted by name; `POST /add» creates a unique account; `POST /iou» records a loan and returns the two changed accounts. Each user has `owes», `owed_by», and `balance». Net obligations between any two users cancel in opposite directions, and the sum of all balances is zero. Requests are serialized with a mutex; rejected requests must not change state. Amounts are parsed as exact integer cents, never binary floating point, and amounts with fractional sub-cents, zero, negative, exponent notation, or pair overflow are rejected. Unknown names and malformed paths are errors. HTTP statuses 400/404/409 for invalid requests are **local hardening conventions**, not claims of upstream error contract.

The API intentionally does not persist to disk, perform authentication, or support currency conversion. `MaxPairCents=100_000_000_000» prevents per-pair overflow; balance output is a JSON number, which can lose precision for extreme aggregate totals across very many users. The local test domain is comfortably below that bound. The kata models a learning contract, not production accounting.

## Language and verification selection — BEFORE checking CI

| Responsibility | Selection | Domain affinity and counterfactual |
|---|---|---|
| Implementation | **Go 1.23** | `net/http», `httptest», mutex-protected state, deterministic maps, exact cents and explicit failure paths expose transaction boundaries. **Ada** offers strong numeric contracts but adds HTTP integration overhead; **COBOL** excels at fixed decimal/batch ledger yet not an idiomatic in-memory HTTP API; **Ruby** makes HTTP quick but dynamic validation risks hiding cents/atomicity mistakes. |
| RED/GREEN | **Go testing + race detector** | Native HTTP request/response contracts, concurrent opposing loans, exact money boundaries, atomic rejection. Compilable stub RED returns HTTP 501 rather than expected 200. External-only tests would miss Go data races. |
| Independent oracle | **Ruby 3.3 + BigDecimal/integer cents** | Append-only event log and O(users² × events) replay; no Go incremental canonical-pair map. Ruby was chosen for compact state-machine replay and exact `BigDecimal» semantics, not for diversity quota. |
| Alternative oracle | **SQL ledger SUM/GROUP BY** | Independent aggregation engine and transactional properties, potentially stronger on concurrency and query semantics, but adds an engine dependency. A second Go map or Ruby translation of the Go net-pair algorithm would share the core bug. |
| Complementary technique | **Metamorphic** | Independent loans commute, opposite loans cancel, rejected operations preserve snapshots, repeated GETs do not mutate, and balances sum to zero. |

**Shared-error risk:** both models interpret the same lender/borrower vocabulary and a cent precision policy, so a mistaken reading of the upstream spec could be shared. No upstream canonical test vectors were imported. The Ruby model replays events rather than copying the Go pair-net algorithm, and the metamorphic properties catch distinct classes of bugs. Future independent holdouts should audit semantics and large-user balance bounds.

## Real executed commands

```bash
cd katas/KATA-000038
bash tests/run.sh
# go test ./tests/red -count=1  => intentional behavioral failure (HTTP 501 vs 200)
# go vet ./src ./cmd/driver
# go test -race -count=1 ./src
# go build -o .build/driver ./cmd/driver
# ruby tests/oracle.rb "$(pwd)/.build/driver"
# bash tests/mutations.sh
```

On Linux: **Go 1.23.2, Ruby 3.3.8**. RED compiled and failed for the correct behavior; GREEN with race detector passed; **65 independent histories, 5,860 real Go HTTP requests** verified against the Ruby event-replay model, including state snapshots, reversals, disjoint-loan commutativity and zero-sum invariants. **2/2 syntactically valid mutants** were detected by **both** Go native tests and Ruby oracle. Full suite exited 0. Evidence: `evidence/full-run.log», `red.txt», `green.txt», `oracle.txt», `mutations.txt».

The first oracle run exposed a test-driver crash when the generator used a non-absolute HTTP target. The generator was corrected and the driver now rejects malformed targets with 400; regression executed. Native tests also exposed a JSON-number validation gap (`json.Number» accepts quoted numerics); fixed by parsing raw JSON numeric bytes. Another test initially compared a float64 interface value to an untyped int, producing a false failure; fixed before GREEN. These are recorded as real retrabajo, not suppressed.

## Rights and Genkidama

Upstream conceptual specification: [Exercism rest-api description](https://github.com/exercism/problem-specifications/blob/main/exercises/rest-api/description.md), blob `e889b1bf20762398566d9811888616e8ee03cb54»; MIT [LICENSE](https://github.com/exercism/problem-specifications/blob/main/LICENSE), blob `6813d6298df9a46da6485050e8a5fcd61ab79879». Canonical-data blob `06fac0284f83a9e2995d81c0f049c70d592b3112» was examined only for conceptual semantics; **no canonical fixtures, upstream starter code or tests were copied**. All submitted implementation/tests/oracle text is original; license audit in `docs/audits/ninja-rest-api-go-ruby-2026-10-26.md».

Genkidama `dev» `eng/ci/registry.json» blob `24bde39c748dd3903789fd20eace80894a4735fb» maps Go to `native» and Ruby to `scripting». This kata uses a dedicated GitHub Actions workflow that explicitly installs Go 1.23.2 and checks Ruby and executes both; it does not infer CI coverage from family detection. Remote exact-head CI is a pending certification gate.

## Ninja

Ninja v0.1.29 reviewed; `confirmed» for existing caution about exact integer minor units and independent verification. No new universal principle or causal performance improvement is claimed. Next gate: CI exact-head, independent review, squash merge, and post-merge state check.
