require 'rails_helper'

RSpec.describe 'API POST /api/topics/:topic_id/topic_modules', type: :request do
  let!(:topic) { create(:topic) }

  it 'appends the module after the existing ones' do
    create(:topic_module, topic: topic, position: 2)

    post "/api/topics/#{topic.id}/topic_modules", params: { topic_module: { name: 'Chapter 4' } }, as: :json

    expect(response).to have_http_status(:created)
    expect(TopicModule.find(JSON.parse(response.body)['id']).position).to eq(3)
  end
end
