# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Topic detail — view switcher', type: :system, js: true do
  before do
    driven_by(:selenium_chrome_headless)
    create(:topic, name: 'Sub-56 Seed Topic') unless Topic.exists?
  end

  let(:modules) { sub56_canonical_modules }

  it 'cycles modules → categories → outcomes → modules on topic-view:cycle' do
    visit_sub56_fixture(modules: modules, topic_id: 9001)

    expect(page).to have_css('[data-view="modules"]:not([hidden])', visible: :all)

    page.execute_script('document.querySelector("[data-controller~=\'topic-view\']").dispatchEvent(new CustomEvent("topic-view:cycle"))')
    expect(page).to have_css('[data-view="categories"]:not([hidden])', visible: :all)

    page.execute_script('document.querySelector("[data-controller~=\'topic-view\']").dispatchEvent(new CustomEvent("topic-view:cycle"))')
    expect(page).to have_css('[data-view="outcomes"]:not([hidden])', visible: :all)

    page.execute_script('document.querySelector("[data-controller~=\'topic-view\']").dispatchEvent(new CustomEvent("topic-view:cycle"))')
    expect(page).to have_css('[data-view="modules"]:not([hidden])', visible: :all)
  end

  it 'tracks aria-selected on the view tabs' do
    visit_sub56_fixture(modules: modules, topic_id: 9002)
    page.find('[role="tab"][data-view="categories"]').click
    expect(page).to have_css('[role="tab"][data-view="categories"][aria-selected="true"]', visible: :all)
    expect(page).to have_css('[role="tab"][data-view="modules"][aria-selected="false"]', visible: :all)
  end

  it 'persists the view choice to localStorage' do
    visit_sub56_fixture(modules: modules, topic_id: 9003)
    page.find('[role="tab"][data-view="outcomes"]').click
    expect(page).to have_css('[data-view="outcomes"]:not([hidden])', visible: :all)
    # Wait for the 200ms debounced write
    sleep 0.3
    stored = page.evaluate_script("localStorage.getItem('topic-detail:topic-9003:view')")
    expect(stored).to eq('outcomes')
  end

  it 'sorts the flat outcomes list by the selected sort option' do
    visit_sub56_fixture(modules: modules, topic_id: 9004)
    page.find('[role="tab"][data-view="outcomes"]').click

    page.find('select#outcomes-sort').select 'Nq descending'
    rows = page.all('[data-outcome-row]', visible: :all)
    nq_values = rows.map { |r| r['data-nq'].to_i }
    expect(nq_values).to eq(nq_values.sort.reverse)

    page.find('select#outcomes-sort').select 'Alphabetical'
    rows = page.all('[data-outcome-row]', visible: :all)
    texts = rows.map { |r| r['data-lo-text'].to_s.downcase }
    expect(texts).to eq(texts.sort)
  end

  it 're-applies the live search query after a view change' do
    visit_sub56_fixture(modules: modules, topic_id: 9005)
    fill_in 'search-outcomes', with: 'Schrödinger'
    wait_for_search_announcement(/match/i)
    page.find('[role="tab"][data-view="categories"]').click
    expect(page).to have_css('[data-view="categories"]:not([hidden])', visible: :all)

    # In the categories pane, only matching rows should be visible (no filter class).
    cat_pane_visible_rows = page.all(
      '[data-view="categories"] [data-lo-text]:not(.topic-detail__lo--filtered)',
      visible: :all
    )
    expect(cat_pane_visible_rows).not_to be_empty
    cat_pane_visible_rows.each do |row|
      lo_text = row['data-lo-text'].to_s
      cat = row.find(:xpath, "ancestor::*[@data-cat-name][1]", visible: :all)['data-cat-name'].to_s
      expect(lo_text.downcase.include?('schrödinger') || cat.downcase.include?('schrödinger')).to be true
    end
  end
end
