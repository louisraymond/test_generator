require 'rails_helper'

RSpec.describe QuestionRowParser, type: :service do
  describe '#parse' do
    context 'with valid written question' do
      let(:row_data) do
        ['Physics', 'written', 'Explain MOSFET operation', 'High input impedance', '2', 'short', 'Feynman', 'Ch 14', '', '']
      end

      it 'parses basic fields correctly' do
        parser = QuestionRowParser.new(row_data, 1)
        result = parser.parse

        expect(result[:topic]).to eq('Physics')
        expect(result[:question_type]).to eq('written')
        expect(result[:content]).to eq('Explain MOSFET operation')
        expect(result[:answer]).to eq('High input impedance')
        expect(result[:points]).to eq(2)
        expect(result[:answer_size]).to eq('short')
        expect(result[:source]).to eq('Feynman')
        expect(result[:source_reference]).to eq('Ch 14')
        expect(parser.errors).to be_empty
      end
    end

    context 'with multiple choice question' do
      let(:row_data) do
        ['Physics', 'multiple_choice', 'What does Ω represent?', 'A - Ohms', '1', 'short', '', '', '', '', 'Ohms|Webers|Siemens|Tesla']
      end

      it 'parses options correctly' do
        parser = QuestionRowParser.new(row_data, 1)
        result = parser.parse

        expect(result[:options]).to eq(['Ohms', 'Webers', 'Siemens', 'Tesla'])
        expect(parser.errors).to be_empty
      end
    end

    context 'with matching question' do
      let(:row_data) do
        ['Electronics', 'matching', 'Match units to quantities', 'Ohm → Resistance', '3', 'short', '', '', '', '', '', 'Ohm (Ω)|Farad (F)|Henry (H)', 'Resistance|Capacitance|Inductance']
      end

      it 'parses left and right items correctly' do
        parser = QuestionRowParser.new(row_data, 1)
        result = parser.parse

        expected_options = {
          'left' => ['Ohm (Ω)', 'Farad (F)', 'Henry (H)'],
          'right' => ['Resistance', 'Capacitance', 'Inductance']
        }
        expect(result[:options]).to eq(expected_options)
        expect(parser.errors).to be_empty
      end
    end

    context 'with diagram label question' do
      let(:row_data) do
        ['Electronics', 'diagram_label', 'Label the MOSFET terminals', 'Gate, Source, Drain', '2', 'short', '', '', '', '', '', '', '', 'MOSFET_symbol.svg', 'Gate|Source|Drain', '[{"x":25,"y":30},{"x":75,"y":50}]']
      end

      it 'parses image and labels correctly' do
        parser = QuestionRowParser.new(row_data, 1)
        result = parser.parse

        expected_options = {
          'image' => 'MOSFET_symbol.svg',
          'labels' => ['Gate', 'Source', 'Drain'],
          'markers' => [{'x' => 25, 'y' => 30}, {'x' => 75, 'y' => 50}]
        }
        expect(result[:options]).to eq(expected_options)
        expect(parser.errors).to be_empty
      end
    end

    context 'with composite question' do
      let(:row_data) do
        ['TOC', 'composite', 'Answer the following about TOC', 'a) Definition; b) Exploit', '5', 'medium', '', '', '', '', '', '', '', '', '', '', '[{"type":"written","content":"a) Define constraint","points":1},{"type":"multiple_choice","content":"b) What is step 2?","options":["Identify","Exploit"],"points":2}]']
      end

      it 'parses parts correctly' do
        parser = QuestionRowParser.new(row_data, 1)
        result = parser.parse

        expected_parts = [
          {'type' => 'written', 'content' => 'a) Define constraint', 'points' => 1},
          {'type' => 'multiple_choice', 'content' => 'b) What is step 2?', 'options' => ['Identify', 'Exploit'], 'points' => 2}
        ]
        expect(result[:options]['parts']).to eq(expected_parts)
        expect(parser.errors).to be_empty
      end
    end

    context 'with validation errors' do
      it 'reports missing required fields' do
        row_data = ['', 'written', 'Test question?', 'Test answer', '2', 'short', '', '', '', '']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include('Missing required field: topic')
      end

      it 'reports invalid question type' do
        row_data = ['Physics', 'invalid_type', 'Test question?', 'Test answer', '2', 'short', '', '', '', '']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include(match(/Invalid question_type/))
      end

      it 'reports invalid points' do
        row_data = ['Physics', 'written', 'Test question?', 'Test answer', '150', 'short', '', '', '', '']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include(match(/Points must be between 1 and 100/))
      end

      it 'reports invalid answer size' do
        row_data = ['Physics', 'written', 'Test question?', 'Test answer', '2', 'invalid_size', '', '', '', '']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include(match(/Invalid answer_size/))
      end

      it 'reports multiple choice validation errors' do
        row_data = ['Physics', 'multiple_choice', 'Test question?', 'A - Correct', '1', 'short', '', '', '', '', '']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include('Multiple choice questions require at least 2 options')
      end

      it 'reports matching validation errors' do
        row_data = ['Physics', 'matching', 'Test question?', 'A → B', '1', 'short', '', '', '', '', '', 'Item 1|Item 2', 'Item A']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include('Left and right items must have the same length')
      end

      it 'reports invalid JSON in markers' do
        row_data = ['Physics', 'diagram_label', 'Test question?', 'Answer', '1', 'short', '', '', '', '', '', '', '', 'image.svg', 'Label 1', 'invalid json']
        parser = QuestionRowParser.new(row_data, 1)
        parser.parse

        expect(parser.errors).to include(match(/Invalid markers JSON/))
      end
    end

    context 'with pipe-separated parsing' do
      it 'handles empty values correctly' do
        parser = QuestionRowParser.new(['', '', '', '', '', '', '', '', '', '', 'Option A||Option C'], 1)
        result = parser.parse

        expect(result[:options]).to eq(['Option A', 'Option C'])
      end

      it 'handles whitespace correctly' do
        parser = QuestionRowParser.new(['', '', '', '', '', '', '', '', '', '', ' Option A | Option B | Option C '], 1)
        result = parser.parse

        expect(result[:options]).to eq(['Option A', 'Option B', 'Option C'])
      end
    end
  end
end
