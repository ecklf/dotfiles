---
description: Review PRs in an explicitly specified repository, post AI-labelled updates, and ask before pushing fixes
agent: build
---

Review GitHub pull requests only in the repository explicitly specified by the user, using the maintainer workflow below.

Arguments: $ARGUMENTS

Usage: `/review-prs owner/repo [PR numbers or URLs] [--no-local-tests]`

## Repository scope

- Require an explicit repository as `owner/repo` or a GitHub repository URL. A full PR URL may supply both the repository and a single PR target.
- If the repository is missing or ambiguous, ask which repository to review before querying PRs or posting comments. Do not fall back to the current directory or account-wide PR searches.
- Resolve the canonical repository with `gh repo view owner/repo --json nameWithOwner,url` and keep that repository fixed throughout discovery, review, comments, and final reconciliation.
- Pass `--repo owner/repo` to every `gh pr` command. Use repository-specific `repos/owner/repo/...` endpoints for PR-related `gh api` calls. Do not use account-wide search results as the review scope.
- Accept PR selectors only when their base repository matches the selected repository. Reject PR URLs from other repositories, even if their PR numbers match.
- Use a checkout whose remote matches the selected repository. Locate or create an isolated checkout when needed rather than inspecting or modifying an unrelated working directory. A contributor's fork is only a permitted push destination for an approved PR belonging to the selected base repository.

## Scope

- With no PR targets, review every open PR in the selected repository not authored by the authenticated GitHub user, including drafts. Identify the user with `gh api user`, rather than assuming the repository owner is the user.
- PR numbers or URLs in the arguments limit the review to those PRs. Exclude the user's own PRs unless explicitly asked to include them.
- `--no-local-tests` skips all local test execution, including unit tests, smoke tests, coverage, and rendering test scripts. Inspect build and lint commands before running them so they do not indirectly execute tests. Other explicit testing instructions also take precedence.
- Treat the remaining arguments as additional review constraints. Do not interpret this command alone as permission to implement, commit, or push fixes.

## Discover and review

1. Read the selected repository's agent and development instructions. Inspect its checkout, remotes, and default branch. Preserve unrelated local work.
2. Use `gh` for GitHub operations, explicitly scoped to the selected repository. Paginate discovery so no open PRs in that repository are silently omitted. Record the eligible PR numbers, authors, actual base branches, head repositories and branches, and head commit IDs at the start of the review.
3. For each eligible PR, read its description, all included commits, complete diff against its actual base, existing comments and reviews, and CI results. Review the relevant surrounding code and integration paths, not just the latest commit or patch in isolation.
4. Use isolated worktrees for different PRs. Do not check a contributor's branch out over the user's working tree or reuse built artifacts from another PR snapshot.
5. Look for concrete correctness issues, regressions, broken navigation or state transitions, persistence and migration problems, compatibility, localization, packaging, and release metadata required by the repository. Give findings a severity, file and line references, reproducible conditions, and a proposed fix. Avoid speculative findings and style-only churn.
6. Run meaningful, targeted checks appropriate to the change when permitted. Use the repository's isolated or mocked test conventions. Distinguish PR regressions from baseline failures and environment blockers. Passing existing tests does not replace reviewing behavior that those tests miss.
7. Report CI accurately, distinguishing passed, failed, in progress, missing, and awaiting workflow approval. Do not approve workflow runs unless requested. Never describe an unrun, blocked, or failing check as passed.

## Comment and ask for approval

1. Post a concise review comment on every reviewed PR. Every AI-authored PR comment must start with `🤖`. Mention human authors with `@username` and identify yourself as an AI assistant helping the maintainer.
2. If fixes are needed, explain the findings, the specific adjustments proposed, and the checks performed or skipped. Before approval, describe the work as proposed and awaiting approval, not already approved or in progress.
3. If no changes are needed, say so and summarize the verification performed. Do not invent adjustments or create empty commits.
4. Summarize the review to the user with links to each PR. Ask explicitly which proposed fixes may be implemented, committed, and pushed. A batch approval may cover the named PRs and described fixes. Ask again before expanding to other PRs or unrelated changes.
5. Post comments rather than formal approvals. Do not merge, close, retarget, mark ready, or edit a PR's title or description unless explicitly requested. Follow `commands/pr.md` if PR description changes are requested.

## Implement approved fixes

After the user approves specific changes, continue through implementation and pushing rather than stopping at a plan.

1. Refresh the approved PR's head and actual base before editing. Check maintainer push access and use the contributor's real head repository and branch. If direct updates are unavailable, report the blocker instead of silently creating another PR.
2. Before implementation, post an update starting with `🤖` that tags the author, lists the approved changes, and says you are working on them now. For example:

   > 🤖 @author I am the AI coding assistant helping @maintainer. The maintainer approved the following fixes, and I am working on their implementation now: ...

3. Make focused fixes consistent with repository conventions. Add release notes or changesets when required. Add meaningful regression coverage for uncovered behavior, and honor `--no-local-tests` or any later instruction to skip local tests.
4. Resolve integration conflicts in approved PRs against their current bases while preserving both sides' intended behavior and relevant tests. Prefer normal merge commits for base updates. Do not rebase, amend, or force-push contributor history without explicit permission.
5. Before committing, inspect `git status`, `git diff`, and `git log --oneline -10`. Stage only the intended changes. Do not commit secrets, generated diagnostics, or unrelated user work. Use concise commit messages matching the repository's style.
6. Recheck the remote head before pushing. Incorporate any concurrent author updates without overwriting them. Push only to the approved PR's head branch, without force.
7. Post a completion comment starting with `🤖`, mentioning the author, pushed commit IDs, changes applied, and the verification actually performed. Explicitly note skipped tests or blocked checks.

## Final reconciliation

- Recheck the reviewed, still-open PRs in the selected repository against their latest bases before finishing. A PR merged during this work can introduce conflicts in another PR.
- Resolve new conflicts within the approved scope. For conflicts in PRs not covered by approval, notify the author with a `🤖` comment and ask the user before implementing or pushing an integration fix.
- Mention newly opened PRs separately rather than silently expanding the original review into an unbounded loop.
- End with a concise per-PR summary: findings or no findings, comment and PR links, fixes pushed and commit IDs, verification, current mergeability, and any approval still needed. Keep mergeability separate from CI success.

## Examples

- `/review-prs ecklf/lg-luma` reviews open PRs by other authors only in `ecklf/lg-luma` and asks before implementing fixes.
- `/review-prs ecklf/lg-luma 27 28` limits the workflow to PRs #27 and #28 in that repository.
- `/review-prs ecklf/lg-luma --no-local-tests` follows the same repository-scoped workflow without executing local tests.
- `/review-prs https://github.com/owner/repo/pull/27 --no-local-tests` reviews one PR with local tests disabled.
