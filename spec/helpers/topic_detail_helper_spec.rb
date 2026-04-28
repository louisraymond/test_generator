# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopicDetailHelper, type: :helper do
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
