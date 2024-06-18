class StemcellRelease
  attr_reader :name, :version_string, :version_major, :version_minor, :date, :body

  def initialize(github_release)
    @name = github_release[:name]
    @version_string = version_string_from(github_release[:name])
    @version_major = version_major_from(@version_string)
    @version_minor = version_minor_from(@version_string)
    @date = date_from(github_release)
    @body = reformat(github_release[:body])
  end

  def line?(line)
    name.match?(/#{line}/i)
  end

  def <=>(other)
    Gem::Version.new(other.version_string) <=> Gem::Version.new(version_string)
  end

  private

  def version_string_from(release_name)
    return if release_name.nil?
    match = /(\d+(\.\d+)?)/.match(release_name)
    match[1] if match && match.length > 1
  end

  def version_major_from(version_string)
    return if version_string.nil?

    version_string.split('.')[0].to_i
  end

  def version_minor_from(version_string)
    return if version_string.nil?

    version_split = version_string.split('.')
    version_split.length > 1 ? version_split[1].to_i : 0
  end

  def date_from(github_release)
    github_release[:published_at] || github_release[:created_at]
  end

  def reformat(text)
    return if text.nil?
    text.gsub('title:', '**Title:**')
        .gsub('url:', '**URL:**')
        .gsub('priorities:', '**Priorities:**')
        .gsub('description:', '**Description:**')
        .gsub('cves:', '**CVEs:**')
        .gsub(/\r\n/, "<br>\n")
  end
end