# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workspace sidebar shell', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'renders a 260px sidebar with grouped nav on the left' do
    visit '/workspace'
    expect(page).to have_css('.app')
    expect(page).to have_css('.app > .sidebar')
    expect(page).to have_css('.app > .main')
    expect(page).to have_css('.sidebar .brand')
    expect(page).to have_css('.sidebar .nav a', minimum: 5)
  end

  it 'groups navigation into Workspace / Library / Build / History' do
    visit '/workspace'
    groups = page.all('.sidebar .navgroup-label').map { |el| el.text.strip.downcase }
    expect(groups).to include('workspace', 'library', 'build', 'history')
  end

  it 'marks the current section as active' do
    visit '/workspace?tab=dashboard'
    expect(page).to have_css('.sidebar .nav a.active', text: 'Dashboard')

    visit '/workspace?tab=history'
    expect(page).to have_css('.sidebar .nav a.active', text: /Exam history|Exams/)
  end

  it 'no longer shows the pill-tab meta-nav' do
    visit '/workspace'
    expect(page).not_to have_css('.meta-tabs')
  end
end
