require 'rails_helper'

RSpec.describe LearningObjective, type: :model do
  describe '#exam_appearance_count' do
    let(:topic) { create(:topic) }
    let(:lo)    { create(:learning_objective, topic: topic) }

    it 'returns 0 when the LO has no questions' do
      expect(lo.exam_appearance_count).to eq(0)
    end

    it 'returns 0 when LO has questions but none are in any exam' do
      q = create(:question, topic: topic)
      lo.questions << q
      expect(lo.exam_appearance_count).to eq(0)
    end

    it "returns 1 when all the LO's questions appear in a single exam" do
      exam = create(:exam)
      q1   = create(:question, topic: topic)
      q2   = create(:question, topic: topic)
      lo.questions << q1
      lo.questions << q2
      create(:exam_question, exam: exam, question: q1, position: 1)
      create(:exam_question, exam: exam, question: q2, position: 2)
      expect(lo.exam_appearance_count).to eq(1)
    end

    it "returns 2 when the LO's questions span two distinct exams" do
      exam_a = create(:exam)
      exam_b = create(:exam)
      q      = create(:question, topic: topic)
      lo.questions << q
      create(:exam_question, exam: exam_a, question: q, position: 1)
      create(:exam_question, exam: exam_b, question: q, position: 1)
      expect(lo.exam_appearance_count).to eq(2)
    end

    it 'counts an exam once even if two of the LOs questions both appear in it' do
      exam = create(:exam)
      q1   = create(:question, topic: topic)
      q2   = create(:question, topic: topic)
      lo.questions << q1
      lo.questions << q2
      create(:exam_question, exam: exam, question: q1, position: 1)
      create(:exam_question, exam: exam, question: q2, position: 2)
      expect(lo.exam_appearance_count).to eq(1)
    end

    it 'is not influenced by other LOs whose questions appear in the same exams' do
      exam = create(:exam)
      other_lo = create(:learning_objective, topic: topic)
      other_q  = create(:question, topic: topic)
      other_lo.questions << other_q
      create(:exam_question, exam: exam, question: other_q, position: 1)
      expect(lo.exam_appearance_count).to eq(0)
    end

    it "attributes a shared question's exam to every LO it links to" do
      exam = create(:exam)
      q    = create(:question, topic: topic)
      other_lo = create(:learning_objective, topic: topic)
      lo.questions << q
      other_lo.questions << q
      create(:exam_question, exam: exam, question: q, position: 1)
      expect(lo.exam_appearance_count).to eq(1)
      expect(other_lo.exam_appearance_count).to eq(1)
    end
  end
end
