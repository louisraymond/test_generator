# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfHelper, type: :helper do
  describe '#marks_to_workspace' do
    it 'returns a one-line rule for 1 mark' do
      expect(helper.marks_to_workspace(1)).to eq('lines lines--1')
    end

    it 'returns two lines for 2 marks' do
      expect(helper.marks_to_workspace(2)).to eq('lines lines--2')
    end

    it 'returns a small working box for 3 marks' do
      expect(helper.marks_to_workspace(3)).to eq('workbox workbox--sm')
    end

    it 'returns a medium working box for 4 marks' do
      expect(helper.marks_to_workspace(4)).to eq('workbox workbox--md')
    end

    it 'returns a large working box for 5+ marks' do
      expect(helper.marks_to_workspace(5)).to eq('workbox workbox--lg')
      expect(helper.marks_to_workspace(12)).to eq('workbox workbox--lg')
    end

    it 'defaults to one line for nil or zero' do
      expect(helper.marks_to_workspace(nil)).to eq('lines lines--1')
      expect(helper.marks_to_workspace(0)).to eq('lines lines--1')
    end
  end

  describe '#render_final_answer' do
    it 'emits a .finalans block with label and unit' do
      html = helper.render_final_answer(label: 'θ =', unit: '°')
      expect(html).to include('class="finalans"')
      expect(html).to include('θ =')
      expect(html).to include('class="finalans__unit">°')
    end

    it 'omits the unit span when no unit is given' do
      html = helper.render_final_answer(label: 'x =')
      expect(html).not_to include('finalans__unit')
    end
  end

  describe '#render_mark (credit pill)' do
    it 'emits a method pill' do
      html = helper.render_mark(kind: 'm', n: 1)
      expect(html).to include('class="mark mark--m"')
      expect(html).to include('M1')
    end

    it 'emits an accuracy pill' do
      expect(helper.render_mark(kind: 'a', n: 2)).to include('A2')
    end

    it 'emits a B (unconditional) pill' do
      expect(helper.render_mark(kind: 'b', n: 1)).to include('B1')
    end

    it 'emits a dependent-method pill' do
      expect(helper.render_mark(kind: 'dm', n: 1)).to include('DM1')
    end
  end

  describe '#shuffled_mcq_options' do
    it 'produces a deterministic shuffle for a given seed' do
      options = [
        { 'text' => 'A', 'correct' => true },
        { 'text' => 'B', 'correct' => false },
        { 'text' => 'C', 'correct' => false },
        { 'text' => 'D', 'correct' => false }
      ]
      first  = helper.shuffled_mcq_options(options, seed: 4721)
      second = helper.shuffled_mcq_options(options, seed: 4721)
      expect(first).to eq(second)
    end

    it 'preserves all options' do
      options = [{ 'text' => 'A' }, { 'text' => 'B' }, { 'text' => 'C' }]
      expect(helper.shuffled_mcq_options(options, seed: 1).sort_by { |o| o['text'] })
        .to eq(options.sort_by { |o| o['text'] })
    end
  end
end
