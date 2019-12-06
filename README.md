# License Audit

[![Build status](https://badge.buildkite.com/20f948b9c7ff7b797a28865ae743627dd78a4664079738992a.svg)](https://buildkite.com/bugsnag/notifier-license-audit)

Internal audit tool to check our repositories for compliance of open source licensing with company policy.

This Ruby script runs through a list of repositories to audit and runs the [LicenseFinder](https://github.com/pivotal/LicenseFinder) tool against them. With appropriate whitelisted licenses and pre-approved packages checked-in and maintained in this repository, this audit should succeed with no unexpected licenses.

## Local Usage

Checkout the code and run:

```
bundle install
```

Check the content of `license_audit.yml` for the repositories to clone, checkout, build and audit.

Run the tool on all repositories in the file:

```
bundle exec license_audit
```

Or just an individual one:

```
bundle exec license_audit audit bugsnag-js
````

Each repo will be cloned into the `apps` directory and LicenseFinder is run from this location.

Build output from `stdout`/`stderr` is stored in `build` and audit report files are in `report`.

## Docker Usage

The audit can be run with `docker-compose` which creates an image for each build environment and allows them to be executed individually:

```
docker-compose build
docker-compose run ruby
docker-compose run java
docker-compose run js
docker-compose run php
docker-compose run python
```
The `docker-compose.yml` file parameterises the base image and APK's required. It also volumes the `apps`, `build` and `reports` directories so they are shared by each run and produce a single report. Most builds use a single `Dockerfile` in the `dockerfiles` directory, but more complex environments (e.g. Android) can use a custom `Dockerfile` by putting the path into the `docker-compoose.yml`.

## Approving Packages & Whitelisting Licensing

See the [LicenseFinder](https://github.com/pivotal/LicenseFinder) documentation for instructions on adding packages approvals or license whitelists.

These decisions are stored (by default) in `doc/dependency_decisions.yml` in the repo. This script makes a temporary file in the cloned repository in `/apps` that is concatenated from a company-wide file at `/decision_files/global.yml` and a repository-specific file at `/decision_files/<repo_name>.yml`. This means the decisions are maintained in one place and is kept private from the public repositories.