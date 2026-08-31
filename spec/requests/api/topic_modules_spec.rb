require 'rails_helper'

RSpec.describe 'API POST /api/topics/:topic_id/topic_modules', type: :request do
  let!(:topic) { create(:topic) }

  def create_module(name)
    post "/api/topics/#{topic.id}/topic_modules",
         params: { topic_module: { name: name } }.to_json,
         headers: { 'Content-Type' => 'application/json' }
  end

  it 'creates a module from only a name and auto-assigns a position' do
    expect {
      create_module('Ch 9 §9.1 revised')
    }.to change(TopicModule, :count).by(1)

    expect(response).to have_http_status(:created)
    json = JSON.parse(response.body)
    expect(json['name']).to eq('Ch 9 §9.1 revised')
    expect(TopicModule.find(json['id']).position).to be_present
  end

  it 'assigns the next sequential position within the topic' do
    create(:topic_module, topic: topic, position: 1)
    create(:topic_module, topic: topic, position: 2)

    create_module('next module')

    expect(response).to have_http_status(:created)
    expect(TopicModule.find(JSON.parse(response.body)['id']).position).to eq(3)
  end
end
