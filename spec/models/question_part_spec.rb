require 'rails_helper'

RSpec.describe QuestionPart, type: :model do
  let(:topic)    { Topic.create!(name: 'T') }
  let(:question) do
    Question.create!(topic: topic, content: 'parent', answer: 'a',
                     points: 5, question_type: 'composite')
  end

  it 'nests parts via parent_part and exposes children + depth' do
    root = described_class.create!(question: question, part_type: 'written',
                                   position: 1, marks: 2, stem: 'a')
    child = described_class.create!(question: question, parent_part: root,
                                    part_type: 'written',
                                    position: 1, marks: 1, stem: 'i')
    expect(root.children).to include(child)
    expect(child.depth).to eq(1)
    expect(root.depth).to eq(0)
    expect(question.question_parts.count).to eq(1) # only roots
  end

  it 'orders parts by position via .ordered scope' do
    a = described_class.create!(question: question, part_type: 'written',
                                position: 2, marks: 1, stem: 'second')
    b = described_class.create!(question: question, part_type: 'written',
                                position: 1, marks: 1, stem: 'first')
    expect(described_class.roots.ordered.to_a).to eq([b, a])
  end

  it 'exposes typed_options via the registry' do
    part = described_class.create!(question: question, part_type: 'multiple_choice',
                                   position: 1, marks: 1, stem: 's',
                                   options: [{ 'text' => 'a', 'correct' => true },
                                             { 'text' => 'b' }])
    expect(part.typed_options).to be_a(QuestionOptions::MCQOptions)
  end
end
