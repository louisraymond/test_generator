require 'rails_helper'

RSpec.describe QuestionOptions::ClozeOptions do
  it 'round-trips a tokens array' do
    raw = { 'tokens' => [{ 'index' => 0, 'blanked' => true, 'word' => 'hello' }] }
    opts = described_class.from(raw)
    expect(opts.tokens.first.word).to eq('hello')
    expect(opts.blanked_indices).to eq([0])
    expect(opts.to_jsonb['tokens'].first['blanked']).to be true
  end

  it 'treats empty raw as empty tokens' do
    expect(described_class.from({}).tokens).to eq([])
    expect(described_class.from(nil).tokens).to eq([])
  end

  it 'defaults ui_mode to wysiwyg' do
    expect(described_class.from({}).ui_mode).to eq('wysiwyg')
  end
end
