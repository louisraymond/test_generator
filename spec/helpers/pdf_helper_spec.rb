# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfHelper, type: :helper do
  describe '#marks_to_workspace' do
    # Marks-based defaults (revised for maths: every question gets a real
    # working box; anything 4+ marks is half-page minimum).
    it 'returns a small working box for 1 mark' do
      expect(helper.marks_to_workspace(1)).to eq('workbox workbox--sm')
    end

    it 'returns a medium working box for 2 marks' do
      expect(helper.marks_to_workspace(2)).to eq('workbox workbox--md')
    end

    it 'returns a large working box for 3 marks' do
      expect(helper.marks_to_workspace(3)).to eq('workbox workbox--lg')
    end

    it 'returns an extra-large (half-page) working box for 4+ marks' do
      expect(helper.marks_to_workspace(4)).to eq('workbox workbox--xl')
      expect(helper.marks_to_workspace(5)).to eq('workbox workbox--xl')
      expect(helper.marks_to_workspace(12)).to eq('workbox workbox--xl')
    end

    it 'defaults to two lines for nil or zero' do
      expect(helper.marks_to_workspace(nil)).to eq('lines lines--2')
      expect(helper.marks_to_workspace(0)).to eq('lines lines--2')
    end

    describe 'answer_size override (Question-shaped argument)' do
      Q = Struct.new(:points, :answer_size, :question_type)

      it "uses 'long' to force an XL workbox regardless of marks" do
        expect(helper.marks_to_workspace(Q.new(1, 'long', 'calculation'))).to eq('workbox workbox--xl')
      end

      it "uses 'medium' to force a large workbox" do
        expect(helper.marks_to_workspace(Q.new(1, 'medium', 'calculation'))).to eq('workbox workbox--lg')
      end

      it "uses 'short' to force one line regardless of marks" do
        expect(helper.marks_to_workspace(Q.new(10, 'short', 'calculation'))).to eq('lines lines--1')
      end

      it 'falls back to marks when answer_size is nil' do
        expect(helper.marks_to_workspace(Q.new(4, nil, 'calculation'))).to eq('workbox workbox--xl')
      end
    end

    describe 'prose question types render ruled lines, not a workbox' do
      Qtype = Struct.new(:points, :answer_size, :question_type)

      it 'written → ruled lines sized by marks' do
        expect(helper.marks_to_workspace(Qtype.new(1, nil, 'written'))).to eq('lines lines--4')
        expect(helper.marks_to_workspace(Qtype.new(3, nil, 'written'))).to eq('lines lines--10')
        expect(helper.marks_to_workspace(Qtype.new(5, nil, 'written'))).to eq('lines lines--22')
      end

      it 'markdown → same as written' do
        expect(helper.marks_to_workspace(Qtype.new(4, nil, 'markdown'))).to eq('lines lines--16')
      end

      it 'composite → ruled lines (sub-parts each render their own region)' do
        expect(helper.marks_to_workspace(Qtype.new(5, nil, 'composite'))).to eq('lines lines--22')
      end

      it 'calculation stays on workbox' do
        expect(helper.marks_to_workspace(Qtype.new(5, nil, 'calculation'))).to eq('workbox workbox--xl')
      end

      it "answer_size 'long' on a written question yields tall ruled lines" do
        expect(helper.marks_to_workspace(Qtype.new(1, 'long', 'written'))).to eq('lines lines--22')
      end
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

  describe '#tokenize_cloze' do
    it 'recognises {{answer}} as an autoblank' do
      toks = helper.tokenize_cloze('Paris is the capital of {{France}}.')
      autoblanks = toks.select { |t| t[:type] == :autoblank }
      expect(autoblanks.length).to eq(1)
      expect(autoblanks.first[:answer]).to eq('France')
    end

    it 'recognises [[answer]] as an autoblank (Wave 5 — seeded content)' do
      toks = helper.tokenize_cloze('During the [[prefill]] phase, tokens are [[parallel]].')
      autoblanks = toks.select { |t| t[:type] == :autoblank }
      expect(autoblanks.map { |t| t[:answer] }).to eq(%w[prefill parallel])
    end

    it 'strips whitespace inside [[ answer ]] markup' do
      toks = helper.tokenize_cloze('Perform a [[ O(n) ]] scan.')
      autoblanks = toks.select { |t| t[:type] == :autoblank }
      expect(autoblanks.first[:answer]).to eq('O(n)')
    end

    it 'does not treat literal $N currency as a math span' do
      toks = helper.tokenize_cloze('Price is $25 at the shop and $100 online.')
      expect(toks.none? { |t| t[:type] == :math }).to be true
    end

    it 'still treats $x^2$ as a math span' do
      toks = helper.tokenize_cloze('Given $x^2$, derive the root.')
      expect(toks.any? { |t| t[:type] == :math && t[:text] == '$x^2$' }).to be true
    end
  end
end
