require 'rails_helper'

RSpec.describe 'Questions create/update (code_analysis form)', type: :request do
  let!(:topic) { create(:topic) }
  let!(:topic_module) { create(:topic_module, topic: topic, position: 1) }
  let!(:lo) { create(:learning_objective, topic: topic, topic_module: topic_module, position: 1) }

  describe 'POST /questions with code_analysis (lines variant)' do
    let(:params) do
      {
        question: {
          topic_id: topic.id,
          content: 'What does this function return?',
          answer: 'The nth Fibonacci number.',
          points: 2,
          question_type: 'code_analysis',
          answer_size: 'medium',
          learning_objective_ids: [lo.id.to_s],
          code_analysis: {
            language: 'python',
            code: "def fib(n):\n    return n if n < 2 else fib(n-1) + fib(n-2)",
            answer_format: 'lines'
          }
        }
      }
    end

    it 'persists a code_analysis question with a hash options value' do
      expect { post questions_path, params: params }.to change(Question, :count).by(1)

      q = Question.last
      expect(q.question_type).to eq('code_analysis')
      expect(q.options).to be_a(Hash)
      expect(q.options['language']).to eq('python')
      expect(q.options['code']).to include('fib')
      expect(q.options['answer_format']).to eq('lines')
      expect(q.options).not_to have_key('choices')
    end

    it 'does not leak the code_analysis nested params onto the model' do
      post questions_path, params: params
      q = Question.last
      expect(q).not_to respond_to(:code_analysis)
    end
  end

  describe 'POST /questions with code_analysis (multiple_choice variant)' do
    let(:params) do
      {
        question: {
          topic_id: topic.id,
          content: 'What does this method return?',
          answer: 'B - Unique names from the collection',
          points: 2,
          question_type: 'code_analysis',
          learning_objective_ids: [lo.id.to_s],
          code_analysis: {
            language: 'ruby',
            code: "def names(users)\n  users.map(&:name).uniq\nend",
            answer_format: 'multiple_choice',
            choices: {
              '0' => { text: 'Sorted names', correct: '0' },
              '1' => { text: 'Unique names from the collection', correct: '1' },
              '2' => { text: 'Raises NoMethodError', correct: '0' }
            }
          }
        }
      }
    end

    it 'persists a code_analysis MC question with choices array in options' do
      expect { post questions_path, params: params }.to change(Question, :count).by(1)

      q = Question.last
      expect(q.options['answer_format']).to eq('multiple_choice')
      expect(q.options['choices']).to be_an(Array)
      expect(q.options['choices'].length).to eq(3)
      expect(q.options['choices'].count { |c| c['correct'] }).to eq(1)
      expect(q.options['choices'].find { |c| c['correct'] }['text']).to include('Unique')
    end

    it 'drops blank choices rather than persisting empty-text entries' do
      params[:question][:code_analysis][:choices]['3'] = { text: '   ', correct: '0' }
      post questions_path, params: params
      q = Question.last
      expect(q.options['choices'].length).to eq(3)
    end

    it 'rejects when no choice is marked correct (validation)' do
      params[:question][:code_analysis][:choices].each_value { |c| c[:correct] = '0' }
      expect { post questions_path, params: params }.not_to change(Question, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /questions/:id (edit mode for code_analysis)' do
    let!(:existing) do
      create(:question,
             topic: topic,
             topic_module: topic_module,
             question_type: 'code_analysis',
             answer_size: 'medium',
             options: {
               'language' => 'python',
               'code' => 'print("old")',
               'answer_format' => 'lines'
             })
    end

    it 'updates options from the code_analysis nested params' do
      patch question_path(existing), params: {
        question: {
          topic_id: topic.id,
          content: existing.content,
          answer: existing.answer,
          points: existing.points,
          question_type: 'code_analysis',
          code_analysis: {
            language: 'ruby',
            code: 'puts "new"',
            answer_format: 'lines'
          }
        }
      }

      existing.reload
      expect(existing.options['language']).to eq('ruby')
      expect(existing.options['code']).to eq('puts "new"')
      expect(existing.options['answer_format']).to eq('lines')
    end
  end

  describe 'non-code_analysis types still work (regression)' do
    let(:params) do
      {
        question: {
          topic_id: topic.id,
          content: 'Write about X.',
          answer: 'Model answer.',
          points: 1,
          question_type: 'written',
          answer_size: 'medium'
        }
      }
    end

    it 'creates a written question as before' do
      expect { post questions_path, params: params }.to change(Question, :count).by(1)
      expect(Question.last.question_type).to eq('written')
    end
  end
end
