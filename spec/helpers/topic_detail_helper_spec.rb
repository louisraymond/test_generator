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
end
