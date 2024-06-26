REPO_ROOT = File.expand_path(File.join('..', '..'), File.dirname(__FILE__))
CI_LIB_DIR = File.join(REPO_ROOT, 'ci', 'lib')

[CI_LIB_DIR].each do |dir|
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true # RSpec 4 default
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # RSpec 4 default
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups # RSpec 4 default

  # Recommended
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  # config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
