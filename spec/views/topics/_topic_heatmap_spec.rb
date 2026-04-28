# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_topic_heatmap', type: :view do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:mod) { create(:topic_module, topic: topic, name: 'Mechanics', position: 0) }

  def make_lo(category: 'Forces', position: 0, description: 'Describe Newtonian forces')
    create(:learning_objective, topic: topic, topic_module: mod,
                                category: category, description: description,
                                position: position)
  end

  def add_questions(lo, count)
    count.times do |i|
      q = create(:question, topic: topic, source: source,
                            content: "Q-#{lo.id}-#{i}", answer: 'a', points: 1,
                            answer_size: 'short', question_type: 'written')
      QuestionLearningObjective.create!(question: q, learning_objective: lo)
    end
  end

  def render_partial(presenter:, mode: :coverage)
    render partial: 'topics/topic_heatmap', locals: { presenter: presenter, mode: mode }
  end

  context 'with two modules and outcomes' do
    let!(:mod_b) { create(:topic_module, topic: topic, name: 'Waves', position: 1) }
    let!(:lo_a) { make_lo(category: 'Forces', position: 0, description: 'Newton') }
    let!(:lo_b) do
      create(:learning_objective, topic: topic, topic_module: mod_b, position: 0,
                                  category: 'Optics', description: 'Refraction')
    end

    before do
      add_questions(lo_a, 2)
      add_questions(lo_b, 0)
    end

    let(:exam_usage) { { lo_a.id => 4, lo_b.id => 0 } }
    let(:presenter) { TopicHeatmapPresenter.new(topic.reload, exam_usage: exam_usage) }

    it 'renders one .topic-heatmap__row per module' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered.scan(/topic-heatmap__row\b/).length).to be >= 2
    end

    it 'each cell has matching aria-label and title' do
      render_partial(presenter: presenter, mode: :coverage)
      doc = Nokogiri::HTML5.fragment(rendered)
      cells = doc.css('button.topic-heatmap__cell')
      expect(cells).not_to be_empty
      cells.each do |c|
        expect(c['title']).to eq(c['aria-label'])
      end
    end

    it 'coverage title format includes category, description, count and "questions"' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to include('Forces — Newton, 2 questions')
    end

    it 'utilization title format includes count and "exam uses"' do
      render_partial(presenter: presenter, mode: :utilization)
      expect(rendered).to include('Forces — Newton, 4 exam uses')
    end

    it 'truncates long outcome descriptions in title/aria-label/data-lo-description so cells stay small' do
      long = 'A' * 400
      long_lo = create(:learning_objective, topic: topic, topic_module: mod, category: 'Long', description: long, position: 99)
      create(:question_learning_objective, learning_objective: long_lo, question: create(:question, topic: topic))

      render_partial(presenter: TopicHeatmapPresenter.new(topic.reload, exam_usage: {}), mode: :coverage)
      doc = Nokogiri::HTML5.fragment(rendered)
      long_cell = doc.css('button.topic-heatmap__cell').find { |c| c['data-lo-description'].to_s.start_with?('AAAA') }
      expect(long_cell).not_to be_nil, 'expected to find a cell for the long-description LO'

      # Truncated description should be ≤ 80 chars (helper limit) + ellipsis.
      # Originally these fields could carry 400+ chars per cell — at 1000+
      # outcomes that's multi-MB of payload.
      expect(long_cell['data-lo-description'].length).to be <= 81 # 80 + ellipsis
      expect(long_cell['data-lo-description']).to end_with('…')
      expect(long_cell['title'].length).to be < 200
      expect(long_cell['aria-label']).to eq(long_cell['title'])
    end

    it 'section heading reads "Question coverage" by default' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to match(/Question coverage/)
    end

    it 'coverage summary matches "N questions across N outcomes"' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to match(/2 questions\s+across\s+2 outcomes/)
    end

    it 'utilization summary matches "N appearances · N outcomes never used"' do
      render_partial(presenter: presenter, mode: :utilization)
      expect(rendered).to match(/4 appearances\s*·\s*1 outcomes never used/)
    end

    it 'legend caption reads "Questions:" in coverage mode' do
      render_partial(presenter: presenter, mode: :coverage)
      # The utilization span is hidden, but the visible text is "Questions:"
      expect(rendered).to include('Questions:')
    end

    it 'legend caption reads "Exam uses:" in utilization mode' do
      render_partial(presenter: presenter, mode: :utilization)
      expect(rendered).to include('Exam uses:')
    end

    it 'tablist has role and aria-label' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to match(/role="tablist"/)
      expect(rendered).to match(/aria-label="Heat-map mode"/)
    end

    it 'tabs carry role=tab and aria-selected reflecting mode' do
      render_partial(presenter: presenter, mode: :coverage)
      doc = Nokogiri::HTML5.fragment(rendered)
      tabs = doc.css('button[role="tab"]')
      expect(tabs.length).to eq(2)
      coverage_tab = tabs.find { |t| t['data-topic-heatmap-mode-param'] == 'coverage' }
      utilization_tab = tabs.find { |t| t['data-topic-heatmap-mode-param'] == 'utilization' }
      expect(coverage_tab['aria-selected']).to eq('true')
      expect(utilization_tab['aria-selected']).to eq('false')
    end

    it 'legend swatches are aria-hidden' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to match(/topic-heatmap__legend-swatch[^>]*aria-hidden="true"/)
    end
  end

  context 'with a topic that has zero outcomes' do
    let(:empty_topic) { create(:topic) }
    let(:presenter) { TopicHeatmapPresenter.new(empty_topic) }

    it 'renders nothing visible (no controller mount)' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).not_to include('data-controller="topic-heatmap"')
    end
  end

  context 'with a module that has zero outcomes' do
    let!(:lo_a) { make_lo(position: 0) }
    let!(:mod_empty) { create(:topic_module, topic: topic, name: 'Empty', position: 1) }

    before { add_questions(lo_a, 1) }

    let(:presenter) { TopicHeatmapPresenter.new(topic.reload) }

    it 'renders the row label and an empty placeholder' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to include('Empty')
      expect(rendered).to include('topic-heatmap__row-empty')
      expect(rendered).to include('—')
    end
  end

  context 'cell with count == 100' do
    let!(:lo) { make_lo(position: 0, description: 'Big LO') }

    before { add_questions(lo, 100) }

    let(:presenter) { TopicHeatmapPresenter.new(topic.reload) }

    it 'displays "99+" but aria-label has the exact integer' do
      render_partial(presenter: presenter, mode: :coverage)
      expect(rendered).to include('>99+<')
      expect(rendered).to match(/aria-label="[^"]*100 questions"/)
    end
  end
end
