# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_topic_toolbar.html.erb', type: :view do
  let(:topic) { create(:topic, name: 'X') }

  it 'renders search, +Outcome, +Module, and ? as real buttons / inputs' do
    render partial: 'topics/topic_toolbar', locals: { topic: topic }
    expect(rendered).to have_css('input[type="search"][placeholder="Search outcomes, categories, modules…"]')
    expect(rendered).to have_css('button[type="button"]', text: '+ Outcome')
    expect(rendered).to have_css('button[type="button"]', text: '+ Module')
    expect(rendered).to have_css('button[type="button"]', text: '?')
  end

  it 'gives every control type="button" so it does not submit a form' do
    render partial: 'topics/topic_toolbar', locals: { topic: topic }
    page_buttons = Capybara.string(rendered).all('button')
    expect(page_buttons).to all(have_css('button[type="button"]', count: 0).or(satisfy { |b| b['type'] == 'button' }))
  end
end
