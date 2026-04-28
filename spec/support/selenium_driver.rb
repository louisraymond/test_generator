# Per-agent JS driver setup (sub-55). Removed on merge.
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :sub55_headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1400,900')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, :sub55_js) do
    driven_by :sub55_headless_chrome
  end
end
