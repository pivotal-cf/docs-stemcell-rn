require 'github_fetcher'

RSpec.describe GithubFetcher do
  subject(:github_fetcher) { GithubFetcher.new }

  let(:client) { instance_double(Octokit::Client) }
  let(:github_access_token) { 'fake-github-access-token' }

  before do
    allow(ENV).to receive(:[]).with("GITHUB_ACCESS_TOKEN").and_return(github_access_token)

    allow(Octokit::Client).to receive(:new).with(auto_paginate: true,
                                                 access_token: github_access_token).and_return(client)
  end

  describe '#initialize' do
    it 'sets up a client' do
      expect(github_fetcher.client).to eq(client)
    end
  end

  describe '#fetch_releases' do
    let(:repo) { 'fake-org/fake-release' }

    it 'calls the octokit client as expected' do
      expect(client).to receive(:releases).with(repo)

      github_fetcher.fetch_releases(repo)
    end
  end
end
