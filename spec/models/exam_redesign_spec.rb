# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exam, type: :model do
  describe 'redesign-era fields' do
    it 'stores exam_date, seed, centre_name_override, lock_version' do
      exam = create(:exam,
                    exam_date: Date.new(2026, 4, 17),
                    seed: 4721,
                    centre_name_override: 'Sitwell Centre')
      expect(exam.reload).to have_attributes(
        exam_date: Date.new(2026, 4, 17),
        seed: 4721,
        centre_name_override: 'Sitwell Centre'
      )
      expect(exam.reload.lock_version).to eq(0)
    end

    it 'assigns a random seed on create when none is given' do
      exam = create(:exam, seed: nil)
      expect(exam.seed).to be_a(Integer)
      expect(exam.seed).to be_between(0, 9_999)
    end

    it 'does not reassign the seed on update' do
      exam = create(:exam, seed: 123)
      expect { exam.update!(title: 'Renamed') }.not_to(change { exam.reload.seed })
    end
  end

  describe 'template inheritance' do
    let(:template) do
      create(:exam_template,
             subject: 'Physics',
             paper_number: '1',
             tier: 'higher',
             centre_name: 'Heathbank Academy')
    end

    it 'inherits subject/paper_number/tier/centre_name from the template' do
      exam = create(:exam, exam_template: template)
      expect(exam.subject).to eq('Physics')
      expect(exam.paper_number).to eq('1')
      expect(exam.tier).to eq('higher')
      expect(exam.centre_name).to eq('Heathbank Academy')
    end

    it 'prefers the per-exam override when present' do
      exam = create(:exam,
                    exam_template: template,
                    subject_override: 'Chemistry',
                    paper_number_override: '2',
                    tier_override: 'standard',
                    centre_name_override: 'Other School')
      expect(exam.subject).to eq('Chemistry')
      expect(exam.paper_number).to eq('2')
      expect(exam.tier).to eq('standard')
      expect(exam.centre_name).to eq('Other School')
    end

    it 'returns nil for inherited fields when no template is set' do
      exam = create(:exam, exam_template: nil)
      expect(exam.subject).to be_nil
      expect(exam.tier).to be_nil
    end
  end
end
