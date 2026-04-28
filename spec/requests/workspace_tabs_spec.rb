require 'rails_helper'

# Wave 4+5 — workspace tab smoke specs. Every tab partial must render
# without raising even when the DB is empty. Regression guard for the
# "missing @topics for generate tab" bug that took out the wizard when
# it first landed.
RSpec.describe 'Workspace tabs render', type: :request do
  before do
    # Ensure some DB state exists so the templates tab has rows to render.
    Topic.create!(name: 'Sample topic') unless Topic.any?
  end

  %w[dashboard topics questions templates generate history setup kb canvas review].each do |tab|
    it "renders tab=#{tab}" do
      get "/workspace?tab=#{tab}"
      expect(response).to have_http_status(:ok)
    end
  end

  it 'generate tab shows the 3-step wizard shell' do
    get '/workspace?tab=generate'
    expect(response.body).to include('data-controller="wizard exam-form"')
    expect(response.body).to include('data-wizard-step="1"')
    expect(response.body).to include('data-wizard-step="2"')
    expect(response.body).to include('data-wizard-step="3"')
    expect(response.body).to include('Blueprint')
  end

  it 'workspace shell enables the command palette controller' do
    get '/workspace?tab=dashboard'
    expect(response.body).to match(/data-controller="palette/)
    expect(response.body).to include('⌘K')
  end

  it 'questions tab renders learning-objective chips for linked questions' do
    topic = Topic.create!(name: 'LO chip workspace topic')
    mod = topic.topic_modules.create!(name: 'Mod 1', position: 1)
    lo = topic.learning_objectives.create!(
      topic_module: mod,
      description: 'Sentinel objective for workspace LO chip rendering',
      category: 'Mod 1',
      position: 1,
    )
    question = topic.questions.create!(
      topic_module: mod,
      content: 'Sample stem for chip rendering check',
      answer: 'Model answer',
      points: 1,
      question_type: 'written',
      options: [],
    )
    question.learning_objectives << lo

    get "/workspace?tab=questions&topic_id=#{topic.id}"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('outcome-chip'),
      'expected the workspace questions tab to render LO chips'
    expect(response.body).to include('Sentinel objective for workspace LO chip rendering')
  end
end
