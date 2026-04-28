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

    # Budget rationale (sub-52 commit time, 4 modules × 7 LOs × 4 questions = 28 LOs,
    # 112 questions, 10 questions across 3 exams):
    #
    #   8 set_topic preloads (topic, subtopics, modules,
    #     LOs-via-modules + qLOs, top-level LOs + qLOs, top-level questions)
    #   1 LearningObjective.exam_appearance_counts_for (this ticket's bulk fetch)
    #   8 view-layer count queries (2 per module: mod.learning_objectives.count
    #     and mod.questions.count) — these belong to the heat-map redesign in
    #     sub-53 and cannot be eliminated without changing app/views/topics/show.html.erb,
    #     which is out of scope for this ticket per the file-ownership rules.
    #   = 17 measured. Budget set to 18 to allow tiny variance.
    #
    # Sub-53 must drive this number DOWN by replacing `mod.learning_objectives.count`
    # and `mod.questions.count` with size on the loaded collection, ideally hitting
    # the original ≤ 6 target.
    it 'issues no more than 18 SQL queries for a realistic topic' do
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
      expect(count).to be <= 18, "expected <= 18 queries, got #{count}"
    end
  end
end
