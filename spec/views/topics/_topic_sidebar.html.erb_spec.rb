# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_topic_sidebar.html.erb', type: :view do
  it 'renders module list with index, name, and ministats for a topic with modules' do
    topic = create(:topic, name: 'Thermal Physics',
                            epigraph_quote: 'Heat...', epigraph_attribution: 'Kelvin')
    4.times do |i|
      create(:topic_module, topic: topic, name: "Module #{i}", position: i)
    end
    topic.reload

    render partial: 'topics/topic_sidebar', locals: { topic: topic }

    expect(rendered).to have_css('aside.topic-detail-v2__sidebar')
    expect(rendered).to have_css('h1.topic-detail__sidebar-title', text: 'Thermal Physics')
    expect(rendered).to have_css('.topic-detail__sidebar-epigraph', text: /Heat/)
    expect(rendered).to have_css('.topic-detail__sidebar-epigraph cite', text: /Kelvin/)
    expect(rendered).to have_css('nav[aria-label="Topic outline"] ul.topic-detail__sidebar-list li', count: 4)
    expect(rendered).to have_css('.topic-detail__sidebar-index', text: '01')
    expect(rendered).to have_css('.topic-detail__sidebar-index', text: '04')
  end

  it 'renders an empty-state CTA when topic has no modules' do
    topic = create(:topic, name: 'Empty')
    render partial: 'topics/topic_sidebar', locals: { topic: topic }

    expect(rendered).to have_css('.topic-detail__sidebar-modules-header', text: /MODULES · 0/)
    expect(rendered).to have_button('+ NEW MODULE')
    expect(rendered).not_to have_css('ul.topic-detail__sidebar-list')
  end

  it 'omits the epigraph block when epigraph_quote is blank' do
    topic = create(:topic, name: 'No Quote', epigraph_quote: nil)
    render partial: 'topics/topic_sidebar', locals: { topic: topic }
    expect(rendered).not_to have_css('.topic-detail__sidebar-epigraph')
  end

  it 'wires the view-switcher pills with Stimulus targets' do
    topic = create(:topic, name: 'X')
    render partial: 'topics/topic_sidebar', locals: { topic: topic }
    expect(rendered).to have_css('button[data-topic-sidebar-target="viewPill"][data-view="modules"]')
    expect(rendered).to have_css('button[data-topic-sidebar-target="viewPill"][data-view="by_category"]')
    expect(rendered).to have_css('button[data-topic-sidebar-target="viewPill"][data-view="outcomes_only"]')
  end
end
