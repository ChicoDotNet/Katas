# KATA-000024 Social Network — local verification checkpoint (2026-10-20)

**NOT CERTIFIED REMOTELY.** Candidate remains discovered on dev. A clean-room Java 21 implementation, Java native tests, SQL relational reference and Go lexical oracle are available as a local checkpoint, not yet committed to this branch.

The additional Go metamorphic test compares 160 paired event traces with and without private direct messages, duplicate follows and rejected commands. The local execution passed 33,600 public projection comparisons and 3,200 atomicity/idempotence checkpoints. It strips sequence numbers from public post projections because inserting private messages advances the logical clock, but never permits private records or changed public content. Two separately compiled Java mutants were rejected: private messages published as posts, and duplicate follows that incorrectly increment the event log.

This audit is an engineering checkpoint, **not** a declaration of green, verified or published in GitHub. The code, oracle, full test suite, catalog metadata, Ninja review, license evidence and workflow must be integrated into a reviewable PR and executed on exact-head CI before certification. Prior SQL and lexer runs are local only. No third-party starter or fixture has been copied.
