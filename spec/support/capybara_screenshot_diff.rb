# frozen_string_literal: true

require 'capybara/screenshot/diff'
require 'capybara_screenshot_diff/rspec'

Capybara::Screenshot.root          = Rails.root
Capybara::Screenshot.save_path     = 'spec/screenshots'
Capybara::Screenshot.blur_active_element = true

# Tolerances: font-hinting + sub-pixel AA jitter between local/CI means we
# can't require byte-identical PNGs. These thresholds tolerate ~250 pixels
# of difference and up to 8 units of RGB distance before a spec fails.
Capybara::Screenshot::Diff.enabled = ENV['DISABLE_SCREENSHOT_DIFF'] != '1'
Capybara::Screenshot::Diff.area_size_limit = 250
Capybara::Screenshot::Diff.color_distance_limit = 8

# Fixed viewport so screenshots are stable regardless of where the suite
# runs. The window dimensions match the design's working canvas width so
# our rendered output lines up with the design reference 1:1.
UI_SPEC_VIEWPORT = [1280, 1600].freeze

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:each, type: :system) do
    # Only resize when the browser is actually up (rack_test has no window).
    if Capybara.current_driver != :rack_test && page.driver.respond_to?(:browser)
      begin
        page.driver.browser.manage.window.resize_to(*UI_SPEC_VIEWPORT)
      rescue Selenium::WebDriver::Error::UnsupportedOperationError,
             Selenium::WebDriver::Error::UnknownError
        # Headless chrome sometimes can't resize the initial window in CI;
        # not fatal for the suite.
      end
    end
  end
end
