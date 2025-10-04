require 'rails_helper'

RSpec.describe 'Questions Import', type: :request do
  let(:user) { create(:user) } # Assuming you have user authentication
  let(:csv_file) { fixture_file_upload('questions_import_sample.csv', 'text/csv') }

  before do
    # Create sample CSV file for testing
    create_sample_csv_file
  end

  describe 'GET /questions/import' do
    it 'renders the import page' do
      get import_questions_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Import Questions from CSV')
      expect(response.body).to include('CSV template')
    end
  end

  describe 'POST /questions/import_csv' do
    context 'with valid CSV file' do
      it 'imports questions successfully' do
        expect {
          post import_csv_questions_path, params: { csv_file: csv_file }
        }.to change(Question, :count).by(2)
         .and change(Topic, :count).by(1)
         .and change(Source, :count).by(1)

        expect(response).to redirect_to(questions_path)
        follow_redirect!
        expect(response.body).to include('Import successful!')
      end

      it 'imports with preview mode' do
        expect {
          post import_csv_questions_path, params: { 
            csv_file: csv_file, 
            preview_only: 'true' 
          }
        }.not_to change(Question, :count)

        expect(response).to redirect_to(import_questions_path)
        follow_redirect!
        expect(response.body).to include('Preview successful!')
      end
    end

    context 'with invalid CSV file' do
      let(:invalid_csv_file) { fixture_file_upload('invalid_questions.csv', 'text/csv') }

      before do
        create_invalid_csv_file
      end

      it 'handles validation errors' do
        expect {
          post import_csv_questions_path, params: { csv_file: invalid_csv_file }
        }.not_to change(Question, :count)

        expect(response).to redirect_to(import_questions_path)
        follow_redirect!
        expect(response.body).to include('Import failed:')
      end
    end

    context 'without CSV file' do
      it 'redirects with error message' do
        post import_csv_questions_path

        expect(response).to redirect_to(import_questions_path)
        follow_redirect!
        expect(response.body).to include('Please select a CSV file to import')
      end
    end

    context 'with unexpected error' do
      before do
        allow(QuestionsImporter).to receive(:call).and_raise(StandardError, 'Unexpected error')
      end

      it 'handles unexpected errors gracefully' do
        post import_csv_questions_path, params: { csv_file: csv_file }

        expect(response).to redirect_to(import_questions_path)
        follow_redirect!
        expect(response.body).to include('Unexpected error: Unexpected error')
      end
    end
  end

  describe 'POST /questions/import_preview' do
    let(:valid_csv_data) do
      [
        ['Physics', 'written', 'Test question?', 'Test answer', '2', 'short', '', '', '', ''],
        ['Physics', 'multiple_choice', 'MC question?', 'A - Correct', '1', 'short', '', '', '', '', 'Option A|Option B|Option C']
      ]
    end

    it 'returns JSON preview result' do
      post import_preview_questions_path, params: { csv_data: valid_csv_data.to_json }

      expect(response).to have_http_status(:success)
      result = JSON.parse(response.body)
      expect(result['success']).to be true
      expect(result['created_questions']).to eq(0) # Dry run
      expect(result['errors']).to be_empty
    end

    it 'handles invalid CSV data' do
      invalid_data = [['', 'written', 'Test question?', 'Test answer', '2', 'short', '', '', '', '']]
      
      post import_preview_questions_path, params: { csv_data: invalid_data.to_json }

      expect(response).to have_http_status(:unprocessable_entity)
      result = JSON.parse(response.body)
      expect(result['error']).to be_present
    end

    it 'handles missing CSV data' do
      post import_preview_questions_path

      expect(response).to have_http_status(:bad_request)
      result = JSON.parse(response.body)
      expect(result['error']).to eq('No CSV data provided')
    end
  end

  private

  def create_sample_csv_file
    csv_content = <<~CSV
      topic,question_type,content,answer,points,answer_size,source,source_reference,answer_label,unit,options,left_items,right_items,image,labels,markers,masks,parts
      Physics,written,"Explain MOSFET operation","High input impedance",2,short,Feynman Lectures,Ch 14,,,,,,,,,,
      Electronics,multiple_choice,"What does Ω represent?","A - Ohms",1,short,,,,,"Ohms|Webers|Siemens|Tesla",,,,,,,
    CSV

    File.open(Rails.root.join('spec', 'fixtures', 'questions_import_sample.csv'), 'w') do |f|
      f.write(csv_content)
    end
  end

  def create_invalid_csv_file
    csv_content = <<~CSV
      topic,question_type,content,answer,points,answer_size,source,source_reference,answer_label,unit,options,left_items,right_items,image,labels,markers,masks,parts
      ,written,"Test question?","Test answer",2,short,,,,,,,,,,,,,
      Physics,invalid_type,"Test question?","Test answer",2,short,,,,,,,,,,,,,
    CSV

    File.open(Rails.root.join('spec', 'fixtures', 'invalid_questions.csv'), 'w') do |f|
      f.write(csv_content)
    end
  end
end
