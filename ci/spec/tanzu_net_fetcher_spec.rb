require 'tanzu_net_fetcher'

RSpec.describe TanzuNetFetcher do
  subject(:tanzu_net_fetcher) { TanzuNetFetcher.new(open_uri: mock_uri) }

  let(:mock_uri) { class_double(URI) }
  let(:mock_uri_instance) { instance_double(OpenURI::OpenRead) }
  let(:fake_releases_uri) { 'https://network.tanzu.vmware.com/api/v2/products/FAKE_PRODUCT/releases' }
  let(:fake_releases_json) do
    {
      'releases' => [
        { 'version' => '123' },
        { 'version' => '45.6' },
        { 'version' => '722' },
        { 'version' => '7.22' },
      ]
    }.to_json
  end
  # JSON.parse(URI.parse('https://network.tanzu.vmware.com/api/v2/products/stemcells-ubuntu-jammy/releases').read)['releases'].first['version']
  # => "1.465"

  describe '#versions' do
    before do
      allow(mock_uri).to receive(:parse).with(fake_releases_uri).and_return(mock_uri_instance)
      allow(mock_uri_instance).to receive(:read).and_return(fake_releases_json)
    end

    it 'returns a list of versions' do
      expect(
        tanzu_net_fetcher.versions(releases_uri: fake_releases_uri)
      ).to eq(['123', '45.6', '722', '7.22'])
    end
  end
end