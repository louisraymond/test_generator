require 'rails_helper'

# Smoke coverage for the per-type PORO value objects. MCQ + Cloze have
# richer dedicated specs. These cases guarantee the .from / .to_jsonb /
# #validate contract for the remaining 10 classes so Wave 3's groundwork
# contract is locked in before any type PR lands.
RSpec.describe 'QuestionOptions (misc value objects)' do
  it 'MatchingOptions round-trips left/right arrays' do
    opts = QuestionOptions::MatchingOptions.from('left' => %w[a b], 'right' => %w[1 2])
    expect(opts.to_jsonb['left']).to eq(%w[a b])
    expect(opts.pairs).to eq([%w[a 1], %w[b 2]])
  end

  it 'OrderingOptions accepts plain-string legacy shape' do
    opts = QuestionOptions::OrderingOptions.from(%w[a b c])
    expect(opts.items.map(&:position)).to eq([1, 2, 3])
  end

  it 'RankingOptions normalises missing rank' do
    opts = QuestionOptions::RankingOptions.from([{ 'text' => 'x' }, { 'text' => 'y', 'rank' => 3 }])
    expect(opts.items.map(&:rank)).to eq([1, 3])
  end

  it 'CalculationOptions defaults answer_format to numeric' do
    opts = QuestionOptions::CalculationOptions.from({})
    expect(opts.answer_format).to eq('numeric')
  end

  it 'DiagramLabelOptions accepts legacy markers key' do
    opts = QuestionOptions::DiagramLabelOptions.from(
      'image' => '/a.png',
      'markers' => [{ 'x' => 10, 'y' => 20, 'answer' => 'alpha' }]
    )
    expect(opts.pins.first.answer).to eq('alpha')
  end

  it 'ImageOcclusionOptions defaults mask shape to rect' do
    opts = QuestionOptions::ImageOcclusionOptions.from(
      'image' => '/x.png',
      'masks' => [{ 'x' => 0, 'y' => 0, 'w' => 10, 'h' => 10, 'answer' => 'a' }]
    )
    expect(opts.masks.first.shape).to eq('rect')
  end

  it 'CodeAnalysisOptions validates language+format' do
    errors = ActiveModel::Errors.new(Object.new)
    QuestionOptions::CodeAnalysisOptions.from(
      'code' => 'print(1)', 'language' => 'python', 'answer_format' => 'lines'
    ).validate(errors)
    expect(errors[:options]).to be_empty
  end

  it 'CompositeOptions reads legacy parts jsonb' do
    opts = QuestionOptions::CompositeOptions.from(
      'parts' => [{ 'stem' => 'first', 'marks' => 2 }, { 'stem' => 'second', 'marks' => 3 }]
    )
    expect(opts.parts.map(&:marks)).to eq([2, 3])
  end

  it 'WrittenOptions defaults answer_size to medium' do
    expect(QuestionOptions::WrittenOptions.from({}).answer_size).to eq('medium')
  end

  it 'MarkdownOptions exposes body' do
    opts = QuestionOptions::MarkdownOptions.from('body' => '# hi')
    expect(opts.body).to eq('# hi')
  end
end
