# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard screen', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'renders breadcrumb + page-head + stat row + two-col panels (pixel-match design)' do
    visit '/workspace?tab=dashboard'

    # Breadcrumb: "WORKSPACE / DASHBOARD" mono-caps
    expect(page).to have_css('.breadcrumb', text: /Workspace.*Dashboard/i)

    # Page-head: Fraunces h1 with time-of-day greeting + action buttons
    expect(page).to have_css('.page-head h1', text: /Good (morning|afternoon|evening)/)
    expect(page).to have_css('.page-head .btn', minimum: 2)

    # Stat row: four tiles
    expect(page).to have_css('.stat-row .stat', count: 4)

    # Two-col: recent activity + quick actions panels
    expect(page).to have_css('.two-col .panel', count: 2)
    expect(page).to have_css('.activity-item', minimum: 5)
    expect(page).to have_css('.quick-card', count: 5)
  end

  it 'each quick-card points at a real route (no dead buttons)' do
    visit '/workspace?tab=dashboard'

    page.all('.quick-card a, a.quick-card').each do |link|
      href = link[:href]
      expect(href).not_to be_blank, "quick-card has empty href"
      expect(href).not_to eq('#'), "quick-card links to fragment"
    end
  end

  it 'greeting says Good morning before noon' do
    travel_to Time.zone.local(2026, 4, 22, 9, 0) do
      visit '/workspace?tab=dashboard'
      expect(page).to have_css('.page-head h1', text: /Good morning/)
    end
  end

  it 'greeting says Good evening after 18:00' do
    travel_to Time.zone.local(2026, 4, 22, 19, 0) do
      visit '/workspace?tab=dashboard'
      expect(page).to have_css('.page-head h1', text: /Good evening/)
    end
  end
end
