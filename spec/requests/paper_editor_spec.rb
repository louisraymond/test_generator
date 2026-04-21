# frozen_string_literal: true

require 'rails_helper'

# Phase 7 — paper-is-editor. Tests target the server-side endpoints that
# power the direct-manipulation interactions. Stimulus-driven DOM mutation
# is covered indirectly: we verify that the toggle endpoint mutates the
# question record correctly so the preview-frame re-renders accurately.
RSpec.describe 'Paper-is-editor endpoints', type: :request do
  let(:topic)  { create(:topic) }
  let(:source) { create(:source) }

  describe 'POST /questions/:id/toggle_correct' do
    let(:question) do
      create(:question, :multiple_choice, topic: topic, source: source,
                                          options: [
                                            { 'text' => 'Photon',  'correct' => true },
                                            { 'text' => 'Gluon',   'correct' => false },
                                            { 'text' => 'W boson', 'correct' => false },
                                            { 'text' => 'Z boson', 'correct' => false }
                                          ],
                                          points: 1, answer: 'Photon')
    end

    it 'marks the selected option correct and all others incorrect' do
      post toggle_correct_question_path(question), params: { index: 2 }
      expect(response).to have_http_status(:ok)
      question.reload
      expect(question.options.map { |o| o['correct'] }).to eq([false, false, true, false])
    end

    it 'single-choice semantics: setting another index flips the previous one' do
      post toggle_correct_question_path(question), params: { index: 0 }
      post toggle_correct_question_path(question), params: { index: 2 }
      question.reload
      expect(question.options[0]['correct']).to be false
      expect(question.options[2]['correct']).to be true
    end

    it 'rejects non-MCQ questions with 422' do
      other = create(:question, topic: topic, source: source, question_type: 'written')
      post toggle_correct_question_path(other), params: { index: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /questions/:id/toggle_blank (cloze)' do
    let(:question) do
      create(:question, topic: topic, source: source,
                        question_type: 'cloze',
                        options: [],
                        content: 'The photon is the force carrier of the electromagnetic interaction.',
                        answer: 'photon,electromagnetic')
    end

    it 'records a blank at the given word index and returns tokenised stem' do
      post toggle_blank_question_path(question), params: { word_index: 1 }
      expect(response).to have_http_status(:ok)
      question.reload

      tokens = question.options['tokens'] || []
      expect(tokens).to be_an(Array)
      expect(tokens.any? { |t| t.is_a?(Hash) && t['blanked'] && t['index'] == 1 }).to be(true)
    end

    it 'toggling an already-blanked word removes the blank' do
      post toggle_blank_question_path(question), params: { word_index: 1 }
      post toggle_blank_question_path(question), params: { word_index: 1 }
      question.reload
      tokens = question.options['tokens'] || []
      expect(tokens.any? { |t| t.is_a?(Hash) && t['blanked'] && t['index'] == 1 }).to be(false)
    end
  end
end
