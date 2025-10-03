require 'rails_helper'

RSpec.describe Question do
  it 'requires content, answer, and points' do
    question = Question.new

    expect(question).not_to be_valid
    expect(question.errors[:content]).to be_present
  end

  it 'allows optional source' do
    question = build(:question, source: nil)

    expect(question).to be_valid
  end
end
