# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopicDetailHelper, type: :helper do
  describe '#module_ministats' do
    it 'formats categories, learning objectives, and questions' do
      topic = create(:topic)
      mod = create(:topic_module, topic: topic, position: 0)
      create(:learning_objective, topic: topic, topic_module: mod, category: 'A', position: 0, category_order: 0)
      create(:learning_objective, topic: topic, topic_module: mod, category: 'A', position: 1, category_order: 0)
      create(:learning_objective, topic: topic, topic_module: mod, category: 'B', position: 0, category_order: 1)
      3.times { create(:question, topic: topic, topic_module: mod) }
      mod.reload
      expect(helper.module_ministats(mod)).to eq('2 cat · 3 LO · 3 Q')
    end

    it 'returns zero counts (never nil) when module is empty' do
      topic = create(:topic)
      mod = create(:topic_module, topic: topic, position: 0)
      expect(helper.module_ministats(mod)).to eq('0 cat · 0 LO · 0 Q')
    end
  end

  describe '#module_index_label' do
    it 'pads single digits to two characters' do
      expect(helper.module_index_label(1)).to eq('01')
    end

    it 'pads 9 to 09' do
      expect(helper.module_index_label(9)).to eq('09')
    end

    it 'leaves 10 unchanged' do
      expect(helper.module_index_label(10)).to eq('10')
    end

    it 'leaves 99 unchanged' do
      expect(helper.module_index_label(99)).to eq('99')
    end

    it 'does not pad past two digits' do
      expect(helper.module_index_label(100)).to eq('100')
    end
  end

  describe '#topic_stat' do
    it 'returns a hash with label and value' do
      result = helper.topic_stat(label: 'MODULES', value: 4)
      expect(result[:label]).to eq('MODULES')
      expect(result[:value]).to eq(4)
    end

    it 'omits the html_data stat_target unless mode: :usage is passed' do
      result = helper.topic_stat(label: 'MODULES', value: 4)
      expect(result[:html_data]).to eq({})
    end

    it 'adds a stat_target html_data key when mode is :usage' do
      result = helper.topic_stat(label: 'EXAM USES', value: 12, mode: :usage)
      expect(result[:html_data]).to eq(stat_target: 'usage')
    end
  end

  describe '#topic_detail_v2?' do
    it 'returns true when params[:v2] is "1"' do
      expect(helper.topic_detail_v2?(ActionController::Parameters.new(v2: '1'))).to be(true)
    end

    it 'returns false when params[:v2] is missing' do
      expect(helper.topic_detail_v2?(ActionController::Parameters.new)).to be(false)
    end

    it 'returns true when ENV TOPIC_DETAIL_V2 is set to true' do
      original = ENV['TOPIC_DETAIL_V2']
      ENV['TOPIC_DETAIL_V2'] = 'true'
      expect(helper.topic_detail_v2?(ActionController::Parameters.new)).to be(true)
    ensure
      ENV['TOPIC_DETAIL_V2'] = original
    end
  end

  describe '#topic_v2_enabled_for?' do
    it 'mirrors topic_detail_v2? for now and accepts a request-like object' do
      req = double('Request', params: ActionController::Parameters.new(v2: '1'))
      expect(helper.topic_v2_enabled_for?(req)).to be(true)
    end

    it 'returns false for a request without v2 param' do
      req = double('Request', params: ActionController::Parameters.new)
      expect(helper.topic_v2_enabled_for?(req)).to be(false)
    end
  end

  describe '#heat_color' do
    it 'returns heat-0 class for zero count' do
      expect(helper.heat_color(0)).to eq('topic-heatmap__cell--heat-0')
    end

    it 'returns heat-1 class for 1..2' do
      expect(helper.heat_color(1)).to eq('topic-heatmap__cell--heat-1')
      expect(helper.heat_color(2)).to eq('topic-heatmap__cell--heat-1')
    end

    it 'returns heat-2 class for 3..4' do
      expect(helper.heat_color(3)).to eq('topic-heatmap__cell--heat-2')
      expect(helper.heat_color(4)).to eq('topic-heatmap__cell--heat-2')
    end

    it 'returns heat-3 class for 5..6' do
      expect(helper.heat_color(5)).to eq('topic-heatmap__cell--heat-3')
      expect(helper.heat_color(6)).to eq('topic-heatmap__cell--heat-3')
    end

    it 'returns heat-4 class for 7+' do
      expect(helper.heat_color(7)).to eq('topic-heatmap__cell--heat-4')
      expect(helper.heat_color(99)).to eq('topic-heatmap__cell--heat-4')
      expect(helper.heat_color(150)).to eq('topic-heatmap__cell--heat-4')
    end

    it 'clamps negative counts to bucket 0 defensively' do
      expect(helper.heat_color(-1)).to eq('topic-heatmap__cell--heat-0')
    end
  end

  describe '#heat_text' do
    it 'returns the integer as a string under the clamp' do
      expect(helper.heat_text(2, mode: :coverage)).to eq('2')
    end

    it 'returns "99+" for counts above the clamp' do
      expect(helper.heat_text(150, mode: :coverage)).to eq('99+')
    end

    it 'returns "0" in utilization mode (never blank)' do
      expect(helper.heat_text(0, mode: :utilization)).to eq('0')
    end
  end

  describe '#heat_units' do
    it 'returns "questions" for coverage mode' do
      expect(helper.heat_units(:coverage)).to eq('questions')
    end

    it 'returns "exam uses" for utilization mode' do
      expect(helper.heat_units(:utilization)).to eq('exam uses')
    end

    it 'accepts string mode values' do
      expect(helper.heat_units('utilization')).to eq('exam uses')
      expect(helper.heat_units('coverage')).to eq('questions')
    end
  end

  describe '#module_collapsed_default?' do
    let(:mod) { build_stubbed(:topic_module) }

    it 'returns false for the first module (idx 0)' do
      expect(helper.module_collapsed_default?(mod, 0)).to be false
    end

    it 'returns true for idx >= 1' do
      expect(helper.module_collapsed_default?(mod, 1)).to be true
      expect(helper.module_collapsed_default?(mod, 5)).to be true
    end
  end

  describe '#category_grouping' do
    let(:topic) { create(:topic) }
    let(:mod)   { create(:topic_module, topic: topic) }

    it 'groups LOs by category, sorted alphabetically by category' do
      lo_b = create(:learning_objective, topic: topic, topic_module: mod, category: 'Beta',  position: 0)
      lo_a = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 0)
      lo_c = create(:learning_objective, topic: topic, topic_module: mod, category: 'Gamma', position: 0)

      mod.reload
      grouping = helper.category_grouping(mod)
      categories = grouping.map(&:first)
      expect(categories).to eq(%w[Alpha Beta Gamma])
      # contains references back
      _ = [lo_a, lo_b, lo_c]
    end

    it 'preserves position order within a category' do
      first  = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 0, description: 'first')
      second = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 1, description: 'second')
      third  = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 2, description: 'third')
      mod.reload

      grouping = helper.category_grouping(mod)
      _, los = grouping.first
      expect(los.map(&:description)).to eq(%w[first second third])
      _ = [first, second, third]
    end
  end

  describe '#lo_chip_html' do
    let(:topic) { create(:topic) }
    let(:lo)    { create(:learning_objective, topic: topic) }

    def render_chip(lo, exam_usage: {}, mode: 'questions')
      Capybara.string(helper.lo_chip_html(lo, exam_usage: exam_usage, mode: mode))
    end

    it 'renders <span class="topic-detail__chip" data-questions data-usage>' do
      html = render_chip(lo)
      chip = html.find('.topic-detail__chip')
      expect(chip['data-questions']).to eq('0')
      expect(chip['data-usage']).to eq('0')
    end

    it 'applies bucket-zero (dashed) class when questionCount == 0' do
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--zero')
    end

    it 'applies bucket-1 colour for n == 1' do
      create(:question, topic: topic, learning_objectives: [lo])
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b1')
    end

    it 'applies bucket-2 colour for n == 2' do
      2.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b2')
    end

    it 'applies bucket-3 colour for n == 4' do
      4.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b3')
    end

    it 'applies bucket-4 colour for n == 7' do
      7.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b4')
    end

    it 'sets aria-label "{n} questions" in questions mode' do
      3.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      chip = render_chip(lo).find('.topic-detail__chip')
      expect(chip['aria-label']).to eq('3 questions')
    end

    it 'embeds data-usage attribute pulled from the exam_usage map' do
      chip = render_chip(lo, exam_usage: { lo.id => 4 }).find('.topic-detail__chip')
      expect(chip['data-usage']).to eq('4')
    end

    it 'shows usage text "{n}x" in usage mode and updates aria-label accordingly' do
      chip = render_chip(lo, exam_usage: { lo.id => 5 }, mode: 'usage').find('.topic-detail__chip')
      expect(chip.text).to eq('5x')
      expect(chip['aria-label']).to eq('5 exam uses')
    end
  end

  # === sub-56: search/views ===
  context 'sub-56 search/views helpers' do
    # Fixture: 1 topic, 2 modules, outcomes spread across 3 categories.
    let(:topic) { create(:topic, name: 'Sub-56 Helper Topic') }
    let!(:mod_a) { create(:topic_module, topic: topic, name: 'Module Alpha', position: 0) }
    let!(:mod_b) { create(:topic_module, topic: topic, name: 'Module Beta',  position: 1) }

    let!(:lo_a1) do
      create(:learning_objective,
             topic: topic, topic_module: mod_a,
             category: 'Quanta',  category_order: 0, position: 0,
             description: 'Explain Schrödinger equation')
    end
    let!(:lo_a2) do
      create(:learning_objective,
             topic: topic, topic_module: mod_a,
             category: 'Heat',    category_order: 1, position: 0,
             description: 'Define entropy')
    end
    let!(:lo_b1) do
      create(:learning_objective,
             topic: topic, topic_module: mod_b,
             category: 'Quanta',  category_order: 0, position: 1,
             description: 'Compute eigenvalues')
    end
    let!(:lo_b2) do
      create(:learning_objective,
             topic: topic, topic_module: mod_b,
             category: 'Atoms',   category_order: 2, position: 0,
             description: 'Describe Bohr model')
    end

    describe '#topic_outcomes_grouped_by_category' do
      subject(:grouped) { helper.topic_outcomes_grouped_by_category(topic) }

      it 'groups outcomes by category sorted alphabetically (case-insensitive)' do
        categories = grouped.map(&:first)
        expect(categories).to eq(%w[Atoms Heat Quanta])
      end

      it 'tags every outcome with its source-module index (1-based)' do
        quanta_rows = grouped.find { |cat, _| cat == 'Quanta' }.last
        module_indexes = quanta_rows.map { |row| row[:module_idx] }
        expect(module_indexes).to contain_exactly(1, 2)
      end

      it 'preserves the LO record itself in each row' do
        atoms_rows = grouped.find { |cat, _| cat == 'Atoms' }.last
        expect(atoms_rows.first[:lo]).to eq(lo_b2)
      end

      it 'returns an Array of [category, rows] pairs (Enumerable contract)' do
        expect(grouped).to be_an(Array)
        expect(grouped.first).to be_an(Array)
        expect(grouped.first.size).to eq(2)
      end
    end

    describe '#topic_outcomes_flat' do
      it 'defaults to topic order (category_order, position, id)' do
        flat = helper.topic_outcomes_flat(topic)
        expect(flat.map { |r| r[:lo] }).to eq([lo_a1, lo_b1, lo_a2, lo_b2])
      end

      it 'tags rows with module_idx and topic_order' do
        flat = helper.topic_outcomes_flat(topic)
        first = flat.first
        expect(first).to include(:lo, :module_idx, :topic_order)
        expect(first[:topic_order]).to eq(0)
        expect(first[:module_idx]).to be_in([1, 2])
      end

      it 'sorts by alpha when requested' do
        flat = helper.topic_outcomes_flat(topic, sort: :alpha)
        descriptions = flat.map { |r| r[:lo].description.downcase }
        expect(descriptions).to eq(descriptions.sort)
      end

      it 'sorts by Nq descending and ascending' do
        # Give one LO three questions, another one — leaves the rest at zero.
        create_list(:question, 3, topic: topic).each do |q|
          q.learning_objectives << lo_a1
        end
        q_one = create(:question, topic: topic)
        q_one.learning_objectives << lo_b2

        desc = helper.topic_outcomes_flat(topic, sort: :nq_desc)
        expect(desc.first[:lo]).to eq(lo_a1)
        expect(desc.first[:lo].questions.size).to eq(3)

        asc = helper.topic_outcomes_flat(topic, sort: :nq_asc)
        # First LO in asc has size 0; lo_a1 (size 3) is last
        expect(asc.last[:lo]).to eq(lo_a1)
      end
    end
  end
end
