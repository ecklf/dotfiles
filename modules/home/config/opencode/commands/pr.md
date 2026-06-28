---
description: Set a PR description for the current change
---

Generate a PR description based on the changes in the current branch compared to the main branch (`main`, `master` - whichever exists first).

Use `git diff` and `git log` to analyze the changes.

Output the PR description in the following format:

## TLDR 

> Short and concise summary of the change. As the title implies it's a "too long didn't read" summary

## Problem

> A concise description of the problem we are trying to solve with the changes in this PR.

## Solution 

> The solution to the above problem.

## Testing

> A description on how this feature can be tested for reviewers.

Check if the PR already exists for the current branch, if not create it in draft mode.
