# Contributing code

## 📢 Conventional Commits 📢

To enhance our development workflow, enable automated changelog generation, and pave the way for Continuous Delivery,
the `dtrpg-sdk.swift` project has adopted the [Conventional Commits
standard](https://www.conventionalcommits.org/en/v1.0.0/) for all commit messages.

Going forward, all commits to this repository **MUST** adhere to the Conventional Commits standard. Commits not
adhering to this standard will not be included in the generated changelog.

## Branching and pull requests

- Branch from `develop`, open pull requests against `develop`.
- CI (`.github/workflows/pr.yaml`) must pass on Linux and macOS (Apple Silicon) before merging.
- Do not open pull requests directly against `master` — releases reach `master` only via the automated release
  process described in [RELEASE.md](RELEASE.md).
