REPO_ROOT = File.expand_path('..', File.dirname(__FILE__))
CI_LIB_DIR = File.join(REPO_ROOT, 'ci', 'lib')

[CI_LIB_DIR].each do |dir|
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

require 'github_fetcher'
require 'tanzu_net_fetcher'
require 'stemcell_release'
require 'stemcell_release_collection'
require 'linux_release_note_printer'

LINUX_STEMCELL_INFO = {
  supported_lines: {
    jammy: {
      tanzunet_uri: 'https://network.tanzu.vmware.com/api/v2/products/stemcells-ubuntu-jammy/releases',
      supported_major_versions: [1],
    },
    xenial: {
      tanzunet_uri: 'https://network.tanzu.vmware.com/api/v2/products/stemcells-ubuntu-xenial/releases',
      supported_major_versions: [621, 456],
    },
  },
  github_repos: %w[cloudfoundry/bosh-linux-stemcell-builder pivotal-cf/bosh-linux-stemcell-builder-lts],
}.freeze

def main
  github_fetcher = GithubFetcher.new
  github_releases =
    LINUX_STEMCELL_INFO[:github_repos].flat_map do |repo|
      github_fetcher.fetch_releases(repo)
    end

  release_collection = StemcellReleaseCollection.new(releases: github_releases.map { |h| StemcellRelease.new(h) })

  tanzu_net_versions_by_line =
    LINUX_STEMCELL_INFO[:supported_lines].each_with_object({}) do |supported_line, memo|
      memo[supported_line[0]] = TanzuNetFetcher.new.versions(releases_uri: supported_line[1][:tanzunet_uri])
    end

  puts LinuxReleaseNotePrinter.new(stemcell_info: LINUX_STEMCELL_INFO,
                                   release_collection: release_collection,
                                   tanzu_net_versions_by_line: tanzu_net_versions_by_line).generate
end

main
