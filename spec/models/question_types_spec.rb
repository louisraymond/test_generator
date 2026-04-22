require 'rails_helper'

RSpec.describe QuestionTypes do
  it 'exposes all 12 question-type keys' do
    expect(described_class.keys).to match_array(Question::QUESTION_TYPES)
  end

  it 'returns a Descriptor for each known key' do
    Question::QUESTION_TYPES.each do |key|
      descriptor = described_class.for(key)
      expect(descriptor).not_to be_nil, "no descriptor for #{key}"
      expect(descriptor.key).to eq(key)
      expect(descriptor.label).to be_a(String)
      expect(descriptor.paper_controller).to be_a(String)
      expect(descriptor.options_class).to be < QuestionOptions::Base
    end
  end

  it 'groups descriptors into :choice, :written, :interactive' do
    expect(described_class.grouped.keys).to match_array(%i[choice written interactive])
  end

  it 'returns nil for unknown keys' do
    expect(described_class.for('nonsense')).to be_nil
  end

  it 'honours the feature-flag config for enabled?' do
    Rails.application.config.x.paper_editor.mcq = false
    expect(described_class.enabled?('multiple_choice')).to be false
    Rails.application.config.x.paper_editor.mcq = true
    expect(described_class.enabled?('multiple_choice')).to be true
  end
end
