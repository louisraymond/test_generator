require 'rails_helper'

RSpec.describe 'API DELETE /api/questions/:id', type: :request do
  let!(:topic) { create(:topic) }
  let!(:question) { create(:question, topic: topic) }

  it 'returns 204 and removes the question' do
    expect {
      delete "/api/questions/#{question.id}"
    }.to change(Question, :count).by(-1)

    expect(response).to have_http_status(:no_content)
    expect(Question.find_by(id: question.id)).to be_nil
  end

  it 'returns 404 when the question does not exist' do
    delete '/api/questions/999999'
    expect(response).to have_http_status(:not_found)
    json = JSON.parse(response.body)
    expect(json['error']).to match(/not found/i)
  end

  it 'leaves the topic, module, and LOs intact' do
    topic_module = create(:topic_module, topic: topic, position: 1)
    lo = create(:learning_objective, topic: topic, topic_module: topic_module, position: 1)
    q = create(:question, topic: topic, topic_module: topic_module)
    create(:question_learning_objective, question: q, learning_objective: lo)

    expect {
      delete "/api/questions/#{q.id}"
    }.to change(Question, :count).by(-1)
       .and change(QuestionLearningObjective, :count).by(-1)

    expect(response).to have_http_status(:no_content)
    expect(Topic.find_by(id: topic.id)).to be_present
    expect(TopicModule.find_by(id: topic_module.id)).to be_present
    expect(LearningObjective.find_by(id: lo.id)).to be_present
  end

  it 'cascades to exam_questions but preserves the exam itself' do
    exam = create(:exam)
    create(:exam_question, exam: exam, question: question, position: 1)

    expect {
      delete "/api/questions/#{question.id}"
    }.to change(Question, :count).by(-1)
       .and change(ExamQuestion, :count).by(-1)

    expect(Exam.find_by(id: exam.id)).to be_present
  end
end
