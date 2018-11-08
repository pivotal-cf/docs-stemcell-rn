# Contributing to Stemcell Release Notes

The Linux stemcell release notes topic is an auto-generated file `stemcells.html`. A script
in the `ci` folder checks for new stemcells and outputs `stemcells.html.md.erb`. Every 15 minutes, "pubtools-docs-helper" pushes a commit if the script finds a new release.

## Modify Release Notes

You cannot edit `stemcells.html.md.erb`. If you do, your changes will be overridden.

To add custom content to the *Stemcell Release Notes* topic, create a `.html.md.erb` partial in the `ci` / `additional_info` folder named after its corresponding release note.

**Note:** The file must begin with an underscore (`_`) and you must replace `.` with `-` in the filename.

Your partial appends to the release notes of that stemcell version.

## Find Pivotal Network Stemcells

The stemcell release notes now publish all stemcells regardless if they are on Pivotal Network. Each stemcell release in the release notes indicates whether or not they are on Pivotal Network.
