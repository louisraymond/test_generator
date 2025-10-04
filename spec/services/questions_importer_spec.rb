require 'rails_helper'

RSpec.describe QuestionsImporter, type: :service do
  let(:topic) { create(:topic, name: 'Test Topic') }
  let(:source) { create(:source, name: 'Test Source') }

  describe '.call' do
    context 'with valid data' do
      let(:valid_data) do
        [
          ['Test Topic', 'written', 'Test question?', 'Test answer', '2', 'short', 'Test Source', 'Page 1', '', ''],
          ['New Topic', 'multiple_choice', 'MC question?', 'A - Correct', '1', 'short', '', '', '', '', 'Option A|Option B|Option C|Option D']
        ]
      end

      it 'creates questions successfully' do
        result = QuestionsImporter.call(valid_data)

        expect(result[:success]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:created_questions]).to eq(2)
        expect(result[:created_topics]).to eq(1) # New Topic
        expect(result[:created_sources]).to eq(0) # Test Source already exists
      end

      it 'creates topics and sources as needed' do
        QuestionsImporter.call(valid_data)

        expect(Topic.find_by(name: 'Test Topic')).to eq(topic)
        expect(Topic.find_by(name: 'New Topic')).to be_present
        expect(Source.find_by(name: 'Test Source')).to eq(source)
      end

      it 'creates questions with correct attributes' do
        QuestionsImporter.call(valid_data)

        question = Question.find_by(content: 'Test question?')
        expect(question).to be_present
        expect(question.topic.name).to eq('Test Topic')
        expect(question.source.name).to eq('Test Source')
        expect(question.question_type).to eq('written')
        expect(question.points).to eq(2)
        expect(question.answer_size).to eq('short')
      end
    end

    context 'with invalid data' do
      let(:invalid_data) do
        [
          ['', 'written', 'Test question?', 'Test answer', '2', 'short', '', '', '', ''], # Missing topic
          ['Test Topic', 'invalid_type', 'Test question?', 'Test answer', '2', 'short', '', '', '', ''] # Invalid question type
        ]
      end

      it 'returns validation errors' do
        result = QuestionsImporter.call(invalid_data, dry_run: true)

        expect(result[:success]).to be false
        expect(result[:errors]).not_to be_empty
        expect(result[:errors]).to include(match(/Missing required field: topic/))
        expect(result[:errors]).to include(match(/Invalid question_type/))
      end

      it 'does not create questions when validation fails' do
        expect {
          QuestionsImporter.call(invalid_data)
        }.to raise_error(QuestionsImporter::ValidationError)

        expect(Question.count).to eq(0)
      end
    end

    context 'with dry run' do
      let(:valid_data) do
        [['Test Topic', 'written', 'Test question?', 'Test answer', '2', 'short', '', '', '', '']]
      end

      it 'validates without creating records' do
        result = QuestionsImporter.call(valid_data, dry_run: true)

        expect(result[:success]).to be true
        expect(result[:created_questions]).to eq(0)
        expect(Question.count).to eq(0)
      end
    end

    context 'with transaction rollback' do
      let(:data_with_error) do
        [
          ['Test Topic', 'written', 'Valid question?', 'Valid answer', '2', 'short', '', '', '', ''],
          ['Test Topic', 'written', 'Invalid question?', '', '2', 'short', '', '', '', ''] # Missing answer
        ]
      end

      it 'rolls back all changes on error' do
        expect {
          QuestionsImporter.call(data_with_error)
        }.to raise_error(QuestionsImporter::ImportError)

        expect(Question.count).to eq(0)
        expect(Topic.count).to eq(1) # Only the existing topic
      end
    end
  end
end
