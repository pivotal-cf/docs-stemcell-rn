class StemcellReleaseCollection
  def initialize(releases:)
    @releases = releases
  end

  def for(line: nil, version_major: nil)
    @releases.select do |release|
      (line ? release.line?(line) : true) &&
        (version_major ? release.version_major?(version_major) : true)
    end.sort
  end
end

