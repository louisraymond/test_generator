require 'rails_helper'

RSpec.describe QuestionTypeValidator, type: :service do
  describe '#validate' do
    context 'with multiple choice questions' do
      it 'validates correct multiple choice options' do
        question_data = {
          question_type: 'multiple_choice',
          options: ['Option A', 'Option B', 'Option C', 'Option D']
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for empty options' do
        question_data = {
          question_type: 'multiple_choice',
          options: []
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Multiple choice questions must have options array')
      end

      it 'reports error for insufficient options' do
        question_data = {
          question_type: 'multiple_choice',
          options: ['Only one option']
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Multiple choice questions must have at least 2 options')
      end

      it 'warns for too many options' do
        question_data = {
          question_type: 'multiple_choice',
          options: (1..15).map { |i| "Option #{i}" }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Multiple choice questions with more than 10 options may be difficult to display')
      end

      it 'warns for duplicate options' do
        question_data = {
          question_type: 'multiple_choice',
          options: ['Option A', 'Option B', 'Option A']
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Multiple choice options contain duplicates')
      end
    end

    context 'with matching questions' do
      it 'validates correct matching options' do
        question_data = {
          question_type: 'matching',
          options: {
            'left' => ['Item 1', 'Item 2', 'Item 3'],
            'right' => ['Match A', 'Match B', 'Match C']
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for missing left/right arrays' do
        question_data = {
          question_type: 'matching',
          options: {}
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Matching questions must have left and right arrays in options')
      end

      it 'reports error for mismatched array lengths' do
        question_data = {
          question_type: 'matching',
          options: {
            'left' => ['Item 1', 'Item 2'],
            'right' => ['Match A']
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Matching left and right arrays must have the same length')
      end

      it 'reports error for insufficient pairs' do
        question_data = {
          question_type: 'matching',
          options: {
            'left' => ['Item 1'],
            'right' => ['Match A']
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Matching questions must have at least 2 pairs')
      end
    end

    context 'with diagram label questions' do
      it 'validates correct diagram label options' do
        question_data = {
          question_type: 'diagram_label',
          options: {
            'image' => 'MOSFET_symbol.svg',
            'labels' => ['Gate', 'Source', 'Drain'],
            'markers' => [{'x' => 25, 'y' => 30}, {'x' => 75, 'y' => 50}]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for missing image' do
        question_data = {
          question_type: 'diagram_label',
          options: {
            'labels' => ['Label 1', 'Label 2']
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Diagram label questions must specify an image')
      end

      it 'reports error for missing labels' do
        question_data = {
          question_type: 'diagram_label',
          options: {
            'image' => 'MOSFET_symbol.svg'
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Diagram label questions must have labels array')
      end

      it 'validates marker coordinates' do
        question_data = {
          question_type: 'diagram_label',
          options: {
            'image' => 'MOSFET_symbol.svg',
            'labels' => ['Label 1'],
            'markers' => [{'x' => 150, 'y' => 30}] # Invalid x coordinate
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Marker 1 x coordinate must be between 0 and 100')
      end

      it 'warns for mismatched markers and labels count' do
        question_data = {
          question_type: 'diagram_label',
          options: {
            'image' => 'MOSFET_symbol.svg',
            'labels' => ['Label 1', 'Label 2'],
            'markers' => [{'x' => 25, 'y' => 30}]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Number of markers (1) doesn\'t match number of labels (2)')
      end
    end

    context 'with image occlusion questions' do
      it 'validates correct image occlusion options' do
        question_data = {
          question_type: 'image_occlusion',
          options: {
            'image' => 'circuit_diagram.svg',
            'masks' => [{'x' => 35, 'y' => 30, 'w' => 25, 'h' => 15}]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for missing image' do
        question_data = {
          question_type: 'image_occlusion',
          options: {
            'masks' => [{'x' => 35, 'y' => 30, 'w' => 25, 'h' => 15}]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Image occlusion questions must specify an image')
      end

      it 'validates mask coordinates' do
        question_data = {
          question_type: 'image_occlusion',
          options: {
            'image' => 'circuit_diagram.svg',
            'masks' => [{'x' => 35, 'y' => 30, 'w' => 150, 'h' => 15}] # Invalid width
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Mask 1 width must be between 0 and 100')
      end
    end

    context 'with composite questions' do
      it 'validates correct composite options' do
        question_data = {
          question_type: 'composite',
          options: {
            'parts' => [
              {'type' => 'written', 'content' => 'Part A', 'points' => 1},
              {'type' => 'multiple_choice', 'content' => 'Part B', 'options' => ['A', 'B'], 'points' => 2}
            ]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for missing parts' do
        question_data = {
          question_type: 'composite',
          options: {}
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Composite questions must have parts array')
      end

      it 'reports error for empty parts' do
        question_data = {
          question_type: 'composite',
          options: {
            'parts' => []
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Composite questions must have at least one part')
      end

      it 'validates individual parts' do
        question_data = {
          question_type: 'composite',
          options: {
            'parts' => [
              {'type' => 'written', 'content' => '', 'points' => 1} # Missing content
            ]
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Part 1 must have content')
      end

      it 'warns for too many parts' do
        question_data = {
          question_type: 'composite',
          options: {
            'parts' => (1..8).map { |i| {'type' => 'written', 'content' => "Part #{i}", 'points' => 1} }
          }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Composite questions with more than 5 parts may be difficult to display')
      end
    end

    context 'with calculation questions' do
      it 'warns for missing answer_label' do
        question_data = {
          question_type: 'calculation',
          answer_label: nil,
          unit: 'V'
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Calculation questions should have answer_label')
      end

      it 'warns for missing unit' do
        question_data = {
          question_type: 'calculation',
          answer_label: 'V',
          unit: nil
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Calculation questions should have unit')
      end
    end

    context 'with ordering/ranking questions' do
      it 'validates correct ordering options' do
        question_data = {
          question_type: 'ordering',
          options: ['Item 1', 'Item 2', 'Item 3']
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to be_empty
      end

      it 'reports error for insufficient items' do
        question_data = {
          question_type: 'ranking',
          options: ['Only one item']
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.errors).to include('Ordering/ranking questions must have at least 2 items')
      end

      it 'warns for too many items' do
        question_data = {
          question_type: 'ordering',
          options: (1..15).map { |i| "Item #{i}" }
        }
        
        validator = QuestionTypeValidator.new(question_data)
        validator.validate

        expect(validator.warnings).to include('Ordering/ranking questions with more than 10 items may be difficult to display')
      end
    end
  end
end
