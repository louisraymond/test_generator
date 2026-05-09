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

    # Budget rationale: V2 is the default chrome. Rendering 4 modules,
    # 28 LOs, and 112 questions costs ~10 queries:
    #
    #   ~8 set_topic preloads (topic, subtopics, modules, modules.LOs,
    #     modules.LOs.QLOs, modules.questions, top-level LOs, top-level
    #     LOs.QLOs, top-level questions)
    #   1 LearningObjective.exam_appearance_counts_for bulk fetch
    #   ≈ 10 measured. Budget set to 12 to allow tiny variance.
    #
    # The view layer reads question counts via LearningObjective#question_count,
    # which uses the already-preloaded `:question_learning_objectives` join —
    # so per-LO `.size` calls are free. Bump this number IF AND ONLY IF
    # you can justify the extra queries.
    it 'issues no more than 12 SQL queries for a realistic topic' do
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
      expect(count).to be <= 12, "expected <= 12 queries, got #{count}"
    end
  end
end
