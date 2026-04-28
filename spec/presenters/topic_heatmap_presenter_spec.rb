# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopicHeatmapPresenter do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }

  def make_lo(mod, position:, category: 'Cat A')
    create(:learning_objective, topic: topic, topic_module: mod,
                                category: category, position: position)
  end

  def add_questions(lo, count)
    count.times do |i|
      q = create(:question, topic: topic, source: source,
                            content: "Q-#{lo.id}-#{i}",
                            answer: 'a', points: 1, answer_size: 'short',
                            question_type: 'written')
      QuestionLearningObjective.create!(question: q, learning_objective: lo)
    end
  end

  describe '#rows' do
    context 'with two modules each containing outcomes' do
      let!(:mod_a) { create(:topic_module, topic: topic, name: 'Module A', position: 0) }
      let!(:mod_b) { create(:topic_module, topic: topic, name: 'Module B', position: 1) }
      let!(:lo_a1) { make_lo(mod_a, position: 0) }
      let!(:lo_a2) { make_lo(mod_a, position: 1) }
      let!(:lo_b1) { make_lo(mod_b, position: 0) }

      before do
        add_questions(lo_a1, 2)
        add_questions(lo_a2, 5)
        add_questions(lo_b1, 0)
      end

      let(:exam_usage) { { lo_a1.id => 3, lo_a2.id => 0, lo_b1.id => 7 } }
      subject(:presenter) { described_class.new(topic.reload, exam_usage: exam_usage) }

      it 'returns one row per topic module in position order' do
        expect(presenter.rows.length).to eq(2)
        expect(presenter.rows.map { |r| r.topic_module.name }).to eq(['Module A', 'Module B'])
      end

      it 'each row has cells, totals, and topic_module' do
        row = presenter.rows.first
        expect(row).to respond_to(:topic_module, :cells, :totals)
      end

      it 'cells preserve LO position order' do
        cells = presenter.rows.first.cells
        expect(cells.map { |c| c.lo.id }).to eq([lo_a1.id, lo_a2.id])
      end

      it 'cell coverage_count equals lo.questions.size' do
        cells = presenter.rows.first.cells
        expect(cells[0].coverage_count).to eq(2)
        expect(cells[1].coverage_count).to eq(5)
      end

      it 'cell utilization_count comes from exam_usage hash' do
        cells = presenter.rows.first.cells
        expect(cells[0].utilization_count).to eq(3)
        expect(cells[1].utilization_count).to eq(0)
      end

      it 'utilization_count defaults to 0 for missing keys' do
        unknown_lo = make_lo(mod_b, position: 1)
        new_presenter = described_class.new(topic.reload, exam_usage: exam_usage)
        cells = new_presenter.rows.last.cells
        expect(cells.find { |c| c.lo.id == unknown_lo.id }.utilization_count).to eq(0)
      end

      it 'row totals sums LO count, question count, and uses count' do
        row = presenter.rows.first
        expect(row.totals[:lo_count]).to eq(2)
        expect(row.totals[:question_count]).to eq(7)
        expect(row.totals[:uses_count]).to eq(3)
      end
    end

    context 'with no learning outcomes' do
      it 'returns an empty array' do
        empty_topic = create(:topic)
        expect(described_class.new(empty_topic).rows).to eq([])
      end
    end

    context 'with a module that has zero outcomes' do
      let!(:mod_empty) { create(:topic_module, topic: topic, name: 'Empty', position: 0) }
      let!(:mod_full)  { create(:topic_module, topic: topic, name: 'Full', position: 1) }
      let!(:lo) { make_lo(mod_full, position: 0) }

      it 'still renders the row with empty cells and zero lo_count' do
        rows = described_class.new(topic.reload).rows
        empty_row = rows.find { |r| r.topic_module.name == 'Empty' }
        expect(empty_row.cells).to eq([])
        expect(empty_row.totals[:lo_count]).to eq(0)
        expect(empty_row).to be_empty
      end
    end
  end

  describe 'Cell display + bucket' do
    let(:lo) { create(:learning_objective, topic: topic) }
    let(:cell) do
      described_class::Cell.new(
        lo: lo, coverage_count: 100, utilization_count: 6
      )
    end

    it 'clamps display > 99 to "99+" while preserving the int' do
      expect(cell.display(:coverage)).to eq('99+')
      expect(cell.coverage_count).to eq(100)
    end

    it 'displays utilization_count as-is when below clamp' do
      expect(cell.display(:utilization)).to eq('6')
    end

    it 'computes bucket per mode' do
      expect(cell.bucket(:coverage)).to eq(4)      # 100 -> 7+
      expect(cell.bucket(:utilization)).to eq(3)   # 6 -> 5..6
    end

    it 'returns 0 bucket for missing/zero data' do
      zero = described_class::Cell.new(lo: lo, coverage_count: 0, utilization_count: 0)
      expect(zero.bucket(:coverage)).to eq(0)
      expect(zero.bucket(:utilization)).to eq(0)
    end
  end

  describe '#summary' do
    let!(:mod) { create(:topic_module, topic: topic, position: 0) }
    let!(:lo1) { make_lo(mod, position: 0) }
    let!(:lo2) { make_lo(mod, position: 1) }

    before do
      add_questions(lo1, 2)
      add_questions(lo2, 0)
    end

    let(:presenter) do
      described_class.new(topic.reload, exam_usage: { lo1.id => 4, lo2.id => 0 })
    end

    it 'returns coverage summary with counts' do
      summary = presenter.summary(:coverage)
      expect(summary[:question_count]).to eq(2)
      expect(summary[:outcome_count]).to eq(2)
    end

    it 'returns utilization summary with appearances and zero count' do
      summary = presenter.summary(:utilization)
      expect(summary[:appearances]).to eq(4)
      expect(summary[:zero_count]).to eq(1)
    end
  end
end
