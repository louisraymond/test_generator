require 'swagger_helper'

RSpec.describe 'api/questions', type: :request do
  let!(:topic) { create(:topic) }
  let!(:topic_module) { create(:topic_module, topic: topic, position: 1) }
  let!(:learning_objective) do
    create(:learning_objective, topic: topic, topic_module: topic_module, position: 1)
  end

  let(:code_analysis_lines) do
    {
      content: 'What does this function compute?',
      answer: 'The nth Fibonacci number (naive recursion).',
      points: 2,
      question_type: 'code_analysis',
      topic_module_id: topic_module.id,
      learning_objective_ids: [learning_objective.id],
      options: {
        language: 'python',
        code: "def fib(n):\n    return n if n < 2 else fib(n-1) + fib(n-2)",
        answer_format: 'lines'
      }
    }
  end

  let(:code_analysis_mc) do
    {
      content: 'What does this method return?',
      answer: 'A - Returns unique names',
      points: 2,
      question_type: 'code_analysis',
      topic_module_id: topic_module.id,
      learning_objective_ids: [learning_objective.id],
      options: {
        language: 'ruby',
        code: "def names(items)\n  items.map(&:name).uniq\nend",
        answer_format: 'multiple_choice',
        choices: [
          { text: 'Returns unique names', correct: true },
          { text: 'Mutates the items array', correct: false },
          { text: 'Raises NoMethodError', correct: false }
        ]
      }
    }
  end

  path '/api/questions/bulk' do
    post 'Bulk-create questions for a topic' do
      tags 'Questions'
      consumes 'application/json'
      produces 'application/json'
      description 'Create up to 500 questions for a topic in one transaction. Each question has a question_type and a type-specific options shape. See examples below for code_analysis variants (lines and multiple_choice).'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[topic_id questions],
        properties: {
          topic_id: { type: :integer },
          strict: { type: :boolean, default: false,
                    description: 'When true, any validation error rolls back the whole batch.' },
          questions: {
            type: :array,
            maxItems: 500,
            items: {
              type: :object,
              required: %w[content answer points question_type],
              properties: {
                client_id: { type: :string, description: 'Optional client-supplied identifier, echoed in error responses.' },
                content: { type: :string },
                answer: { type: :string },
                points: { type: :integer, minimum: 1, maximum: 100 },
                question_type: { type: :string, enum: Question::QUESTION_TYPES },
                answer_size: { type: :string, enum: Question::ANSWER_SIZES, nullable: true },
                topic_module_id: { type: :integer, nullable: true },
                source_id: { type: :integer, nullable: true },
                source_name: { type: :string, nullable: true },
                learning_objective_ids: { type: :array, items: { type: :integer } },
                options: { description: 'Type-specific options shape. For code_analysis, a hash with language, code, answer_format, and (when multiple_choice) choices.' }
              }
            }
          }
        }
      }

      response '200', 'questions created (code_analysis, lines)' do
        let(:payload) { { topic_id: topic.id, questions: [code_analysis_lines] } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['created']).to eq(1)
          expect(body['errors']).to eq([])
          q = topic.questions.reload.last
          expect(q.question_type).to eq('code_analysis')
          expect(q.options['answer_format']).to eq('lines')
          expect(q.options['language']).to eq('python')
        end
      end

      response '200', 'questions created (code_analysis, multiple_choice)' do
        let(:payload) { { topic_id: topic.id, questions: [code_analysis_mc] } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['created']).to eq(1)
          q = topic.questions.reload.last
          expect(q.options['answer_format']).to eq('multiple_choice')
          expect(q.options['choices'].length).to eq(3)
        end
      end

      response '200', 'mixed batch with one invalid code_analysis returns per-item error (non-strict)' do
        let(:bad_question) { code_analysis_lines.merge(options: { language: 'python', answer_format: 'lines' }) } # missing code
        let(:payload) { { topic_id: topic.id, questions: [code_analysis_lines, bad_question], strict: false } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['created']).to eq(1)
          expect(body['errors'].length).to eq(1)
          expect(body['errors'].first['message']).to match(/code/i)
        end
      end

      response '422', 'strict mode: invalid answer_format rolls back batch' do
        let(:bad_question) { code_analysis_lines.merge(options: code_analysis_lines[:options].merge(answer_format: 'essay')) }
        let(:payload) { { topic_id: topic.id, questions: [bad_question], strict: true } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['created']).to eq(0)
          expect(body['errors'].length).to eq(1)
          expect(body['errors'].first['message']).to match(/answer_format/)
        end
      end
    end
  end
end
