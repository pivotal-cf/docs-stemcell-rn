REPO_ROOT = File.expand_path('..', File.dirname(__FILE__))
CI_LIB_DIR = File.join(REPO_ROOT, 'ci', 'lib')

[CI_LIB_DIR].each do |dir|
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

require 'github_fetcher'
require 'stemcell_release'
require 'stemcell_release_collection'
require 'windows_release_note_printer'

WINDOWS_STEMCELL_INFO = {
  supported_lines: {
    '2019': {
      tanzunet_uri: 'https://network.tanzu.vmware.com/api/v2/products/stemcells-windows-server/releases',
      supported_major_versions: [2019],
    }
  },
  github_repos: %w[cloudfoundry/stembuild],
}.freeze

def main
  github_fetcher = GithubFetcher.new
  github_releases =
    WINDOWS_STEMCELL_INFO[:github_repos].flat_map do |repo|
      github_fetcher.fetch_releases(repo)
    end

  release_collection = StemcellReleaseCollection.new(releases: github_releases.map { |h| StemcellRelease.new(h) })

  puts WindowsReleaseNotePrinter.new(stemcell_info: WINDOWS_STEMCELL_INFO,
                                     release_collection: release_collection,
                                     tanzu_net_versions_by_line: []).generate
end

main
