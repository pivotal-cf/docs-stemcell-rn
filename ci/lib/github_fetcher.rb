require 'octokit'

class GithubFetcher
  attr_accessor :client

  def initialize(client: nil)
    @client = client || default_client
  end

  def fetch_releases(repo)
    client.releases(repo)
  end

  def default_client
    Octokit::Client.new(
      auto_paginate: true,
      access_token: ENV['GITHUB_ACCESS_TOKEN'],
    )
  end
end
