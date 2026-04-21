# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workspace setup tab', type: :request do
  describe 'GET /workspace?tab=setup' do
    it 'renders the setup form with redesign fields' do
      get '/workspace?tab=setup'
      body = response.body

      expect(body).to include('name="exam_template[subject]"')
      expect(body).to include('name="exam_template[paper_number]"')
      expect(body).to include('name="exam_template[tier]"')
      expect(body).to include('name="exam_template[subtitle]"')
      expect(body).to include('name="exam_template[rubric]"')
      expect(body).to include('name="exam_template[centre_name]"')
      expect(body).to include('name="exam_template[principles_of_marking]"')
    end

    it 'renders a tier segmented control with three options' do
      get '/workspace?tab=setup'
      %w[foundation higher standard].each do |tier|
        expect(response.body).to include("value=\"#{tier}\"")
      end
    end

    it 'shows candidate field toggles' do
      get '/workspace?tab=setup'
      expect(response.body).to include('candidate_fields')
    end

    it 'renders at least one section row by default' do
      get '/workspace?tab=setup'
      expect(response.body).to match(/exam_sections_attributes\]\[0\]\[name\]/)
    end
  end

  describe 'POST /exam_templates with redesign fields' do
    it 'creates a template with the new fields set' do
      expect do
        post '/exam_templates', params: {
          exam_template: {
            name: 'Redesigned template',
            subject: 'Physics',
            paper_number: '2',
            tier: 'higher',
            subtitle: 'Mock · Winter 2026',
            rubric: 'Answer all questions.',
            centre_name: 'Test Centre',
            candidate_fields: ['Full name', 'Candidate number'],
            grade_boundaries: { 'A*' => 50, 'A' => 42 },
            principles_of_marking: 'Credit equivalent forms.',
            exam_sections_attributes: [
              { position: 0, name: 'Section A', question_count: 5, letter: 'A' }
            ]
          }
        }
      end.to change(ExamTemplate, :count).by(1)

      template = ExamTemplate.last
      expect(template.subject).to eq('Physics')
      expect(template.tier).to eq('higher')
      expect(template.candidate_fields).to eq(['Full name', 'Candidate number'])
      expect(template.grade_boundaries).to eq({ 'A*' => 50, 'A' => 42 })
      expect(template.principles_of_marking).to include('equivalent')
      expect(template.exam_sections.first.letter).to eq('A')
    end
  end
end
