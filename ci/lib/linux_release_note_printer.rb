class LinuxReleaseNotePrinter
  def initialize(stemcell_info:, release_collection:, tanzu_net_versions_by_line:)
    @stemcell_info = stemcell_info
    @release_collection = release_collection
    @tanzu_net_versions_by_line = tanzu_net_versions_by_line
  end

  def generate
    header + release_notes.join("\n")
  end

  private

  def release_notes
    @stemcell_info[:supported_lines].flat_map do |release_line_name, release_line_info|
      release_line_header(release_line_name) +
        release_line_release_notes(release_line_name, release_line_info).join("\n")
    end
  end

  def release_line_release_notes(release_line_name, release_line_info)
    release_line_info[:supported_major_versions].flat_map do |major_version|
      release_line_major_version_header(release_line_name, major_version) +
        release_line_major_version_release_notes(release_line_name, major_version).join("\n")
    end
  end

  def release_line_major_version_release_notes(release_line_name, major_version)
    @release_collection.for(line: release_line_name, version_major: major_version).map do |release|
      release_markdown(release_line_name, release)
    end
  end

  def header
    <<~HEADER
        ---
        title: Stemcell (Linux) Release Notes
        owner: BOSH
        modified_date: false
        ---

        This topic includes release notes for Linux stemcells used with <%= vars.platform_name %>.

    HEADER
  end

  def release_line_header(release_line_name)
    <<~RELEASE_LINE_HEADER
        ## <a id="#{release_line_name.downcase}"></a> #{release_line_name.capitalize} Stemcells

        The following sections describe each #{release_line_name.capitalize} stemcell release.

    RELEASE_LINE_HEADER
  end

  def release_line_major_version_header(release_line_name, major_version)
    <<~RELEASE_LINE_MAJOR_VERSION_HEADER
        ### <a id="#{version_line_anchor_for(release_line_name, major_version)}"></a> #{major_version}.x

        This section includes release notes for the #{major_version}.x line of Linux stemcells used with <%= vars.platform_name %>.

    RELEASE_LINE_MAJOR_VERSION_HEADER
  end

  # TODO: ask if we can change the anchor link format for :xenial
  def version_line_anchor_for(release_line_name, major_version)
    if release_line_name == :xenial
      "#{major_version}-line"
    else
      "#{release_line_name}-#{major_version}-line"
    end
  end

  def release_markdown(release_line_name, release)
    <<~RELEASE_MARKDOWN
        #### <a id="#{release_anchor_for(release_line_name, release.version_string)}"></a> #{release.version_string}

        #{tanzu_net_markup(release_line_name, release.version_string)}
        **Release Date**: #{release.date.strftime('%B %d, %Y')}

        #{adjust_markdown_header(release.body)}
        #{additional_context(release.version_string)}
      RELEASE_MARKDOWN
  end

  def adjust_markdown_header(text)
    text.gsub('## ', '#### ')
  end

  def release_anchor_for(line, version_string)
    anchor_version = version_string.sub('.', '-')
    if line == :xenial
      anchor_version
    else
      "#{line}-#{anchor_version}"
    end
  end

  def tanzu_net_markup(release_line_name, version_string)
    return unless @tanzu_net_versions_by_line[release_line_name].include?(version_string)

    <<~PIVNET_AVAILABLE
        <span class="pivnet">Available in the Broadcom Support portal</span>
      PIVNET_AVAILABLE
  end

  def additional_context(version)
    File.read(additional_context_file(version)) if File.exist?(additional_context_file(version))
  end

  def additional_context_file(version)
    File.join('additional_info', "_#{version.sub('.', '-')}.html.md.erb")
  end
end
