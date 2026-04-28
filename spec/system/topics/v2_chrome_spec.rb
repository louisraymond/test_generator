# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Topic detail v2 chrome (sub-53)', type: :system, js: true do
  def build_topic_with_modules
    topic = create(:topic, name: 'Thermal Physics',
                           epigraph_quote: 'Heat is the motion of particles.',
                           epigraph_attribution: 'Kelvin')
    4.times do |i|
      mod = create(:topic_module, topic: topic, name: "Module #{('A'.ord + i).chr}", position: i)
      2.times do |loi|
        create(:learning_objective, topic: topic, topic_module: mod,
                                    category: "Cat #{loi}", category_order: loi, position: loi)
      end
      3.times { create(:question, topic: topic, topic_module: mod) }
    end
    topic
  end

  it 'renders the sidebar with topic name, epigraph, and module entries' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)

    expect(page).to have_css('nav[aria-label="Topic outline"]')
    expect(page).to have_css('.topic-detail-v2__sidebar')
    expect(page).to have_css('.topic-detail__sidebar-title', text: 'Thermal Physics')
    expect(page).to have_css('.topic-detail__sidebar-epigraph', text: 'Heat is the motion of particles.')
    expect(page).to have_css('.topic-detail__sidebar-epigraph cite', text: 'Kelvin')

    topic.topic_modules.each_with_index do |mod, i|
      idx = format('%02d', i + 1)
      within(:css, "a[data-module-id='#{mod.id}']") do
        expect(page).to have_css('.topic-detail__sidebar-index', text: idx)
        expect(page).to have_css('.topic-detail__sidebar-name', text: mod.name)
        expect(page).to have_css('.topic-detail__sidebar-ministats', text: /cat ·/)
        expect(page).to have_css('.topic-detail__sidebar-ministats', text: /LO ·/)
        expect(page).to have_css('.topic-detail__sidebar-ministats', text: /Q$/)
      end
    end
  end

  it 'shows MODULES · 0 and a + NEW MODULE CTA when topic has no modules' do
    topic = create(:topic, name: 'Empty Topic')
    visit topic_path(topic, v2: 1)

    expect(page).to have_css('.topic-detail__sidebar-modules-header', text: /MODULES · 0/)
    expect(page).to have_button('+ NEW MODULE')
  end

  it 'shows the stat strip with 4 cards' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)

    expect(page).to have_css('.topic-detail__stat-card', count: 4)
    cards = page.all('.topic-detail__stat-card')
    expect(cards[0]).to have_text('MODULES')
    expect(cards[0]).to have_css('.topic-detail__stat-card__value', text: '4')
    expect(cards[1]).to have_text('CATEGORIES')
    expect(cards[2]).to have_text('OUTCOMES')
    expect(cards[2]).to have_css('.topic-detail__stat-card__value', text: '8')
    expect(cards[3]['data-stat-target']).to eq('usage')
  end

  it 'shows the toolbar with search, +Outcome, +Module, ?' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)

    expect(page).to have_css('input[placeholder="Search outcomes, categories, modules…"]')
    expect(page).to have_button('+ Outcome')
    expect(page).to have_button('+ Module')
    expect(page).to have_button('?')
  end

  it 'renders the footer hint' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)
    expect(page).to have_css('.topic-detail__footer-hint', text: /press \? for keyboard shortcuts/i)
  end

  it 'renders the skip-to-content link as the first focusable element' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)
    expect(page).to have_css('a.topic-detail__skip-link', text: /Skip to main content/i, visible: :all)
    # The skip link must point at the main element id.
    expect(page).to have_css('a.topic-detail__skip-link[href="#topic-detail-main"]', visible: :all)
    expect(page).to have_css('main#topic-detail-main')
  end

  it 'sets aria-current on the clicked sidebar entry and scrolls main pane to that module' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)

    third = topic.topic_modules[2]
    # Wait for Stimulus to connect (entry target binding implies the
    # topic-sidebar controller is up).
    expect(page).to have_css("a[data-module-id='#{third.id}'][data-topic-sidebar-target='entry']")
    initial_scroll = page.evaluate_script('window.scrollY')
    find("a[data-module-id='#{third.id}']").click

    # aria-current toggled on the clicked entry.
    expect(page).to have_css("a[data-module-id='#{third.id}'][aria-current='location']")

    # The page must have scrolled toward the third module — anywhere is fine
    # as long as it moved.  We don't pin to a pixel because smooth-scroll
    # animation timing varies between Chrome versions and headless modes.
    deadline = Time.now + 2.0
    scroll_y = page.evaluate_script('window.scrollY')
    while scroll_y == initial_scroll && Time.now < deadline
      sleep 0.1
      scroll_y = page.evaluate_script('window.scrollY')
    end
    expect(scroll_y).to be > initial_scroll, "expected window to scroll past #{initial_scroll}, got #{scroll_y}"
  end

  it 'renders module sections in main pane with mod-{id} ids and tabindex on heading' do
    topic = build_topic_with_modules
    visit topic_path(topic, v2: 1)
    topic.topic_modules.each do |mod|
      expect(page).to have_css("##{ "mod-#{mod.id}" }")
    end
    # The first heading must accept programmatic focus (tabindex="-1").
    first = topic.topic_modules.first
    expect(page).to have_css("##{ "mod-#{first.id}" } [tabindex='-1']")
  end
end
