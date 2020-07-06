# Contributing to Stemcell Release Notes

The Linux stemcell release notes topic is an auto-generated file `stemcells.html`. A script
in the `ci` folder checks for new stemcells and outputs `stemcells.html.md.erb`. Every 15 minutes,
"pubtools-docs-helper" pushes a commit if the script finds a new release.

Committing to this repository automatically goes to the production site at docs.pivotal.io.

You cannot edit `stemcells.html.md.erb`. If you do, your changes will be overridden.

## Modify Release Notes

To append new content to the *Stemcell Release Notes* topic:

1. On a command line, navigate to the `ci` / `additional_info` directory.

1. Create a file formatted as follows:
    ```
    _STEMCELL-VERSION.html.md.erb
    ```
    For example:
    ```
    _97-32.html.md.erb
    ```
    The file must begin with an underscore (`_`) and you must replace all `.` with `-` in the
    filename.
  
1. Enter your release notes in Markdown format. Avoid headings.

1. Commit and push your new file.

1. Review [Stemcell (Linux) Release Notes](https://docs-pcf-staging.cfapps.io/platform/stemcells/stemcells.html)
    on the documentation staging site a few minutes to ensure that your partial appends to the
    release notes of that stemcell version.

If you experience any issues, contact #pcf-docs in Slack.

## Find [Tanzu Network](https://network.pivotal.io/) Stemcells

The stemcell release notes now publish all stemcells regardless of whether or not they are on
[Tanzu Network](https://network.pivotal.io/). Each stemcell release in the release
notes indicates whether or not they are can be found on <%= vars.product_network %>.
