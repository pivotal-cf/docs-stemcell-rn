# Stemcell Release Notes

This repository contains content for the Stemcell release notes. We publish the this documentation at https://docs.vmware.com/en/Stemcells-for-VMware-Tanzu/services/release-notes/index.html.

In this README:

- [Find Tanzu Network Stemcells](#find-tanzu-network-stemcells)
- [Contributing to Stemcell Release Notes](#contributing-to-stemcell-release-notes)
- [Publishing the Docs](#publishing-the-docs)

## Find Tanzu Network Stemcells

The stemcell release notes now publish all stemcells regardless of whether or not they are on
[Tanzu Network](https://network.pivotal.io/). Each stemcell release in the release
notes indicates whether or not they are can be found on Tanzu Network.

## Contributing to Stemcell Release Notes

The Linux stemcell release notes topic is an auto-generated file `stemcells.html`. A script
in the `ci` folder checks for new stemcells and outputs `stemcells.html.md.erb`. Every 15 minutes,
"pubtools-docs-helper" pushes a commit if the script finds a new release.

Committing to this repository automatically goes to the production site at docs.pivotal.io.

You cannot edit `stemcells.html.md.erb`. If you do, your changes will be overridden.

### Modify Release Notes

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

## Publishing the Docs

These docs have been migrated to https://docs.vmware.com and are now published using the following tools:

- [docworks](https://docworks.vmware.com/) is the main tool for managing docs used by writers.
- [docsdash](https://docsdash.vmware.com/) is a deployment UI which manages the promotion from
staging to pre-prod to production. The process below describes how to upload our docs to staging,
replacing the publication with the same version.

### Prepare Markdown Files

This repo contains the following files:

- Markdown files live in this repo.
- The table of contents is now in this repo in the [toc.md](toc.md) file. Each page requires an entry in the TOC.
- Variables also live in this repo in the [template_variables.yml](template_variables.yml).

### In DocWorks

1. Run a build of the "Stemcell Release Notes" project to upload the docs to Docs Dash.
2. Review your changes on the staging site https://docs-staging.vmware.com/...

### In Docsdash

1. Wait about 1 minute for processing to complete after uploading.
2. Go to https://docsdash.vmware.com/deployment-stage.

### Promoting to Pre-Prod and Prod

**Prerequisite** Needs additional privileges - reach out to a manager on the docs team [#tanzu-docs](https://vmware.slack.com/archives/C055V2M0H) or ask a writer to do this step for you.

1. Go to Staging publications in docsdash  
  https://docsdash.vmware.com/deployment-stage

2. Select a publication (make sure it's the latest version)

3. Click "Deploy selected to Pre-Prod" and wait for the pop to turn green (refresh if necessary after about 10s)

4. Go to Pre-Prod list  
  https://docsdash.vmware.com/deployment-pre-prod

5. Select a publication

6. Click "Sign off for Release"

7. Wait for your username to show up in the "Signed off by" column

8. Select the publication again

9. Click "Deploy selected to Prod"

