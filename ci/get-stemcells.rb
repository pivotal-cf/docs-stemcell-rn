require 'json'
require 'octokit'
require 'open-uri'
require 'base64'

module Resources
  class Github
    def initialize
      @client = Octokit::Client.new(auto_paginate: true, access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def get_stemcell_releases
      get_bosh_stemcell_releases + get_linux_stemcell_builder_releases + get_linux_stemcell_builder_lts_releases
    end

    private
    def get_bosh_stemcell_releases
      bosh_releases = @client.releases 'cloudfoundry/bosh'

      bosh_releases.select do |r|
        r[:name].start_with?("Stemcell")
      end.map do |release|
        release_to_hash(release)
      end
    end

    def get_linux_stemcell_builder_releases
      bosh_releases = @client.releases 'cloudfoundry/bosh-linux-stemcell-builder'
      bosh_releases.map do |release|
        release_to_hash(release)
      end
    end

    def get_linux_stemcell_builder_lts_releases
      bosh_releases = @client.releases 'pivotal-cf/bosh-linux-stemcell-builder-lts'
      bosh_releases.map do |release|
        release_to_hash(release)
      end
    end

    def release_to_hash(release)
      version = release[:name][/\d+(\.\d+)?/]
      version_split = version.split('.')
      major_version = version_split[0].to_i
      minor_version = 0
      minor_version = version_split[1].to_i if version_split.length > 1

      {
        'name' => release[:name],
        'version' => release[:name][/\d+(\.\d+)?/],
        'major_version' => major_version,
        'minor_version' => minor_version,
        'body' => release[:body],
        'created_at' => release[:created_at],
        'published_at' => release[:published_at],
        'pivnet_available' => false,
      }
    end
  end

  class Pivnet
    def get_pivnet_releases(api_endpoint)
      #get and parse the list of stemcell releases from pivnet
      stemcells = URI.parse(api_endpoint).read
      stemcells = JSON.parse(stemcells)
      stemcells_list = stemcells['releases']

      #put the list of stemcells in order of their version numbers
      sorted_stemcells_list = stemcells_list.sort_by { |h| h['version'] }.reverse

      right_stemcells = sorted_stemcells_list.select do |d|
        d['version'].start_with?("#{@starting_stemcell_version}")
      end

      stemcells_numbers_list = right_stemcells.map do |r|
        r['version']
      end

      return stemcells_numbers_list
    end
  end
end

def sorted_releases_by_major_version(releases)
  result = {}
  releases.each do |release|
    unless result.has_key? release['major_version']
      result[release['major_version']] = []
    end

    result[release['major_version']] << release
  end

  return result.sort.reverse.to_h
end

def puts_release_notes(releases, pivnet_api, release_type)
  pivnet = Resources::Pivnet.new
  pivnet_releases = pivnet.get_pivnet_releases(pivnet_api)

  output = "## <a id=\"#{release_type.downcase}\"></a> #{release_type} Stemcells \n\n"
  output += "The following sections describe each #{release_type} stemcell release. \n\n"
  releases.each do |major_version, minor_releases|
    output += "### <a id=\"#{major_version}-line\"></a> #{major_version}.x \n\n"
    output += "This section includes release notes for the #{major_version} line of Linux stemcells used with <%= vars.platform_name %>.\n\n"

    minor_releases.sort_by {|release| release['minor_version']}

    minor_releases.each_with_index do |release, i|
      version = release['version']

      output += "#### <a id=\"#{version.sub('.', '-')}\"></a> #{version}\n\n"

      output += "<span class='pivnet'>Available in VMware Tanzu Network</span>\n\n" if pivnet_releases.include?(version)

      if !release['published_at'].nil?
        release_date = release['published_at'].strftime("%B %d, %Y")
      else
        release_date = release['created_at'].strftime("%B %d, %Y")
      end
      output += "**Release Date**: #{release_date}\n\n"

      output += release['body']+ "\n\n"

      additional_info_path = 'additional_info'
      additional_context_file = File.join(additional_info_path, "_#{version.sub('.', '-')}.html.md.erb")
      if File.exist?(additional_context_file)
        file = File.open(additional_context_file, "rb")
        output += file.read + "\n\n"
        file.close
      end
    end
  end

output = output.gsub("title:", "**Title:**")
output = output.gsub("url:", "<br>**URL:**")
output = output.gsub("priorities:", "<br>**Priorities:**")
output = output.gsub("description:", "<br>**Description:**")
output = output.gsub("cves:", "<br>**CVEs:**")
output = output.gsub("- https", "<br>- https")
puts output

end

def main
  github = Resources::Github.new
  github_releases = github.get_stemcell_releases

  output = <<-HEADER
---
title: Stemcell (Linux) Release Notes
owner: BOSH
modified_date: false
---

This topic includes release notes for Linux stemcells used with <%= vars.platform_name %>.\n\n
HEADER

  major_version_releases = sorted_releases_by_major_version(github_releases)
  releases_xenial = major_version_releases.select{|major_version| major_version < 3000}
  releases_trusty = major_version_releases.select{|major_version| major_version >= 3000}

  puts output

  puts_release_notes(releases_xenial, 'https://network.pivotal.io/api/v2/products/stemcells-ubuntu-xenial/releases',
                     "Xenial")
  puts_release_notes(releases_trusty, 'https://network.pivotal.io/api/v2/products/stemcells/releases',
                     "Trusty")
end

main
