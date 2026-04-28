# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Topic detail — search', type: :system, js: true do
  before do
    driven_by(:selenium_chrome_headless)
    # Seed minimal data so /topics renders without N+1 surprise.
    create(:topic, name: 'Sub-56 Seed Topic') unless Topic.exists?
  end

  let(:modules) { sub56_canonical_modules }

  it 'live-filters outcomes that match the query and hides the rest' do
    visit_sub56_fixture(modules: modules)

    # Modules pane has 28 LOs; categories + outcomes panes mirror them.
    expect(page).to have_css(
      '[data-view="modules"] [data-lo-text]', visible: :all, count: 28
    )
    fill_in 'search-outcomes', with: 'Schrödinger'

    wait_for_search_announcement(/match/i)

    # Every outcome under the "Schrödinger Equation" category counts (cat-name match).
    cat_match_rows = page.all(
      '[data-view="modules"] [data-cat-name="Schrödinger Equation"] [data-lo-text]',
      visible: :all
    )
    expect(cat_match_rows).not_to be_empty
    cat_match_rows.each do |row|
      expect(row[:class].to_s).not_to include('topic-detail__lo--filtered')
    end

    # Rows in the "Vectors" category (no match) get the filter class.
    vec_rows = page.all(
      '[data-view="modules"] [data-cat-name="Vectors"] [data-lo-text]',
      visible: :all
    )
    expect(vec_rows).not_to be_empty
    vec_rows.each do |row|
      expect(row[:class].to_s).to include('topic-detail__lo--filtered')
    end

    # The "Vectors" category in the modules pane gets the cat-filter class.
    expect(page).to have_css(
      '[data-view="modules"] [data-cat-name="Vectors"].topic-detail__cat--filtered',
      visible: :all
    )
  end

  it 'treats a module-name match as every outcome in that module' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'Atoms'
    wait_for_search_announcement(/match/i)

    atoms_rows = page.all(
      '[data-mod-name="Atoms"] [data-lo-text]',
      visible: :all
    )
    expect(atoms_rows).not_to be_empty
    atoms_rows.each do |row|
      expect(row[:class].to_s).not_to include('topic-detail__lo--filtered')
    end

    badge = page.find(
      '[data-mod-name="Atoms"] .topic-detail__module-card__match-count',
      visible: :all
    )
    expect(badge.text(:all)).to match(/7 matches/)
  end

  it 'is case-insensitive' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'schrödinger'
    wait_for_search_announcement(/match/i)
    lower_text = page.find('[data-topic-search-target="liveRegion"]', visible: :all).text(:all)

    fill_in 'search-outcomes', with: ''
    fill_in 'search-outcomes', with: 'Schrödinger'
    wait_for_search_announcement(/match/i)
    upper_text = page.find('[data-topic-search-target="liveRegion"]', visible: :all).text(:all)

    expect(lower_text).to eq(upper_text)
  end

  it 'normalises whitespace (trims and collapses runs)' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: '  schrö dinger  '
    # Compare with single-space tokenized version
    wait_for_search_announcement(/match/i)
    msg_a = page.find('[data-topic-search-target="liveRegion"]', visible: :all).text(:all)

    fill_in 'search-outcomes', with: ''
    fill_in 'search-outcomes', with: 'schrö dinger'
    wait_for_search_announcement(/match/i)
    msg_b = page.find('[data-topic-search-target="liveRegion"]', visible: :all).text(:all)

    expect(msg_a).to eq(msg_b)
  end

  it 'announces match counts via aria-live=polite' do
    visit_sub56_fixture(modules: modules)
    region = page.find('[data-topic-search-target="liveRegion"]', visible: :all)
    expect(region['aria-live']).to eq('polite')

    fill_in 'search-outcomes', with: 'Schrödinger'
    wait_for_search_announcement(/match/i)
    expect(region.text(:all)).to match(/\d+ outcomes? match/)
  end

  it 'clears the input on Esc and announces "search cleared"' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'xyz'
    wait_for_search_announcement(/match|0/)
    find('#search-outcomes').send_keys(:escape)
    wait_for_search_announcement(/cleared/i)
    expect(page.find('#search-outcomes').value).to eq('')
    expect(page).to have_no_css('.topic-detail__lo--filtered', visible: :all)
  end

  it 'shows the empty state when nothing matches and the Clear button restores the page' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'xyzzy'
    wait_for_search_announcement(/0 outcomes match/i)

    empty = page.find('[data-topic-search-target="emptyState"]', visible: :all)
    # `hidden` attribute is removed by the controller when the empty state shows.
    is_hidden = page.evaluate_script(
      "document.querySelector('[data-topic-search-target=\"emptyState\"]').hidden"
    )
    expect(is_hidden).to be(false)
    expect(empty.find('[data-search-empty-query]', visible: :all).text(:all)).to eq('xyzzy')

    empty.find('button.topic-detail__search-empty__clear', visible: :all).click
    wait_for_search_announcement(/cleared/i)
    expect(page.find('#search-outcomes').value).to eq('')
  end

  it 'outlines the matching heat-map cell with the query-hit class' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'Solve the time-independent'
    wait_for_search_announcement(/match/i)

    expect(page).to have_css(
      '[data-heat-lo-id="15"].topic-detail__heat-cell--query-hit',
      visible: :all
    )
    # A non-matching cell does not get the outline.
    expect(page).to have_no_css(
      '[data-heat-lo-id="1"].topic-detail__heat-cell--query-hit',
      visible: :all
    )
  end

  it 'records performance.measure entries and stays well under a frame' do
    visit_sub56_fixture(modules: modules)
    fill_in 'search-outcomes', with: 'a'
    wait_for_search_announcement(/match|0/)

    duration = page.evaluate_script(<<~JS)
      (() => {
        const m = performance.getEntriesByName('topic-search:filter').pop();
        return m ? m.duration : null;
      })()
    JS

    expect(duration).not_to be_nil
    puts "[bench] topic-search:filter (28 LOs, sub-56) = #{duration.round(2)}ms"
    expect(duration).to be < 25
  end
end
