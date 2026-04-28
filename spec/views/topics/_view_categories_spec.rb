# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_view_categories', type: :view do
  let(:topic) { create(:topic, name: 'Quantum Physics') }
  let!(:mod_a) { create(:topic_module, topic: topic, name: 'Foundations', position: 0) }
  let!(:mod_b) { create(:topic_module, topic: topic, name: 'Atoms',       position: 1) }

  let!(:lo1) do
    create(:learning_objective,
           topic: topic, topic_module: mod_a,
           category: 'Quanta', category_order: 0, position: 0,
           description: 'Explain the Schrödinger equation')
  end
  let!(:lo2) do
    create(:learning_objective,
           topic: topic, topic_module: mod_b,
           category: 'Quanta', category_order: 0, position: 1,
           description: 'Compute eigenvalues')
  end
  let!(:lo3) do
    create(:learning_objective,
           topic: topic, topic_module: mod_b,
           category: 'Spectra', category_order: 1, position: 0,
           description: 'Read an emission spectrum')
  end

  before do
    # The view uses helpers from TopicDetailHelper.
    view.extend(TopicDetailHelper)
  end

  def render_partial
    render partial: 'topics/view_categories', locals: { topic: topic }
  end

  it 'renders the pane with hidden, data-view, and Stimulus target attributes' do
    render_partial
    expect(rendered).to have_css(
      'section.topic-detail__view--categories[data-topic-view-target="pane"][data-view="categories"][hidden]',
      visible: :all
    )
  end

  it 'groups outcomes alphabetically by category, each with data-cat-name' do
    render_partial
    sections = Capybara.string(rendered).all('article.topic-detail__category-section', visible: :all)
    expect(sections.map { |s| s['data-cat-name'] }).to eq(%w[Quanta Spectra])
  end

  it 'tags each outcome with the source-module M-idx' do
    render_partial
    rows = Capybara.string(rendered).all('li.topic-detail__lo-row', visible: :all)
    tags = rows.map { |r| r.find('.topic-detail__m-tag', visible: :all).text(:all) }
    expect(tags).to include('M01', 'M02')
  end

  it 'exposes data-lo-id and data-lo-text on every row for the search filter' do
    render_partial
    expect(rendered).to have_css(
      "li.topic-detail__lo-row[data-lo-id='#{lo1.id}'][data-lo-text='Explain the Schrödinger equation']",
      visible: :all
    )
  end

  it 'shows an Nq chip per outcome' do
    create(:question, topic: topic).learning_objectives << lo1
    render_partial
    expect(rendered).to have_css('span.topic-detail__nq-chip', text: '1', visible: :all)
  end

  it 'links to + question for each outcome' do
    render_partial
    expect(rendered).to have_link('+ question',
                                  href: new_question_path(learning_objective_id: lo1.id),
                                  visible: :all)
  end
end
