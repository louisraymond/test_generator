# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExamTemplate, type: :model do
  describe 'redesign-era fields' do
    it 'stores subject, paper_number, tier, subtitle, rubric, centre_name' do
      template = create(:exam_template,
                        subject: 'Mathematics',
                        paper_number: '3',
                        tier: 'higher',
                        subtitle: 'Mock · Summer 2026',
                        rubric: 'Answer all questions in the spaces provided.',
                        centre_name: 'Heathbank Academy')
      expect(template.reload).to have_attributes(
        subject: 'Mathematics',
        paper_number: '3',
        tier: 'higher',
        subtitle: 'Mock · Summer 2026',
        rubric: 'Answer all questions in the spaces provided.',
        centre_name: 'Heathbank Academy'
      )
    end

    it 'stores candidate_fields as a jsonb array of labels' do
      fields = %w[Name Centre Candidate\ number]
      template = create(:exam_template, candidate_fields: fields)
      expect(template.reload.candidate_fields).to eq(fields)
    end

    it 'stores grade_boundaries as a jsonb hash' do
      boundaries = { 'A*' => 54, 'A' => 46, 'B' => 38 }
      template = create(:exam_template, grade_boundaries: boundaries)
      expect(template.reload.grade_boundaries).to eq(boundaries)
    end

    describe 'tier validation' do
      it 'accepts foundation, higher, standard' do
        %w[foundation higher standard].each do |tier|
          expect(build(:exam_template, tier: tier)).to be_valid
        end
      end

      it 'accepts nil (tier is optional)' do
        expect(build(:exam_template, tier: nil)).to be_valid
      end

      it 'rejects unknown tiers' do
        expect(build(:exam_template, tier: 'elite')).not_to be_valid
      end
    end
  end
end
