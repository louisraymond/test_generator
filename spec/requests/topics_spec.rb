require 'rails_helper'

RSpec.describe 'Topics show', type: :request do
  describe 'GET /topics/:id' do
    let(:topic) { create(:topic) }

    it 'assigns @exam_usage as a Hash' do
      get topic_path(topic)
      expect(controller.instance_variable_get(:@exam_usage)).to be_a(Hash)
    end

    it 'renders the page' do
      get topic_path(topic)
      expect(response).to have_http_status(:ok)
    end

    it 'issues no more than 6 SQL queries for a realistic topic' do
      # 4 modules x 7 LOs x ~4 questions/LO; some questions in exams
      4.times do |m_idx|
        mod = create(:topic_module, topic: topic, name: "Module #{m_idx}", position: m_idx)
        7.times do
          lo = create(:learning_objective, topic: topic, topic_module: mod)
          4.times do
            q = create(:question, topic: topic, topic_module: mod)
            lo.questions << q
          end
        end
      end
      # Expose ~10 questions across 3 exams
      exams = Array.new(3) { create(:exam) }
      Question.limit(10).each_with_index do |q, i|
        create(:exam_question, exam: exams[i % 3], question: q, position: i + 1)
      end

      count = QueryCounter.count_for do
        get topic_path(topic)
      end
      expect(count).to be <= 6, "expected <= 6 queries, got #{count}"
    end
  end
end
