# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_view_outcomes_flat', type: :view do
  let(:topic) { create(:topic, name: 'Quantum Physics') }
  let!(:mod_a) { create(:topic_module, topic: topic, name: 'Foundations', position: 0) }
  let!(:lo1) do
    create(:learning_objective,
           topic: topic, topic_module: mod_a,
           category: 'Quanta', category_order: 0, position: 0,
           description: 'Explain the Schrödinger equation')
  end
  let!(:lo2) do
    create(:learning_objective,
           topic: topic, topic_module: mod_a,
           category: 'Quanta', category_order: 0, position: 1,
           description: 'Compute eigenvalues')
  end

  before { view.extend(TopicDetailHelper) }

  def render_partial
    render partial: 'topics/view_outcomes_flat', locals: { topic: topic }
  end

  it 'renders the pane hidden by default with data-view="outcomes"' do
    render_partial
    expect(rendered).to have_css(
      'section.topic-detail__view--outcomes[data-topic-view-target="pane"][data-view="outcomes"][hidden]',
      visible: :all
    )
  end

  it 'renders a real <select> sort dropdown with the four options' do
    render_partial
    options = Capybara.string(rendered).all('select#outcomes-sort option', visible: :all).map { |o| o['value'] }
    expect(options).to eq(%w[topic_order nq_desc nq_asc alpha])
  end

  it 'wires the select to topic-view#selectSort' do
    render_partial
    expect(rendered).to have_css(
      'select#outcomes-sort[data-action="change->topic-view#selectSort"]',
      visible: :all
    )
  end

  it 'has a visually-hidden label so the select is accessible' do
    render_partial
    expect(rendered).to have_css(
      'label[for="outcomes-sort"].topic-detail__visually-hidden',
      text: /sort/i, visible: :all
    )
  end

  it 'renders one row per outcome with data-* attributes for client-side sort' do
    render_partial
    rows = Capybara.string(rendered).all('li[data-outcome-row]', visible: :all)
    expect(rows.size).to eq(2)
    expect(rows.map { |r| r['data-lo-id'] }).to contain_exactly(lo1.id.to_s, lo2.id.to_s)
    expect(rows.first['data-nq']).to eq('0')
    expect(rows.first['data-topic-order']).to eq('0')
  end

  it 'tags each row with the source module M-idx' do
    render_partial
    tags = Capybara.string(rendered)
                   .all('li[data-outcome-row] .topic-detail__m-tag', visible: :all)
                   .map { |n| n.text(:all) }
    expect(tags).to all(eq('M01'))
  end
end
