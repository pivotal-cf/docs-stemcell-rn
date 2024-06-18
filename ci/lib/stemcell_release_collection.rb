class StemcellReleaseCollection
  def initialize(releases:)
    @releases = releases
  end

  def for(line:, version_major:)
    @releases.select { |release| release.line?(line) && release.version_major == version_major }.sort
  end
end
