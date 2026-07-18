# Release process

## Summary

1. Trigger the [**Prepare Release**](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/prepare-release.yaml) workflow.
1. Merge the resulting PR into `master`.
1. Tagging, the GitHub Release, and syncing `master` back into `develop` all happen automatically.

## Breakdown

Instead of writing the changelog by hand on a release branch, a `prepare-release` workflow does it for you:

```sh
git checkout develop
git pull
```

Trigger the [**Prepare Release**](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/prepare-release.yaml) workflow (`workflow_dispatch` in the Actions tab). It:

1. Runs `git-cliff --bump` against `develop` to determine the next version (e.g. `0.3.0`) from commits
   since the last tag.
2. Prepends the generated changelog section to `CHANGELOG.md`.
3. Opens a PR from an auto-created `release/0.3.0` branch into `master`.

Unlike `dtrpg-sdk.rs`, there's no manifest version to bump — SwiftPM has no version field in `Package.swift`;
a package's version is purely whatever git tag points at a given commit.

You review the PR (catch anything that shouldn't ship) — the [**PR**](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/pr.yaml)
workflow runs against it — and merge into `master`.

Merging triggers [**Tag Release**](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/tag-release.yaml),
which tags `master` with `vX.Y.Z` matching the merged `release/X.Y.Z` branch name:

```sh
git tag -a v0.3.0 -m "Release 0.3.0"
git push origin v0.3.0
```

The tag push triggers the [**Release**](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/release.yaml)
workflow, which builds, tests, generates the changelog scoped to that tag, attaches it to the GitHub Release, merges
`master` back into `develop`, and notifies `dtrpg-app.swift` via repository dispatch. Swift Package Index does not need
an explicit publish step — it polls public repositories for new semver tags and indexes them automatically.

## Triggering the run

```sh
gh workflow run prepare-release.yaml
```

Or trigger it directly from the [Prepare Release workflow page](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/prepare-release.yaml).
