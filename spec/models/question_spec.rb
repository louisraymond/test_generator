require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'basic validations' do
    it 'requires content, answer, and points' do
      question = Question.new
      expect(question).not_to be_valid
      expect(question.errors[:content]).to be_present
      expect(question.errors[:answer]).to be_present
      expect(question.errors[:points]).to be_present
    end

    it 'allows optional source' do
      question = build(:question, source: nil)
      expect(question).to be_valid
    end

    it 'requires points between 1 and 100' do
      expect(build(:question, points: 0)).not_to be_valid
      expect(build(:question, points: 101)).not_to be_valid
      expect(build(:question, points: 50)).to be_valid
    end

    it 'validates question_type inclusion' do
      expect(build(:question, question_type: 'invalid')).not_to be_valid
      expect(build(:question, question_type: 'written')).to be_valid
    end

    it 'validates bloom_level inclusion when present' do
      expect(build(:question, bloom_level: 'nonsense')).not_to be_valid
      Question::BLOOM_LEVELS.each do |level|
        expect(build(:question, bloom_level: level)).to be_valid
      end
    end

    it 'allows bloom_level to be nil (back-fill is optional)' do
      expect(build(:question, bloom_level: nil)).to be_valid
    end

    it 'validates answer_size inclusion when present' do
      expect(build(:question, answer_size: 'huge')).not_to be_valid
      expect(build(:question, answer_size: 'medium')).to be_valid
      expect(build(:question, answer_size: nil)).to be_valid
    end
  end

  describe 'multiple_choice options validation' do
    it 'requires at least two choices' do
      q = build(:question, question_type: 'multiple_choice', options: [{ 'text' => 'Only one', 'correct' => true }])
      expect(q).not_to be_valid
      expect(q.errors[:options]).to include('must include at least two choices')
    end

    it 'requires at least one correct choice' do
      q = build(:question, question_type: 'multiple_choice', options: [
        { 'text' => 'A', 'correct' => false },
        { 'text' => 'B', 'correct' => false }
      ])
      expect(q).not_to be_valid
      expect(q.errors[:options]).to include('must have at least one correct choice')
    end

    it 'normalizes options during validation' do
      q = build(:question, :multiple_choice)
      q.valid?
      expect(q.options).to all(include('text', 'correct'))
    end
  end

  describe 'matching options validation' do
    it 'requires left and right arrays' do
      q = build(:question, question_type: 'matching', options: { 'left' => %w[A B] })
      expect(q).not_to be_valid
    end

    it 'requires same length arrays' do
      q = build(:question, question_type: 'matching', options: { 'left' => %w[A B], 'right' => %w[1] })
      expect(q).not_to be_valid
    end

    it 'accepts valid matching options' do
      q = build(:question, :matching)
      expect(q).to be_valid
    end
  end

  describe 'ranking options validation' do
    it 'requires at least two items' do
      q = build(:question, question_type: 'ranking', options: [{ 'text' => 'One', 'rank' => 1 }])
      expect(q).not_to be_valid
    end

    it 'normalizes ranking options during validation' do
      q = build(:question, :ranking)
      q.valid?
      expect(q.options).to all(include('text', 'rank'))
    end
  end

  describe 'ordering options validation' do
    it 'requires at least two items' do
      q = build(:question, question_type: 'ordering', options: ['Only one'])
      expect(q).not_to be_valid
    end
  end

  describe '#apply_options_text' do
    it 'parses valid JSON' do
      q = build(:question)
      q.options_text = '[{"text": "A", "correct": true}, {"text": "B", "correct": false}]'
      q.question_type = 'multiple_choice'
      q.valid?
      expect(q.options).to be_an(Array)
      expect(q.options.length).to eq(2)
    end

    it 'adds error for invalid JSON' do
      q = build(:question)
      q.options_text = 'not json'
      expect(q).not_to be_valid
      expect(q.errors[:options].first).to include('must be valid JSON')
    end

    it 'handles blank text by setting empty array' do
      q = build(:question)
      q.options_text = '   '
      q.valid?
      expect(q.options).to eq([])
    end
  end

  describe 'learning_objectives_align_with_topic' do
    it 'rejects objectives from a different topic' do
      topic1 = create(:topic)
      topic2 = create(:topic)
      lo = create(:learning_objective, topic: topic2)
      q = build(:question, topic: topic1)
      q.learning_objectives = [lo]
      expect(q).not_to be_valid
      expect(q.errors[:learning_objectives]).to be_present
    end
  end
end
