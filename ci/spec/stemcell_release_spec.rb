require 'stemcell_release'

RSpec.describe StemcellRelease do
  describe '#initialize' do
    subject(:stemcell_release) { StemcellRelease.new(github_release) }

    let(:expected_version_string) { '42.13' }
    let(:expected_version_major) { 42 }
    let(:expected_version_minor) { 13 }
    let(:created_at) { nil }
    let(:published_at) { Time.new(2020, 03, 16, 0, 0, 0) }

    let(:github_release) do
      {
        name: "Fake Release #{expected_version_string} for Testing",
        body: 'Fake release body',
        created_at: created_at,
        published_at: published_at,
        prerelease: false
      }
    end

    it 'sets #name to :name' do
      expect(stemcell_release.name).to eq(github_release[:name])
    end

    it 'extracts #version_string from :name' do
      expect(stemcell_release.version_string).to eq(expected_version_string)
    end

    context 'when name does not contain a number' do
      it 'sets #version_string to nil' do
        expect(StemcellRelease.new(name: 'foo').version_string).to eq(nil)
      end
    end

    it 'extracts #version_major from #version_string' do
      expect(stemcell_release.version_major).to eq(expected_version_major)
    end

    it 'extracts #version_minor from #version_string' do
      expect(stemcell_release.version_minor).to eq(expected_version_minor)
    end

    it 'sets :prerelease' do
      expect(stemcell_release.prerelease).to eq(github_release[:prerelease])
    end

    it 'sets #body to :body' do
      expect(stemcell_release.body).to eq(github_release[:body])
    end

    it 'sets #date to :published_at' do
      expect(stemcell_release.date).to eq(published_at)
    end

    context 'when the github release has no :published_at date' do
      let(:created_at) { Time.new(2024, 03, 16, 0, 0, 0) }
      let(:published_at) { nil }

      it 'sets #date to :created_at' do
        expect(stemcell_release.date).to eq(created_at)
      end
    end
  end

  describe '#body' do
    it 'replaces "title:" with "**Title:**"' do
      expect(StemcellRelease.new(body: "title: Something").body).to eq('**Title:** Something')
    end

    it 'replaces "url:" with "**URL:**"' do
      expect(StemcellRelease.new(body: "url: Something").body).to eq('**URL:** Something')
    end

    it 'replaces "priorities:" with "**Priorities:**"' do
      expect(StemcellRelease.new(body: "priorities: Something").body).to eq('**Priorities:** Something')
    end

    it 'replaces "description:" with "**Description:**"' do
      expect(StemcellRelease.new(body: "description: Something").body).to eq('**Description:** Something')
    end

    it 'replaces "cves:" with "**CVEs:**"' do
      expect(StemcellRelease.new(body: "cves: Something").body).to eq('**CVEs:** Something')
    end

    it 'replaces "\r\n" with "<br>\n"' do
      expect(StemcellRelease.new(body: "Something\r\nElse").body).to eq("Something<br>\nElse")
    end
  end

  describe '#line?' do
    subject(:stemcell_release) { StemcellRelease.new(name: 'Fake 456.789 Some_line Test') }

    it 'returns true if the input matches #name' do
      expect(stemcell_release.line?(:some_line)).to eq(true)
    end

    it 'returns false if the input does not match #name' do
      expect(stemcell_release.line?(:other_line)).to eq(false)
    end
  end

  describe '#version_major?' do
    subject(:stemcell_release) { StemcellRelease.new(name: 'Fake 456.789 Some_line Test') }

    before do
      expect(stemcell_release.version_major).to eq(456)
    end

    it 'returns true if the input matches the version_major extracted from #name' do
      expect(stemcell_release.version_major?(456)).to eq(true)
    end

    it 'returns false if the input does not match the version_major extracted from #name' do
      expect(stemcell_release.version_major?(789)).to eq(false)
    end
  end

  describe '#<=>' do
    it 'sorts in descending order by Gem::Version of #version_string' do
      expect(StemcellRelease.new(name: '123') <=> StemcellRelease.new(name: '456')).to eq(1)
      expect(StemcellRelease.new(name: '456') <=> StemcellRelease.new(name: '456')).to eq(0)
      expect(StemcellRelease.new(name: '456') <=> StemcellRelease.new(name: '123')).to eq(-1)

      expect(StemcellRelease.new(name: '1.23') <=> StemcellRelease.new(name: '1.24')).to eq(1)
      expect(StemcellRelease.new(name: '1.23') <=> StemcellRelease.new(name: '1.23')).to eq(0)
      expect(StemcellRelease.new(name: '1.23') <=> StemcellRelease.new(name: '1.22')).to eq(-1)
    end
  end
end
