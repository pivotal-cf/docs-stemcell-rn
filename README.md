# Contributing to Stemcell Release Notes

The Linux stemcell release notes topic is an auto-generated file `stemcells.html`. A script
in the `ci` folder checks for new stemcells and outputs `stemcells.html.md.erb`. Every 15 minutes, "pubtools-docs-helper" pushes a commit if the script finds a new release.

You cannot edit `stemcells.html.md.erb`. If you do, your changes will be overridden.

## Modify Release Notes

To append new content to the *Stemcell Release Notes* topic:

1. Go to the `ci` / `additional_info` folder.
1. Create a file formatted like the following:
  ```
  _STEMCELL-VERSION.html.md.erb
  ```
  For example:
  ```terminal
  _97-32.html.md.erb
  ```
  The file must begin with an underscore (`_`) and you must replace all `.` with `-` in the filename.
  
1. Enter your release notes in Markdown format. Avoid headings.

1. Commit and push your new file.

1. Check [Stemcell (Linux) Release Notes](https://docs-pcf-staging.cfapps.io/platform/stemcells/stemcells.html) on the docs staging site after several minutes. See that your partial appends to the release notes of that stemcell version.

If you experience any issues, contact #pcf-docs in Slack.

## Find Pivotal Network Stemcells

The stemcell release notes now publish all stemcells regardless if they are on Pivotal Network. Each stemcell release in the release notes indicates whether or not they are on Pivotal Network.
