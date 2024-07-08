require 'json'
require 'open-uri'

class TanzuNetFetcher
  def initialize(open_uri: URI)
    @open_uri = open_uri
  end

  def versions(releases_uri:)
    response_json = @open_uri.parse(releases_uri).read
    response = JSON.parse(response_json)

    if response.has_key?('releases')
      response['releases'].map { |release| release['version'] }
    else
      []
    end
  end
end