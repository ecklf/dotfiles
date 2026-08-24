# Global Agent Instructions

## Missing Tools

- When a required command or package is unavailable, use `nix-shell -p <packages> --run '<command>'` instead of installing it globally.
- Include every package needed for the task in the same `nix-shell -p` invocation rather than starting separate shells for individual dependencies.

## Pull Requests

- When generating or updating a pull request description, follow the exact PR body format and content requirements in `commands/pr.md`.
