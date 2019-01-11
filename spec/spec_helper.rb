require 'simplecov'
#require 'undercover'

SimpleCov.start do
  add_filter(%r{\/spec\/})
end

require './lib/banking'
require './lib/banking/constants'
require './lib/banking/storage'
require './lib/banking/base_tax'
require './lib/banking/usual_tax'
require './lib/banking/virtual_tax'
require './lib/banking/capitalist_tax'
require './lib/banking/tax'
require './lib/banking/card'
require './lib/banking/cash_flow'
require './lib/banking/account'
require './lib/banking/console_cashflow'
require './lib/banking/console_account'
require './lib/banking/console'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
