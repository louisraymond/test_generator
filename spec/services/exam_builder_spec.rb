require 'rails_helper'

RSpec.describe ExamBuilder do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }

  before do
    # Create a pool of questions for the topic
    10.times { create(:question, topic: topic, source: source) }
  end

  describe '.call' do
    it 'creates an exam with the requested number of questions' do
      exam = described_class.call(topic_ids: [topic.id], count: 5)
      expect(exam).to be_persisted
      expect(exam.exam_questions.count).to eq(5)
    end

    it 'sets the exam title' do
      exam = described_class.call(topic_ids: [topic.id], count: 3, title: 'My Exam')
      expect(exam.title).to eq('My Exam')
    end

    it 'defaults title to Practice Exam' do
      exam = described_class.call(topic_ids: [topic.id], count: 3)
      expect(exam.title).to eq('Practice Exam')
    end

    it 'sets duration_minutes when provided' do
      exam = described_class.call(topic_ids: [topic.id], count: 3, duration_minutes: 90)
      expect(exam.duration_minutes).to eq(90)
    end

    it 'assigns sequential positions to exam questions' do
      exam = described_class.call(topic_ids: [topic.id], count: 5)
      positions = exam.exam_questions.order(:position).pluck(:position)
      expect(positions).to eq([1, 2, 3, 4, 5])
    end

    context 'with strict mode' do
      it 'raises NotEnoughQuestionsError when requesting more than available' do
        expect {
          described_class.call(topic_ids: [topic.id], count: 20, strict: true)
        }.to raise_error(ExamBuilder::NotEnoughQuestionsError, /requested 20/)
      end

      it 'raises MissingTopicsError when no topics given' do
        expect {
          described_class.call(topic_ids: [], count: 5)
        }.to raise_error(ExamBuilder::MissingTopicsError)
      end

      it 'raises when no questions exist for selected topics' do
        empty_topic = create(:topic)
        expect {
          described_class.call(topic_ids: [empty_topic.id], count: 5)
        }.to raise_error(ExamBuilder::NotEnoughQuestionsError, /No questions available/)
      end
    end

    context 'with allow_repeats: true' do
      it 'pads by cycling to reach requested count' do
        exam = described_class.call(
          topic_ids: [topic.id], count: 15, allow_repeats: true
        )
        expect(exam.exam_questions.count).to eq(15)
      end
    end

    context 'with question type filter' do
      before do
        3.times { create(:question, :multiple_choice, topic: topic, source: source) }
      end

      it 'filters by question type' do
        exam = described_class.call(
          topic_ids: [topic.id], count: 3, types: ['multiple_choice']
        )
        question_types = exam.questions.pluck(:question_type).uniq
        expect(question_types).to eq(['multiple_choice'])
      end
    end

    context 'with topic_weights' do
      let(:topic2) { create(:topic) }

      before do
        5.times { create(:question, topic: topic2, source: source) }
      end

      it 'distributes questions proportionally by weight' do
        exam = described_class.call(
          topic_ids: [topic.id, topic2.id],
          count: 10,
          topic_weights: { topic.id.to_s => 3.0, topic2.id.to_s => 1.0 }
        )
        expect(exam.exam_questions.count).to eq(10)
      end
    end
  end

  describe '.allocate_by_weights' do
    it 'distributes questions by weight' do
      scope = Question.where(topic_id: topic.id)
      result = described_class.allocate_by_weights(
        scope, [topic.id.to_s], { topic.id.to_s => 1.0 }, 5
      )
      expect(result.size).to eq(5)
    end

    it 'caps allocation at available count' do
      scope = Question.where(topic_id: topic.id)
      result = described_class.allocate_by_weights(
        scope, [topic.id.to_s], { topic.id.to_s => 1.0 }, 20
      )
      expect(result.size).to eq(10) # only 10 available
    end
  end

  describe '.from_template' do
    let(:template) { create(:exam_template) }
    let(:section) do
      create(:exam_section, exam_template: template, question_count: 3, position: 0)
    end

    before do
      create(:section_source_rule, exam_section: section, source_type: 'Topic', source_id: topic.id)
    end

    it 'creates an exam from a template' do
      exam = described_class.from_template(template_id: template.id)
      expect(exam).to be_persisted
      expect(exam.exam_template).to eq(template)
    end

    it 'generates a default title with template name and date' do
      exam = described_class.from_template(template_id: template.id)
      expect(exam.title).to include(template.name)
    end

    it 'increments the template use count' do
      expect {
        described_class.from_template(template_id: template.id)
      }.to change { template.reload.use_count }.by(1)
    end

    it 'assigns section numbers to exam questions' do
      exam = described_class.from_template(template_id: template.id)
      section_numbers = exam.exam_questions.pluck(:section_number).uniq
      expect(section_numbers).to eq([0])
    end

    context 'with no sections' do
      let(:empty_template) { create(:exam_template) }

      it 'raises MissingSectionsError' do
        expect {
          described_class.from_template(template_id: empty_template.id)
        }.to raise_error(ExamBuilder::MissingSectionsError)
      end
    end

    context 'with force-included questions' do
      let(:forced_question) { create(:question, topic: topic, source: source) }

      before do
        create(:section_question_rule,
          exam_section: section,
          question: forced_question,
          rule_type: 'force_include',
          repeat_count: 1
        )
      end

      it 'includes the forced question in the exam' do
        exam = described_class.from_template(template_id: template.id)
        expect(exam.questions).to include(forced_question)
      end
    end
  end
end
