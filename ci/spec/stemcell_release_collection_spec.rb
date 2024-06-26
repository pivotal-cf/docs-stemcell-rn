require 'stemcell_release_collection'
require 'stemcell_release'

RSpec.describe StemcellReleaseCollection do
  subject(:stemcell_release_collection) { StemcellReleaseCollection.new(releases: releases) }

  let(:line1) { 'First Line' }
  let(:line2) { 'LAST Line' }

  let(:line1_version0) { '13.2' }
  let(:line1_version1) { '11.99' }

  let(:line2_version0) { '4.3' }
  let(:line2_version1) { '11.04' }
  let(:line2_version2) { '11.11' }

  let(:line1_major_13) do
    [
      StemcellRelease.new(name: "Release #{line1} #{line1_version0}"),
    ]
  end

  let(:line1_major_11) do
    [
      StemcellRelease.new(name: "Release #{line1} #{line1_version1}"),
    ]
  end

  let(:line2_major_4) do
    [
      StemcellRelease.new(name: "Release #{line2} #{line2_version0}"),
    ]
  end

  let(:line2_major_11) do
    [
      StemcellRelease.new(name: "Release #{line2} #{line2_version2}"),
      StemcellRelease.new(name: "Release #{line2} #{line2_version1}"),
    ]
  end

  let(:releases) do
    line1_major_13 +
      line1_major_11 +
      line2_major_4 +
      line2_major_11
  end

  describe '#for' do
    context 'when only :line and :version_major are specified' do
      it 'returns stemcell releases matching the :line, and :version_major, sorted by (gem) version descending' do
        expected_releases =
          line2_major_11.sort do |a, b|
            Gem::Version.new(b.version_string) <=> Gem::Version.new(a.version_string)
          end

        expect(stemcell_release_collection.for(line: line2, version_major: 11)).to eq(expected_releases)
      end
    end

    context 'when only :line is specified' do
      it 'returns stemcell releases matching the :line, sorted by (gem) version descending' do
        expected_releases =
          (line2_major_4 + line2_major_11).sort do |a, b|
            Gem::Version.new(b.version_string) <=> Gem::Version.new(a.version_string)
          end

        expect(stemcell_release_collection.for(line: line2)).to eq(expected_releases)
      end
    end

    context 'when only :version_major is specified' do
      it 'returns stemcell releases matching the :version_major, sorted by (gem) version descending' do
        expected_releases =
          (line1_major_11 + line2_major_11).sort do |a, b|
            Gem::Version.new(b.version_string) <=> Gem::Version.new(a.version_string)
          end

        expect(stemcell_release_collection.for(version_major: 11)).to eq(expected_releases)
      end
    end
  end
end