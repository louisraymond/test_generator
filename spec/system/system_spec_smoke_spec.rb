# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'system spec smoke (sub-53)', type: :system, js: true do
  it 'launches headless Chrome and evaluates JS' do
    visit '/up'
    expect(page.evaluate_script('1 + 1')).to eq(2)
  end
end
