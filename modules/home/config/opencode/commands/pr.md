---
description: Create or update the pull request for the current branch
---

Upsert the GitHub pull request for the current branch.

1. Determine the current branch, its GitHub remote, and the base branch. Prefer `main`, then `master`, checking remote branches rather than assuming either exists.
2. Use the `gh` CLI to check whether a pull request already exists for the current repository and head branch. Check all PR states so an existing PR is not duplicated.
3. If a PR exists:
   - Analyze the PR's commits and complete diff against its actual base branch. Use the remote PR changes rather than uncommitted or unpushed local changes.
   - Generate a new body using the exact format below.
   - Update the existing PR body with `gh pr edit`. Do not change its draft state, title, base, or head branch.
   - Report the PR URL and that it was updated.
4. If no PR exists, check whether the current branch exists on the GitHub remote.
5. If the remote branch exists:
   - Analyze the remote branch's commits and complete diff against the selected base branch.
   - Generate a concise PR title and a body using the exact format below.
   - Create the PR in draft mode with `gh pr create --draft`.
   - Report the PR URL.
6. If the remote branch does not exist:
   - Inspect the working tree and commits that have not been pushed.
   - Ask the user for confirmation before committing, pushing, or creating the PR. State which actions are needed; do not perform any of them before confirmation.
   - If confirmed, commit only the intended changes when a commit is needed, push the current branch, and create a draft PR as described above.

Write the PR body to a temporary file and pass it to `gh` with `--body-file` so Markdown formatting is preserved. Remove the temporary file afterward.

Use this exact PR body format:

## TLDR

Short and concise summary of the change. As the title implies, this is a "too long; didn't read" summary.

## Problem

A concise description of the problem the changes solve.

## Solution

A concise description of how the changes solve the problem, including important implementation details.

## Testing

How reviewers can verify the change. Clearly state when tests were not run or when no automated tests exist.
