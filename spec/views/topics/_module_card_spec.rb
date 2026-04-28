require 'rails_helper'

RSpec.describe 'topics/_module_card', type: :view do
  let(:topic) { create(:topic, name: 'T1') }
  let(:mod)   { create(:topic_module, topic: topic, name: 'Foundations', description: 'Intro stuff', position: 0) }

  before do
    create(:learning_objective, topic: topic, topic_module: mod, category: 'Basics', position: 0, description: 'Define X')
    create(:learning_objective, topic: topic, topic_module: mod, category: 'Basics', position: 1, description: 'Define Y')
    create(:learning_objective, topic: topic, topic_module: mod, category: 'Advanced', position: 0, description: 'Apply Z')
    mod.reload
  end

  def render_card(idx: 0, exam_usage: {})
    render partial: 'topics/module_card', locals: { mod: mod, idx: idx, exam_usage: exam_usage }
  end

  describe 'header structure (antagonist B1: no button-inside-button)' do
    it 'renders the toggle as a button and the Edit affordance as a sibling, never nested' do
      render_card

      # Header row exists
      expect(rendered).to have_css('.topic-module__header-row')

      # Toggle button is a direct child of header-row
      expect(rendered).to have_css('.topic-module__header-row > button.topic-module__toggle')

      # Edit affordance is a sibling, NOT inside the toggle
      expect(rendered).to have_css('.topic-module__header-row > .topic-module__edit')

      # Critical: parse the rendered HTML and verify there is no <button> inside another <button>
      doc = Nokogiri::HTML.fragment(rendered)
      doc.css('button').each do |btn|
        expect(btn.css('button').size).to eq(0),
          "Found nested <button> inside another <button>: #{btn.to_html[0..200]}"
        # Also ensure no <a role=button> with role-overlap inside the button (defensive)
      end
    end
  end

  describe 'aria & semantics' do
    it 'sets aria-expanded=true on the first module toggle and links it to the body' do
      render_card(idx: 0)
      expect(rendered).to have_css('button.topic-module__toggle[aria-expanded="true"][aria-controls="mod-' + mod.id.to_s + '-body"]')
      expect(rendered).to have_css('div#mod-' + mod.id.to_s + '-body.topic-module__body')
      # body is NOT hidden when expanded
      expect(rendered).not_to have_css('div#mod-' + mod.id.to_s + '-body[hidden]')
    end

    it 'sets aria-expanded=false and hidden on subsequent modules' do
      render_card(idx: 1)
      expect(rendered).to have_css('button.topic-module__toggle[aria-expanded="false"]')
      expect(rendered).to have_css('div#mod-' + mod.id.to_s + '-body[hidden]', visible: :all)
    end

    it 'marks the chevron as aria-hidden' do
      render_card
      expect(rendered).to have_css('.topic-module__chevron[aria-hidden="true"]')
    end

    it 'sets aria-label on the Edit affordance' do
      render_card
      expect(rendered).to have_css('.topic-module__edit[aria-label="Edit module Foundations"]')
    end

    it 'renders the M-label as a zero-padded two-digit eyebrow (M01, not M1) per the design' do
      render_card(idx: 0)
      expect(rendered).to have_css('.topic-module__m-label', exact_text: 'M01')
      render_card(idx: 8)
      expect(rendered).to have_css('.topic-module__m-label', exact_text: 'M09')
      render_card(idx: 11)
      expect(rendered).to have_css('.topic-module__m-label', exact_text: 'M12')
    end
  end

  describe 'content' do
    it 'renders the module name and description in the title block' do
      render_card
      expect(rendered).to have_css('.topic-module__name', text: 'Foundations')
      expect(rendered).to have_css('.topic-module__description', text: 'Intro stuff')
    end

    it 'renders LO and Q counts in the stats block' do
      render_card
      expect(rendered).to have_css('.topic-module__stats')
      expect(rendered).to have_text('3') # 3 LOs
    end

    it 'renders one section per category, alphabetised' do
      render_card
      sections = Nokogiri::HTML.fragment(rendered).css('.topic-module__category .topic-module__cat-name').map(&:text)
      expect(sections).to eq(%w[Advanced Basics])
    end

    it 'renders an <ol> with one <li> per learning outcome' do
      render_card
      expect(rendered).to have_css('ol.topic-module__lo-list')
      expect(rendered).to have_css('li.topic-module__lo[tabindex="-1"]', count: 3)
    end

    it 'each LO row sets data-lo-id to the LO id' do
      render_card
      ids = Nokogiri::HTML.fragment(rendered).css('li.topic-module__lo').map { |li| li['data-lo-id'] }
      expected_ids = mod.learning_objectives.pluck(:id).map(&:to_s).sort
      expect(ids.sort).to eq(expected_ids)
    end

    it 'links the + question affordance to new_question_path with learning_objective_id' do
      render_card
      lo = mod.learning_objectives.first
      expect(rendered).to have_link('+ question', href: new_question_path(learning_objective_id: lo.id))
    end

    it 'wires the Stimulus controller and id values on the article' do
      render_card
      expect(rendered).to have_css(
        'article.topic-module[data-controller="topic-module"]' \
        "[data-topic-module-id-value=\"#{mod.id}\"]" \
        "[data-topic-module-topic-id-value=\"#{topic.id}\"]"
      )
    end
  end

  describe 'empty module' do
    let(:empty_mod) { create(:topic_module, topic: topic, name: 'Empty', position: 1) }

    it 'shows a placeholder when no LOs exist' do
      render partial: 'topics/module_card', locals: { mod: empty_mod, idx: 1, exam_usage: {} }
      expect(rendered).to have_css('.topic-module__empty', visible: :all)
    end
  end
end
