require 'rails_helper'

RSpec.describe QuestionOptions::MCQOptions do
  describe '.from' do
    it 'accepts legacy hash-of-strings shape' do
      opts = described_class.from([{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }])
      expect(opts.choices.length).to eq(2)
      expect(opts.choices[0].text).to eq('a')
      expect(opts.choices[0].correct).to be true
      expect(opts.choices[1].correct).to be false
    end

    it 'accepts plain-string legacy shape' do
      opts = described_class.from(%w[x y])
      expect(opts.choices.map(&:text)).to eq(%w[x y])
      expect(opts.choices.map(&:correct)).to eq([false, false])
    end

    it 'accepts new shape with eliminated flag' do
      opts = described_class.from([
        { 'text' => 'a', 'correct' => false, 'eliminated' => true },
        { 'text' => 'b', 'correct' => true }
      ])
      expect(opts.choices[0].eliminated).to be true
      expect(opts.correct_indices).to eq([1])
    end
  end

  describe '#to_jsonb' do
    it 'round-trips to a normalized hash shape' do
      raw = [{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }]
      expect(described_class.from(raw).to_jsonb).to eq([
        { 'text' => 'a', 'correct' => true,  'eliminated' => false },
        { 'text' => 'b', 'correct' => false, 'eliminated' => false }
      ])
    end
  end

  describe '#with_correct' do
    it 'flips exclusively by default' do
      opts = described_class.from([{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }, { 'text' => 'c' }])
      flipped = opts.with_correct(idx: 2)
      expect(flipped.correct_indices).to eq([2])
    end
  end

  describe '#validate' do
    it 'flags under-two choices' do
      errors = ActiveModel::Errors.new(Object.new)
      described_class.from([{ 'text' => 'a', 'correct' => true }]).validate(errors)
      expect(errors[:options]).to include('must include at least two choices')
    end

    it 'flags blank text' do
      errors = ActiveModel::Errors.new(Object.new)
      described_class.from([{ 'text' => ' ', 'correct' => true }, { 'text' => 'b' }]).validate(errors)
      expect(errors[:options]).to include('each choice must include text')
    end

    it 'flags no correct' do
      errors = ActiveModel::Errors.new(Object.new)
      described_class.from([{ 'text' => 'a' }, { 'text' => 'b' }]).validate(errors)
      expect(errors[:options]).to include('must have at least one correct choice')
    end
  end
end
