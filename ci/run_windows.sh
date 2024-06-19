#!/usr/bin/env bash

set -ex

pushd docs-stemcell-rn/ci
	bundle install
	windows_2019_stemcell_tempfile="$(mktemp)"
	ruby get_windows_stemcells.rb > "${windows_2019_stemcell_tempfile}"
	mv "${windows_2019_stemcell_tempfile}" ../windows-stemcell-v2019x.html.md.erb

	if [[ -n $(git status --porcelain) ]]; then
		git config user.name "Stemcell Release Notes Bot"
		git config user.email "cf-docs@pivotal.io"
		git add --all :/
		git commit -m "Updating windows 2019 stemcell markdown file"
	fi
popd

shopt -s dotglob
cp -R "docs-stemcell-rn/." "updated-docs-stemcell-rn/"
