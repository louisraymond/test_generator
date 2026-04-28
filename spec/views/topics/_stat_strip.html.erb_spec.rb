# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_stat_strip.html.erb', type: :view do
  it 'renders 4 stat cards with the correct labels and counts' do
    topic = create(:topic, name: 'X')
    mod = create(:topic_module, topic: topic, position: 0)
    create(:learning_objective, topic: topic, topic_module: mod, category: 'A', position: 0, category_order: 0)
    create(:learning_objective, topic: topic, topic_module: mod, category: 'B', position: 0, category_order: 1)
    2.times { create(:question, topic: topic, topic_module: mod) }
    topic.reload

    render partial: 'topics/stat_strip', locals: { topic: topic, exam_usage: nil }

    cards = Capybara.string(rendered).all('.topic-detail__stat-card')
    expect(cards.size).to eq(4)
    expect(cards[0]).to have_css('.topic-detail__stat-card__label', text: 'MODULES')
    expect(cards[0]).to have_css('.topic-detail__stat-card__value', text: '1')
    expect(cards[1]).to have_css('.topic-detail__stat-card__label', text: 'CATEGORIES')
    expect(cards[1]).to have_css('.topic-detail__stat-card__value', text: '2')
    expect(cards[2]).to have_css('.topic-detail__stat-card__label', text: 'OUTCOMES')
    expect(cards[2]).to have_css('.topic-detail__stat-card__value', text: '2')
    expect(cards[3]).to have_css('.topic-detail__stat-card__label', text: 'QUESTIONS')
    expect(cards[3]).to have_css('.topic-detail__stat-card__value', text: '2')
    expect(cards[3]['data-stat-target']).to eq('usage')
  end

  it 'pre-renders both coverage + utilization label/value on the 4th card so JS can swap on mode change' do
    topic = create(:topic, name: 'X')
    mod = create(:topic_module, topic: topic, position: 0)
    3.times { create(:question, topic: topic, topic_module: mod) }
    topic.reload

    render partial: 'topics/stat_strip',
           locals: { topic: topic, exam_usage: { 1 => 5, 2 => 7 } }

    cards = Capybara.string(rendered).all('.topic-detail__stat-card')

    # Initial visible state mirrors the heat-map's coverage default —
    # the previous behaviour (showing EXAM USES whenever exam_usage was
    # present) was wrong because it diverged from the active mode.
    expect(cards[3]).to have_css('.topic-detail__stat-card__label', text: 'QUESTIONS')
    expect(cards[3]).to have_css('.topic-detail__stat-card__value', text: '3')

    # Both pairs available as data attributes for topic_heatmap_controller's swap.
    expect(cards[3]['data-stat-target']).to eq('usage')
    expect(cards[3]['data-coverage-label']).to eq('QUESTIONS')
    expect(cards[3]['data-coverage-value']).to eq('3')
    expect(cards[3]['data-utilization-label']).to eq('EXAM USES')
    expect(cards[3]['data-utilization-value']).to eq('12')
  end

  it 'falls back gracefully when exam_usage is nil (data attrs default to 0)' do
    topic = create(:topic, name: 'X')
    render partial: 'topics/stat_strip', locals: { topic: topic, exam_usage: nil }
    cards = Capybara.string(rendered).all('.topic-detail__stat-card')
    expect(cards[3]['data-utilization-value']).to eq('0')
  end
end
