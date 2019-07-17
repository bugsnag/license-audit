# License Audit

Internal audit tool to check our repositories for compliance of open source licensing with company policy.

This Ruby script runs through a list of repositories to audit and runs the [LicenseFinder](https://github.com/pivotal/LicenseFinder) tool against them. With appropriate whitelisted licenses and pre-approved packages checked-in and maintained in this repository, this audit should succeed with no unexpected licenses.

## Usage

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

Each repo will be cloned into the `apps` directory (on `master` branch) and LicenseFinder is run from this location.

## Approving Packages & Whitelisting Licensing

See the [LicenseFinder](https://github.com/pivotal/LicenseFinder) documentation for instructions on adding packages approvals or license whitelists.

These decisions are stored (by default) in `doc/dependency_decisions.yml` in the repo. This script makes a temporary file in the cloned repository in `/apps` that is concatenated from a company-wide file at `/decision_files/global.yml` and a repository-specific file at `/decision_files/<repo_name>.yml`. This means the decisions are maintained in one place and is kept private from the public repositories.
