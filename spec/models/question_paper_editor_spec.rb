require 'rails_helper'

RSpec.describe Question, 'paper-editor integration' do
  let(:topic) { Topic.create!(name: 'T') }

  describe '#typed_options' do
    it 'returns a QuestionOptions value object for the question type' do
      q = Question.new(topic: topic, question_type: 'multiple_choice',
                       content: 'x', answer: 'x', points: 1,
                       options: [{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }])
      expect(q.typed_options).to be_a(QuestionOptions::MCQOptions)
      expect(q.typed_options.correct_indices).to eq([0])
    end

    it 'returns nil for unknown types' do
      q = Question.new(question_type: 'nonsense')
      expect(q.typed_options).to be_nil
    end
  end

  describe '#paper_editor_enabled?' do
    it 'defaults to enabled' do
      q = Question.new(question_type: 'multiple_choice')
      expect(q.paper_editor_enabled?).to be true
    end

    it 'falls to false when the feature flag is off' do
      Rails.application.config.x.paper_editor.mcq = false
      q = Question.new(question_type: 'multiple_choice')
      expect(q.paper_editor_enabled?).to be false
    ensure
      Rails.application.config.x.paper_editor.mcq = true
    end
  end

  it 'has a lock_version column defaulting to 0' do
    q = Question.create!(topic: topic, question_type: 'written',
                         content: 'x', answer: 'y', points: 1)
    expect(q.lock_version).to eq(0)
  end
end
