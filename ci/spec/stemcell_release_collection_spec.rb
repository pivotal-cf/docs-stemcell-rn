require 'stemcell_release_collection'
require 'stemcell_release'

RSpec.describe StemcellReleaseCollection do
  subject(:stemcell_release_collection) { StemcellReleaseCollection.new(releases: releases) }

  let(:line0) { 'first-line' }
  let(:line1) { 'Second Line' }
  let(:line2) { 'LAST Line' }

  let(:line1_version0) { '13.2' }
  let(:line1_version1) { '12' }

  let(:line0_version0) { '1.2' }
  let(:line0_version1) { '3.3' }

  let(:line2_version0) { '4.3' }
  let(:line2_version1) { '11.04' }
  let(:line2_version2) { '11.11' }

  let(:line2_major_11) do
    [
      StemcellRelease.new(name: "Release #{line2} #{line2_version2}"),
      StemcellRelease.new(name: "Release #{line2} #{line2_version1}"),
    ]
  end

  let(:releases) do
    [
      StemcellRelease.new(name: "Release #{line1} #{line1_version0}"),
      StemcellRelease.new(name: "Release #{line1} #{line1_version1}"),

      StemcellRelease.new(name: "Release #{line0} #{line0_version0}"),
      StemcellRelease.new(name: "Release #{line0} #{line0_version1}"),

      StemcellRelease.new(name: "Release #{line2} #{line2_version0}"),
    ] + line2_major_11
  end

  describe '#for' do
    it 'returns stemcell releases matching the :line, and :version, sorted by version descending' do
      expected_releases =
        line2_major_11.sort do |a, b|
          Gem::Version.new(b.version_string) <=> Gem::Version.new(a.version_string)
        end

      expect(stemcell_release_collection.for(line: line2, version_major: 11)).to eq(expected_releases)
    end
  end
end