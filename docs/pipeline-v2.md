# Development/CI overlap — experiment extension 2026-10-17

The new pipeline is **single-author serial development with asynchronous CI**. A kata must have an implemented solution, verified local RED, GREEN, a structurally independent oracle, authorship/provenance notes, and Ninja review **before** work begins on the next. It may then set `development_complete: true` and stay `green` until remote CI has reported results.

GitHub-hosted CI may run in parallel with creation of the following kata. This saves wait time but MUST NOT be taken to mean concurrent or incomplete kata development.

## Catalog scanning

Every source scan adds all new canonical candidate records with stable IDs, source URLs and provisional fingerprints/difficulty, status `discovered`. The scan manifest records how many were considered, unique and rejected. Rights and rubric are audited **per candidate** before marking eligible. Scan records are append-only and independently reviewable. This first expanded scan covers the 31 exercises listed by Kata-Log, including the four prior published ones.

## Promotion

`green + development_complete` = independently tested locally, GitHub CI pending. `verified` = GitHub CI green and evidence. `published` = integrated reviewed PR and explicit skill review. Already-published count is NOT affected by overlapping work.

If the current PR's CI fails, fix it and/or open a follow-up corrective PR. Do not hide the failure, and do not merge a partially tested branch.

## Throughput policy: do not poll away the iteration

**Engineering WIP is sequential, CI WIP is concurrent.** In each hourly execution, continue developing the next distinct eligible kata immediately after the previous kata reaches `green + development_complete`, aiming for up to nine locally completed katas per run. "CI is still running" is not a stopping condition or a reason to burn remaining work time refreshing workflow statuses.

- Check CI at the beginning to recover failures, and again opportunistically at a batch checkpoint/end. Avoid repeated tight polling. Handle actual failures when discovered; do not hide red evidence or merge unverified work.
- Commit logical, independently testable kata increments with reproducible results. Avoid moving a shared PR head purely to trigger another CI cycle. Prefer a stable CI checkpoint and continue development on a separate feature branch or unpublished local commits when appropriate.
- GitHub CI may verify a previous kata while new source is written, but `verified` and `published` require evidence for the actual reviewed head. Never credit local-only results to the published total.
- Measure separately **active engineering time**, **time awaiting CI**, **CI duration**, and **time spent polling CI**. The goal is more verified useful output per working window, not higher reported throughput by conflating states.
- Resume eligible work while the slowest JVM/Swift/etc. jobs run. Finish a kata's local tests, independent oracle, provenance and Ninja note *before* beginning the next, and keep idempotent checkpoints to reconcile agents and updated branches.

## Git tooling: no dependency on GitHub CLI

The hourly agent must **never require `gh`**. First detect tools, checkout, remotes and credentials:

1. With a valid workspace, use ordinary `git` (`status`, `fetch`, `log`, `diff`, `switch`, `commit`, `push`) for source/version operations on its own feature branch. Verify the remote state, avoid rewriting someone else's work and never force-push.
2. Prefer the connected GitHub tools for PR creation, reviews, CI checks, or source access when Git alone cannot perform the action. Connector use is also valid without any local checkout.
3. If Git credentials or write capability are missing, record what actually failed and pivot to a usable connector. Absence of `gh` **is not a blocker**. Absence of working Git and connector write access is a real blocker, not permission to claim unpushed changes.
4. Never require installing an external CLI to continue; do not invent commits, build outcomes, pushes or PR numbers.

This policy applies to unattended hourly executions and interactive work alike.
