# KATA-000030 — Trip Service (original Ruby seam-refactoring exercise)

**State:** GREEN local, `development_complete=true`, remote CI and independent review pending. **Not verified or published.**

## Scope and rights

Conceptual inspiration: [Kata-Log Trip Service](https://kata-log.rocks/trip-service-kata), whose **own** page content is public domain (Unlicense declaration in its footer). The upstream GitHub starter is **not** imported, nor are its code, tests, fixtures or precise semantics. All Ruby, Go and shell code here is original, MIT. **This is NOT a characterization of Sandro Mancuso's original legacy class.** It is a separate bounded contract for studying seams, authentication precedence, domain errors and preservation of output order. Do not claim equivalence to the upstream legacy program.

## Domain and invariants

Given an optional viewer ID, a target ID and a directory of users with friend IDs and ordered trip IDs:

1. Validate request shape, nonempty string identifiers, uniqueness of user IDs and nested arrays; reject malformed input (`invalid_request`).
2. If unauthenticated, return `not_logged_in` even when target is absent.
3. If authenticated but target missing, return `user_not_found`.
4. Owner or exact friend may see the target's trip list; others see `[]`.
5. Preserve trip order and duplicates; duplicate friend entries do not multiply trips.
6. No implicit global session: `Session`, `UserDirectory` and `TripService` are explicit boundaries.
7. The JSON-lines CLI processes independent requests without state leakage.

`src/trip_service.rb` provides the refactored service and contract validation. `src/cli.rb` is the real subprocess interface used by the Go oracle. The intentionally wrong RED stub is independently compiled/loaded and fails its first behavioral assertion.

## Implementation language selection **before** inspecting CI

| Candidate | Affinity | Trade-off |
|---|---|---|
| **Ruby 3.3 (selected)** | Dynamic legacy seams, tiny injectable collaborator interfaces, expressive Minitest, transparent refactoring without mocking framework | Runtime rather than static enforcement of identifiers |
| **Haskell** | Pure access predicate and ADTs for authorization errors | Less representative of a stateful legacy seam and dependency injection |
| **VB.NET** | Enterprise-service idioms, interfaces and explicit access control | More scaffolding for a small dependency-boundary kata |
| **C++20** | Strong domain types and ownership | Boilerplate can obscure characterization and dependency seams |

**Contrafactual:** implementing every domain exercise in Java/Go/C# would mask Ruby's low-ceremony collaborator substitution and dynamic legacy constraints. We did not select Ruby because it already had CI. Genkidama's `eng/ci/registry.json` places Ruby in the `scripting` family; `.github/workflows/polyglot.yml` uses `ruby/setup-ruby@v1`. After selection, this kata adapted the same setup to Ruby 3.3 and `actions/setup-go` to Go 1.23.2.

## Three independent language decisions

| Role | Choice | Rationale |
|---|---|---|
| Production | Ruby 3.3 | Explicit session/directory seams and immutable user records |
| RED/GREEN | Ruby 3.3 + Minitest | Idiomatic domain behavior and exception-precedence assertions |
| Oracle | Go 1.23 | **AST-first request generator + direct authorization decision table**, not translated Ruby service classes |
| Metamorphic | Go + Ruby | Permuting friendships and adding unrelated users cannot change authorization |
| Mutation | Ruby + Go | Compile/syntax-check three mutated Ruby variants; kill through Go behavioral mismatch |

**Alternative verification:** duplicate the service with mock collaborators and compare two call traces. Rejected as too structurally similar to the Ruby implementation and prone to common-mode authorization errors. Chosen independent decision-table generator calculates expected access directly from IDs and friendships, then invokes a real Ruby process over JSON-lines.

**Common risks:** both languages interpret the same invented domain contract, so a mistaken specification can be shared. JSON normalization and string identity are shared semantic assumptions; tests deliberately cover exact IDs, Unicode, duplicates, empty and missing values. This is not a claim of independent domain specification or of causal skill improvement.

## Reproducible commands

```bash
cd katas/KATA-000030
bash tests/run.sh
```

The runner checks behavioral RED, 13 native tests/17 assertions, `go vet`, 350 exhaustive authorization cases, 900 seeded generated cases, 200 metamorphic cases, eight invalid schemas (1458 total), then three syntax-valid behaviorally detected mutants. No Python oracle is used. Run CI on the **exact PR head** before claiming remote certification.

## Ninja review

See `evidence/skill_review.md`. Ninja v0.1.29: `no_change`. A locally found defect or a passing oracle does not prove causal skill improvement; no holdout was changed.
