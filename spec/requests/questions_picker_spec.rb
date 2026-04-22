require 'rails_helper'

# Wave 5 — /questions/new is now a type picker, and /questions/:id/edit
# is the paper-is-editor. Classic multi-section forms stay behind
# ?ui=classic.
RSpec.describe 'Questions editor (Wave 5)', type: :request do
  let!(:topic) { Topic.create!(name: 'Picker topic') }

  describe 'GET /questions/new' do
    it 'renders the type picker' do
      get '/questions/new'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('What')
      expect(response.body).to include('q-picker-card')
      # Every type registered in the registry should appear as a card.
      QuestionTypes.keys.each do |k|
        expect(response.body).to include(%(data-type="#{k}")), "missing card for #{k}"
      end
    end

    it 'redirects to /questions/:id/edit when ?type= is picked' do
      expect {
        get '/questions/new?type=multiple_choice'
      }.to change(Question, :count).by(1)
      expect(response).to redirect_to(edit_question_path(Question.last))
      expect(Question.last.question_type).to eq('multiple_choice')
      expect(Question.last.options).to be_present
    end

    it 'keeps the classic multi-section form behind ?ui=classic' do
      get '/questions/new?ui=classic'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('question_form') # classic CSS class
    end
  end

  describe 'GET /questions/:id/edit' do
    let(:q) do
      Question.create!(topic: topic, question_type: 'multiple_choice',
                       content: 'Stem', answer: 'a', points: 1,
                       options: [{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }])
    end

    it 'renders the paper-is-editor by default' do
      get edit_question_path(q)
      expect(response.body).to include('q-editor-single')
      expect(response.body).to include('rail__eyebrow')
      # The paper-editor Stimulus controller attaches when editable.
      expect(response.body).to match(/data-controller="[^"]*paper-editor/)
    end

    it 'renders the classic form behind ?ui=classic' do
      get edit_question_path(q, ui: 'classic')
      expect(response.body).to include('Classic')
      expect(response.body).not_to include('q-editor-single')
    end
  end
end
