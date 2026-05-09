require 'rails_helper'

RSpec.describe LearningObjective, type: :model do
  describe '#question_count' do
    let(:topic) { create(:topic) }
    let(:lo)    { create(:learning_objective, topic: topic) }

    it 'returns 0 when the LO has no questions' do
      expect(lo.question_count).to eq(0)
    end

    it 'matches questions.size for an LO with multiple questions' do
      3.times { lo.questions << create(:question, topic: topic) }
      lo.reload
      expect(lo.question_count).to eq(lo.questions.size)
      expect(lo.question_count).to eq(3)
    end
  end

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

  describe '.exam_appearance_counts_for' do
    let(:topic) { create(:topic) }

    it 'returns a Hash mapping lo.id => count' do
      lo = create(:learning_objective, topic: topic)
      q  = create(:question, topic: topic)
      lo.questions << q
      create(:exam_question, exam: create(:exam), question: q, position: 1)

      result = LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
      expect(result).to be_a(Hash)
      expect(result[lo.id]).to eq(1)
    end

    it 'executes in a single SQL query' do
      lo = create(:learning_objective, topic: topic)
      q  = create(:question, topic: topic)
      lo.questions << q
      create(:exam_question, exam: create(:exam), question: q, position: 1)

      count = QueryCounter.count_for do
        LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
      end
      expect(count).to eq(1)
    end

    it 'returns correct counts across LOs with varied exam exposure' do
      lo_a = create(:learning_objective, topic: topic)
      lo_b = create(:learning_objective, topic: topic)
      lo_c = create(:learning_objective, topic: topic) # zero questions
      q_a  = create(:question, topic: topic)
      q_b  = create(:question, topic: topic)
      lo_a.questions << q_a
      lo_b.questions << q_b
      e1 = create(:exam)
      e2 = create(:exam)
      create(:exam_question, exam: e1, question: q_a, position: 1)
      create(:exam_question, exam: e2, question: q_a, position: 1)
      create(:exam_question, exam: e1, question: q_b, position: 2)

      result = LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
      expect(result[lo_a.id]).to eq(2)
      expect(result[lo_b.id]).to eq(1)
      expect(result.fetch(lo_c.id, 0)).to eq(0)
    end

    it 'omits LOs with no exam appearances from the keys (caller uses fetch)' do
      lo_with    = create(:learning_objective, topic: topic)
      lo_without = create(:learning_objective, topic: topic)
      q          = create(:question, topic: topic)
      lo_with.questions << q
      create(:exam_question, exam: create(:exam), question: q, position: 1)

      result = LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
      expect(result).to have_key(lo_with.id)
      expect(result).not_to have_key(lo_without.id)
      expect(result.fetch(lo_without.id, 0)).to eq(0)
    end
  end
end
