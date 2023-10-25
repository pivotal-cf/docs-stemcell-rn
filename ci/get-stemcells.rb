require 'json'
require 'octokit'
require 'open-uri'
require 'base64'


STEMCELL_RELEASES = {
  jammy: {
    tanzunet_uri: 'https://network.pivotal.io/api/v2/products/stemcells-ubuntu-jammy/releases',
    supported_lines: %w(1),
  },
  xenial: {
    tanzunet_uri: 'https://network.pivotal.io/api/v2/products/stemcells-ubuntu-xenial/releases',
    supported_lines: %w(621 456),
  }
}

module Resources
  class Github
    def initialize
      @client = Octokit::Client.new(auto_paginate: true, access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def get_stemcell_releases
      get_linux_stemcell_builder_releases + get_linux_stemcell_builder_lts_releases
    end

    private

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
    # Get and parse the list of stemcell releases from pivnet
    def self.get_pivnet_releases(api_endpoint)
      stemcells_response = URI.parse(api_endpoint).read
      stemcells = JSON.parse(stemcells_response)

      stemcells['releases']
        .map { |s| s['version'] }
        .sort
        .reverse
    rescue => e
      $stderr.puts "Error getting pivnet releases, exiting: #{e}"
      exit 1
    end
  end
end

def header
  <<-HEADER
---
title: Stemcell (Linux) Release Notes
owner: BOSH
modified_date: false
---

This topic includes release notes for Linux stemcells used with <%= vars.platform_name %>.\n\n
HEADER
end

def puts_release_notes(releases, ubuntu_release_name, stemcell_info)
  major_version_releases = sorted_releases_by_major_version(releases)
  releases = major_version_releases.select{|major_version| stemcell_info[:supported_lines].include?(major_version.to_s) }

  pivnet_releases = Resources::Pivnet.get_pivnet_releases(stemcell_info[:tanzunet_uri])

  output = "## <a id=\"#{ubuntu_release_name.downcase}\"></a> #{ubuntu_release_name.capitalize} Stemcells \n\n"
  output += "The following sections describe each #{ubuntu_release_name.capitalize} stemcell release. \n\n"
  releases.each do |major_version, minor_releases|
    output += "### <a id=\"#{version_line_anchor_for(ubuntu_release_name, major_version)}\"></a> #{major_version}.x \n\n"
    output += "This section includes release notes for the #{major_version}.x line of Linux stemcells used with <%= vars.platform_name %>.\n\n"

    minor_releases.sort_by {|release| release['minor_version']}

    minor_releases.each_with_index do |release, i|
      version = release['version']

      output += "#### <a id=\"#{release_anchor_for(ubuntu_release_name, version)}\"></a> #{version}\n\n"

      output += "<span class='pivnet'>Available in VMware Tanzu Network</span>\n\n" if pivnet_releases.include?(version)

      if !release['published_at'].nil?
        release_date = release['published_at'].strftime("%B %d, %Y")
      else
        release_date = release['created_at'].strftime("%B %d, %Y")
      end
      output += "**Release Date**: #{release_date}\n\n"

      body = humanize_old_stemcell_release_notes(release['body'])
      body = body
        .gsub('## ', '#### ')
        .gsub(/\r\n/, "<br>\n")
      output += body + "\n\n"

      additional_info_path = 'additional_info'
      additional_context_file = File.join(additional_info_path, "_#{version.sub('.', '-')}.html.md.erb")
      if File.exist?(additional_context_file)
        file = File.open(additional_context_file, "rb")
        output += file.read + "\n\n"
        file.close
      end
    end
  end

  puts output
end

def sorted_releases_by_major_version(releases)
  result = {}
  releases.each do |release|
    unless result.has_key? release['major_version']
      result[release['major_version']] = []
    end

    result[release['major_version']] << release
  end

  result.each do |stemcell_line, releases_for_line|
    result[stemcell_line] = releases_for_line.sort_by { |a| Gem::Version.new(a['version']) }.reverse
  end

  return result.sort.reverse.to_h
end

def version_line_anchor_for(ubuntu_release_name, major_version)
  case ubuntu_release_name
  when :xenial
    "#{major_version}-line"
  else
    "#{ubuntu_release_name}-#{major_version}-line"
  end
end

def release_anchor_for(ubuntu_release_name, version)
  anchor_version = version.sub('.', '-')

  case ubuntu_release_name
  when :xenial
    anchor_version
  else
    "#{ubuntu_release_name}-#{anchor_version}"
  end
end

def humanize_old_stemcell_release_notes(text)
  text
    .gsub("title:", "**Title:**")
    .gsub("url:", "**URL:**")
    .gsub("priorities:", "**Priorities:**")
    .gsub("description:", "**Description:**")
    .gsub("cves:", "**CVEs:**")
end

def main
  github = Resources::Github.new
  github_releases = github.get_stemcell_releases

  puts header

  STEMCELL_RELEASES.each do |ubuntu_release_name, stemcell_info|
    filtered_releases = github_releases.select{|release| release['name'].downcase.include?(ubuntu_release_name.to_s)}

    puts_release_notes(filtered_releases, ubuntu_release_name, stemcell_info)
  end
end

main
