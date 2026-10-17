# Katas delivery governance (CaliWood model)

## Branch roles and integration

- `main`: stable, intentionally promoted. This is the default branch and Dependabot's update target.
- `dev`: integration of tested kata increments and infrastructure changes.
- New work starts from current `dev`, using `features/*`, `bugs/*`, `releases/*`, `hotfixes/*`, `tags/*` or `kata/*`. Historic `feature/*`, `chore/*` and `docs/*` branches remain compatible during transition.
- Working branches target `dev` through PRs and **squash merge**. Retain working branches by default.
- Do not push changes directly to either long-lived branch.

## Stable promotion

1. Select the exact current `dev` head commit and record its SHA.
2. Verify CI relevant to the changed katas and the catalog. A passing run for an older SHA is not proof for a newer candidate. Do not promote unresolved, failing, or unmerged PRs.
3. Open a `dev → main` pull request. Ensure the diff contains only intended, certified content, and that checks validate the exact candidate.
4. **Squash merge** into `main` only when the current PR candidate is green; recheck if `dev` changes.
5. Verify post-merge `main` CI and the resulting stable tree.

### Mandatory ancestry synchronization

Squash promotion intentionally does not connect the commit ancestry of `dev` and `main`.
After a successful stable promotion and post-merge validation:

1. Create a `main → dev` PR.
2. Verify the GitHub synthetic merge changes **no repository content** relative to the PR's current `dev` base. The `Branch governance` workflow runs this gate.
3. Only when this test passes, merge with a **regular merge commit**, never squash. This is the sole routine exception to the squash policy.
4. If the sync introduces changes, resolve the difference deliberately; do not merge a content-changing sync.

Do not synchronize if `dev` has acquired additional changes since the stable promotion, without first reconciling them. Preserve a reproducible stable version and avoid promoting incomplete work.

## Dependabot

`.github/dependabot.yml` exists in `main` so GitHub can read it. It must also remain in `dev`, otherwise a `dev → main` squash promotion could accidentally remove it. Both configured ecosystems open PRs against **main** (default), not `dev`:

- GitHub Actions references.
- Go module manifests inside `katas/*`.

Dependabot's direct PRs into stable `main` are an explicit dependency-maintenance exception to product-branch flow, not a license to bypass CI. Updates still require green validation and a squash merge. Security update settings are managed separately in GitHub repository settings.

## Review checklist

PRs should include their outcome, source and destination, relevant quality evidence, exact head SHA, CI state and known risks. For the kata pilot, the evidence contract in `AGENTS.md` (RED/GREEN, independent oracle, Ninja review, licensing and published-state gates) remains authoritative.
