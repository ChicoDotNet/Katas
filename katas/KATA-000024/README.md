# KATA-000024 — Social Network (original TypeScript implementation)

**State:** GREEN locally, `development_complete=true` in a guarded catalog proposal only; **NOT remotely certified or published**. The current `dev` record remains `discovered` until a reviewed PR is merged. MIT original implementation; source exercise description: https://kata-log.rocks/social-network-kata (Kata-Log's own public-domain content). No upstream starters, third-party fixtures, images or code imported. The JSON protocol and choices below are original, not asserted to match third-party starter behavior.

## Domain and contract

The six acceptance increments from the source backlog are posting, reading a timeline, following/feed, mentions, HTTP(S) links, and private messages. This implementation consumes newline-delimited JSON: each line has `{ "events": [...], "queries": [...] }` and produces `{ "results": [...] }` (one array per query). Events are `post(user,text)`, `follow(user,target)`, `dm(from,to,text)`; queries are `timeline(user)`, `feed(user)`, `mentions(user)`, `inbox(user)`. See `tests/native.test.mjs` for concrete request shapes.

Original policy decisions, documented rather than attributed to the source: user identifiers are ASCII letters followed by up to 31 ASCII letters/digits/underscores; text length 1..2000 UTF-16 code units; follows are directional, idempotent and self-follow is ignored; feeds include historical posts from followed users but not the reader's own posts unless another account is followed; timeline/feed/mentions/inbox are newest-first; IDs are 1-based positions in the **event** stream, including follows and DMs. A DM appears only in its recipient's inbox; it is never public. Mentions are case-sensitive and unique per post, with an explicit ASCII token boundary. Links are metadata (not fetched) and restricted to simple http(s) tokenization with trailing punctuation trimmed. An invalid event or query rejects the entire request, rather than partially applying it. The CLI emits JSON error objects for invalid requests. No real network service, persistence, accounts or authentication is claimed.

## Independent language choices (decided before inspecting workflows)

| Role | Choice and distinct technique | Reason |
|---|---|---|
| Implementation | TypeScript 5.8.3, incremental per-user indexes and discriminated event/query unions | Type checking of event variants; projection updates are local and efficient |
| Native RED/GREEN | TypeScript compile + Node 22 `node:test` | Seven BDD acceptance scenarios with explicit errors, privacy, order and boundaries |
| Independent oracle | Go 1.23.2, **read-only scan of the entire event history per query** | No indexes or incremental update logic; byte-level mention/link scanner instead of JS regex |
| Alternative verification | Go duplicate of TypeScript indexes (rejected), or SQL relational projections (future) | Duplicating update logic risks shared index-ordering defects; relational scan has better structural independence |
| Metamorphic | Go generates unrelated DMs and checks all public projections unchanged | Detects privacy leakage without reproducing the implementation algorithm |
| Mutations | Python 3.13 harness compiles three TypeScript variants and requires behavioral Go mismatches | Exercises wrong follow target, inbox recipient leak, reversed feed order |

Language alternatives considered before workflows: Ruby (excellent BDD, but fewer compile-time tagged union guarantees), Haskell (pure folds and ADTs, no local compiler), Prolog (relational queries, no local runtime). TypeScript was selected for semantic affinity, not CI convenience. The Go oracle was selected for a log-scan reference rather than language variety. Shared risks: both models share event ordering, the same source contract and ASCII username policy; oracle does not independently validate Unicode segmentation or actual browser clickability. This is a domain-model kata, not a secure production social network.

## Reproduction and observed results

```bash
# from katas/KATA-000024; Node 22, tsc 5.8.3, Go 1.23.2, Python 3.13
bash tests/run.sh
```

`run.sh` compiles a deliberately incorrect but type-correct RED stub, verifies a behavioral failure in the same native tests, compiles real TypeScript, runs seven Node BDD tests, `go vet`, 1,201 differential event histories / 20,602 independent query projections, 100 metamorphic pairs, then three **compiled and behaviorally rejected** mutants. Local execution output is preserved in `evidence/local-run.txt`. CI config `.github/workflows/ts-social-network-kata.yml` uses Node 22 and Go 1.23.2 and installs pinned TypeScript. Genkidama `eng/ci/registry.json` (dev) assigns TypeScript to the `web` family; `eng/ci/run-family` and `polyglot.yml` were consulted before adapting Katas' TypeScript Forth workflow. No CI success is claimed until a real exact-head run is inspected.

The source's suggested incremental BDD exercise was implemented as six separately named acceptance scenarios; **we do not claim a blind, no-peeking-ahead workshop**, because the full public backlog was read before coding. Retain the exact original acceptance wording only at the source URL, not in copied fixtures.

## Risks and audit

No external starter or fixture copied. Rights per artifact: public-domain source description, original MIT code/tests/oracle/workflow/README. `evidence/skill_review.md` records `no_change` for Ninja v0.1.29; a successful local comparison cannot establish causal transfer. The catalog proposal in `evidence/catalog-transition.json` must be applied only to the current `dev` candidate with a matching ID, fingerprint, source URL and discovered status. `published` requires independent review, exact-head CI and squash merge; the metadata proposal does not promote publication.
