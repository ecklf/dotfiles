---
description: Generate a PR description based on the current branch changes
---

Generate a PR description based on the changes in the current branch compared to the main branch (`main`, `master` - whichever exists first).

Use `git diff` and `git log` to analyze the changes.

Output the PR description in the following format:

# Summary

> Short and concise description of the change
