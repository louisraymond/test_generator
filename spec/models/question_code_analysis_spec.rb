require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'code_analysis question type' do
    let(:valid_lines_options) do
      {
        'language' => 'python',
        'code' => "def fib(n):\n    return n if n < 2 else fib(n-1) + fib(n-2)",
        'answer_format' => 'lines'
      }
    end

    let(:valid_mc_options) do
      {
        'language' => 'ruby',
        'code' => "def names(items)\n  items.map(&:name).uniq\nend",
        'answer_format' => 'multiple_choice',
        'choices' => [
          { 'text' => 'Returns unique names', 'correct' => true },
          { 'text' => 'Mutates the items array', 'correct' => false },
          { 'text' => 'Raises NoMethodError', 'correct' => false }
        ]
      }
    end

    describe 'accepted as a question type' do
      it 'is included in QUESTION_TYPES' do
        expect(Question::QUESTION_TYPES).to include('code_analysis')
      end

      it 'is valid with lines answer_format' do
        q = build(:question, question_type: 'code_analysis', options: valid_lines_options)
        expect(q).to be_valid
      end

      it 'is valid with multiple_choice answer_format' do
        q = build(:question, question_type: 'code_analysis', options: valid_mc_options)
        expect(q).to be_valid
      end
    end

    describe 'validation' do
      it 'rejects non-hash options' do
        q = build(:question, question_type: 'code_analysis', options: ['not', 'a', 'hash'])
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to include('hash')
      end

      it 'requires code to be present' do
        q = build(:question, question_type: 'code_analysis', options: valid_lines_options.merge('code' => ''))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to include('code')
      end

      it 'requires code to be non-blank' do
        q = build(:question, question_type: 'code_analysis', options: valid_lines_options.merge('code' => "   \n  "))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to include('code')
      end

      it 'rejects missing answer_format' do
        opts = valid_lines_options.dup.tap { |o| o.delete('answer_format') }
        q = build(:question, question_type: 'code_analysis', options: opts)
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to match(/answer_format/)
      end

      it 'rejects unknown answer_format' do
        q = build(:question, question_type: 'code_analysis',
                             options: valid_lines_options.merge('answer_format' => 'essay'))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to match(/answer_format/)
      end

      it 'rejects multiple_choice without choices array' do
        q = build(:question, question_type: 'code_analysis',
                             options: valid_mc_options.merge('choices' => nil))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to match(/choices|2 choices/)
      end

      it 'rejects multiple_choice with fewer than 2 choices' do
        q = build(:question, question_type: 'code_analysis',
                             options: valid_mc_options.merge('choices' => [{ 'text' => 'A', 'correct' => true }]))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to match(/2 choices/)
      end

      it 'rejects multiple_choice with no correct choice' do
        q = build(:question, question_type: 'code_analysis',
                             options: valid_mc_options.merge('choices' => [
                               { 'text' => 'A', 'correct' => false },
                               { 'text' => 'B', 'correct' => false }
                             ]))
        expect(q).not_to be_valid
        expect(q.errors[:options].join(' ')).to match(/correct/)
      end

      it 'lines format does not require choices' do
        q = build(:question, question_type: 'code_analysis', options: valid_lines_options)
        expect(q).to be_valid
      end

      it 'permits language to be blank (falls back to plain text)' do
        q = build(:question, question_type: 'code_analysis',
                             options: valid_lines_options.merge('language' => ''))
        expect(q).to be_valid
      end
    end
  end
end
