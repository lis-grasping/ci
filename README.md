# ci

The GitHub Actions workflows that the grasp repositories share: lint, tests, the
release check and the release. A repository calls them from one `ci.yml`, pinned by
tag, and passes only what differs.

## Use

```yaml
name: CI

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

permissions:
  contents: read

jobs:
  lint:
    # A pull request into main shows the runs of its head on develop
    if: github.event_name == 'push' || github.base_ref == 'develop'
    uses: lis-grasping/ci/.github/workflows/lint.yml@v0.1.0
    secrets: inherit

  tests:
    uses: lis-grasping/ci/.github/workflows/tests.yml@v0.1.0
    with:
      pythons: '["3.10", "3.11", "3.12", "3.13", "3.14"]'
      all: ${{ github.ref == 'refs/heads/main' || github.base_ref == 'main' }}
    secrets: inherit

  release-check:
    if: github.ref == 'refs/heads/main' || github.base_ref == 'main'
    uses: lis-grasping/ci/.github/workflows/release-check.yml@v0.1.0

  release:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: [lint, tests, release-check]
    concurrency:
      group: release
      cancel-in-progress: false
    permissions:
      contents: write
    uses: lis-grasping/ci/.github/workflows/release.yml@v0.1.0
    with:
      tag: ${{ needs.release-check.outputs.tag }}
      title: <name> ${{ needs.release-check.outputs.version }}
      notes: ${{ needs.release-check.outputs.notes }}
```

Pushes to `develop` lint and test on the Python of development. A pull request into
`main` tests every supported Python and the lowest versions, and checks the release.
Its merge runs all of it again and then tags `v<version>` and makes the GitHub
release from the version's section of `CHANGELOG.md`.

| Workflow | Inputs |
|---|---|
| `lint.yml` | `apt-packages` |
| `tests.yml` | `pythons`, `python` (`3.13`), `lowest-python` (`3.10`), `all`, `apt-packages` |
| `release-check.yml` | `version-source`: `uv` (the project's version) or `changelog` |
| `release.yml` | `tag`, `title`, `notes` |

While graspkit is private, `lint.yml` and `tests.yml` read it with the secret
`GRASPKIT_DEPLOY_KEY`, the private half of a read-only deploy key of graspkit. Without
it they install graspkit as a public repository. `scripts/add-deploy-keys.sh` creates
the key and sets the secret in every repository that installs graspkit; it needs `gh`
logged in as an owner of the organization.

## Release

Work happens on `develop`. A release is one commit `Release <version>` on `develop`,
which moves the `Unreleased` entries of `CHANGELOG.md` into a dated section with its
compare link, and then the pull request `Release <version>` from `develop` into
`main`, merged with a merge commit. This repository's version is the newest dated
section of `CHANGELOG.md`.
