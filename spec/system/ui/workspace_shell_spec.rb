# frozen_string_literal: true

require 'rails_helper'

# UI — workspace shell pill meta-nav.
#
# First visual-regression baseline for the project. Any change to the
# meta-nav HTML/CSS that isn't intentional will fail this spec.
RSpec.describe 'Workspace shell', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'shows Dashboard as the first pill tab, active by default' do
    visit '/workspace'
    expect(page).to have_css('.meta-tabs .meta-tabs__btn', count: 5)
    first_tab = page.all('.meta-tabs__btn').first
    expect(first_tab.text.strip).to eq('Dashboard')
    expect(first_tab[:class]).to include('is-active')
  end

  it 'lists Dashboard · Setup · Knowledge base · Canvas · Review in order' do
    visit '/workspace'
    labels = page.all('.meta-tabs__btn').map { |el| el.text.strip }
    expect(labels).to eq(%w[Dashboard Setup] + ['Knowledge base'] + %w[Canvas Review])
  end

  it 'has the ExamGen wordmark on the left and + New dropdown on the right' do
    visit '/workspace'
    expect(page).to have_css('.meta-nav__wordmark', text: 'ExamGen')
    expect(page).to have_css('.meta-new__btn', text: /\+\s*New/)
  end
end
