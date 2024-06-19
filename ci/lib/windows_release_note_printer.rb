class WindowsReleaseNotePrinter
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
    filtered_releases.map { |release_hash| release_markdown(release_hash) }
  end

  def filtered_releases
    @release_collection.for.select do |release|
      supported_lines.any? { |line| release.line?(line) } &&
        !release.prerelease
    end
  end

  def supported_lines
    @stemcell_info[:supported_lines].keys
  end

  def header
    <<~HEADER
      ---
      title: Stemcell v2019.x (Windows Server version 2019) Release Notes
      owner: Windows
      modified_date: false
      ---

      This topic includes release notes for Windows stemcells used with the following runtimes:

      - <%= vars.windows_runtime_full %> (<%= vars.windows_runtime_abbr %>) v2.5 and later:
        - For Windows stemcell compatibilities with <%= vars.windows_runtime_abbr %>, see specific stemcell version notes below.
      - VMware <%= vars.k8s_runtime_full %> (<%= vars.k8s_runtime_abbr %>, formerly PKS) v1.5 and later:
        - For Windows stemcell compatibilities with <%= vars.k8s_runtime_abbr %>, refer to the [Release Notes](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid-Integrated-Edition/1.19/tkgi/GUID-release-notes.html) for your <%= vars.k8s_runtime_abbr %> version.

      The stemcell is based on Windows Server, version 2019.

      To download a stemcell, see [Stemcells (Windows)](https://network.tanzu.vmware.com/products/stemcells-windows-server) on VMware Tanzu Network.

      <p class="note">
      <span class="note__title">Note</span>
      Manual stemcell creation is deprecated.
      Use <code>stembuild</code> v2019.23 or later to create stemcells automatically.
      For more information,
      see <a href="https://docs.vmware.com/en/VMware-Tanzu-Application-Service/<%= vars.current_major_version %>/tas-for-vms/create-vsphere-stemcell-automatically.html">Creating a Windows Stemcell for vSphere Using stembuild</a>.
      </p>

    HEADER
  end

  def release_markdown(release_hash)
    <<~RELEASE_MARKDOWN
      ## <a id="#{release_hash.version_string}"></a>#{release_hash.version_string}

      **Release Date**: #{release_hash.date.strftime('%B %d, %Y')}

      #{release_hash.body}
    RELEASE_MARKDOWN
  end
end
