# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkingStep, type: :model do
  let(:question) { create(:question) }

  describe 'validations' do
    it 'requires a kind from m|a|b|dm' do
      expect(build(:marking_step, question: question, kind: 'x')).not_to be_valid
      %w[m a b dm].each do |k|
        expect(build(:marking_step, question: question, kind: k)).to be_valid
      end
    end

    it 'requires a positive n' do
      expect(build(:marking_step, question: question, n: 0)).not_to be_valid
      expect(build(:marking_step, question: question, n: 2)).to be_valid
    end

    it 'requires text' do
      expect(build(:marking_step, question: question, text: '')).not_to be_valid
    end

    it 'auto-assigns position in insertion order' do
      s1 = create(:marking_step, question: question)
      s2 = create(:marking_step, question: question)
      expect(s1.position).to eq(1)
      expect(s2.position).to eq(2)
    end
  end

  describe 'accepts/rejects string arrays' do
    it 'stores accept variants' do
      step = create(:marking_step, question: question,
                                   accepts: ['γ', 'photons'],
                                   rejects: ['W', 'Z'])
      expect(step.reload.accepts).to eq(['γ', 'photons'])
      expect(step.reload.rejects).to eq(['W', 'Z'])
    end
  end

  describe 'ordering scope' do
    it 'orders by position ascending' do
      s2 = create(:marking_step, question: question, position: 2)
      s1 = create(:marking_step, question: question, position: 1)
      expect(question.marking_steps.ordered).to eq([s1, s2])
    end
  end

  describe 'Question#has_structured_marking?' do
    it 'is false when no marking steps exist' do
      expect(question.has_structured_marking?).to be(false)
    end

    it 'is true once a marking step is attached' do
      create(:marking_step, question: question)
      expect(question.reload.has_structured_marking?).to be(true)
    end
  end
end
