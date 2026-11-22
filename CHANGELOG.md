# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `scripts/add-deploy-keys.sh`, moved from graspkit, which creates graspkit's
  read-only deploy key and sets it as the secret `GRASPKIT_DEPLOY_KEY` of every
  repository that installs graspkit.

## [0.1.0] - 2026-11-22

### Added

- The reusable workflows `lint.yml`, `tests.yml`, `release-check.yml` and
  `release.yml`, taken from graspkit's, graspdata's and graspsim's. `lint.yml` and
  `tests.yml` install system packages that a repository names, and read the private
  graspkit with the secret `GRASPKIT_DEPLOY_KEY`. `release-check.yml` takes the
  version from uv or from CHANGELOG.md.

[Unreleased]: https://github.com/lis-grasping/ci/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/lis-grasping/ci/releases/tag/v0.1.0
