require 'rails_helper'

RSpec.describe 'Exam generation' do
  it 'creates exam with random questions from selected topics' do
    topic = create(:topic)
    create_list(:question, 10, topic: topic)

    post exams_path, params: { topic_ids: [topic.id], question_count: 5 }

    expect(Exam.last.questions.count).to eq(5)
    expect(Exam.last.questions.pluck(:topic_id).uniq).to eq([topic.id])
  end
end
